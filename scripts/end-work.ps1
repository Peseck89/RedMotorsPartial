<#
RedMotors end-work script.

Safety rules:
- AutoSafe mode may add, commit, and push only WORK_LOG.md and WEEKLY_REPORT_LOG.md.
- No deploy, retrieve, git reset, git clean, pull, or Salesforce metadata operations.
- If non-log files are pending, automatic closure is blocked.
- Manual mode can append logs, but does not run git add, commit, or push.
#>

[CmdletBinding()]
param(
    [ValidateSet("AutoSafe", "Manual")]
    [string]$Mode = "AutoSafe"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

function Write-Section {
    param([string]$Title)

    Write-Host ""
    Write-Host "=== $Title ==="
}

function Test-Tool {
    param([string]$Name)

    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Get-Array {
    param([object]$Value)

    if ($null -eq $Value) {
        return @()
    }

    return @($Value)
}

function Invoke-LoggedCommand {
    param(
        [string]$Label,
        [string]$FilePath,
        [string[]]$ArgumentList = @(),
        [switch]$Quiet
    )

    $commandText = if ($ArgumentList.Count -gt 0) {
        "$FilePath $($ArgumentList -join ' ')"
    }
    else {
        $FilePath
    }

    if (-not $Quiet) {
        Write-Host ""
        Write-Host "> $commandText"
    }

    try {
        $global:LASTEXITCODE = $null
        $output = & $FilePath @ArgumentList 2>&1
        $lines = @($output | ForEach-Object { "$_" })

        if (-not $Quiet) {
            foreach ($line in $lines) {
                Write-Host $line
            }
        }

        $exitCode = if ($null -ne $global:LASTEXITCODE) {
            [int]$global:LASTEXITCODE
        }
        else {
            0
        }

        if ($exitCode -ne 0 -and -not $Quiet) {
            Write-Host "Advertencia: $Label fallo con codigo $exitCode."
        }

        return [pscustomobject]@{
            ExitCode = $exitCode
            Output   = $lines
        }
    }
    catch {
        if (-not $Quiet) {
            Write-Host "Advertencia: $Label no se pudo ejecutar: $($_.Exception.Message)"
        }

        return [pscustomobject]@{
            ExitCode = 1
            Output   = @()
        }
    }
}

function Get-FirstStatusLine {
    param([string[]]$StatusOutput)

    $lines = @($StatusOutput | Where-Object { $_ -like "## *" } | Select-Object -First 1)
    if ($lines.Count -eq 0) {
        return ""
    }

    return $lines[0]
}

function Get-StatusBody {
    param([string[]]$StatusOutput)

    return @($StatusOutput | Where-Object { $_ -and ($_ -notlike "## *") })
}

function Get-StatusPaths {
    param([string[]]$StatusBody)

    $paths = @()

    foreach ($line in $StatusBody) {
        if ($line -match "^\?\?\s+(.+)$") {
            $paths += $Matches[1].Trim()
            continue
        }

        if ($line.Length -gt 3) {
            $path = $line.Substring(3).Trim()
            if ($path -match "\s+->\s+") {
                $path = @($path -split "\s+->\s+")[-1]
            }

            if (-not [string]::IsNullOrWhiteSpace($path)) {
                $paths += $path
            }
        }
    }

    return @($paths | Sort-Object -Unique)
}

function Get-GitFacts {
    param([string[]]$StatusOutput)

    $statusLine = Get-FirstStatusLine -StatusOutput $StatusOutput
    $statusBody = @(Get-StatusBody -StatusOutput $StatusOutput)
    $untrackedLines = @($statusBody | Where-Object { $_ -match "^\?\?\s+" })
    $trackedChangeLines = @($statusBody | Where-Object { $_ -notmatch "^\?\?\s+" })
    $paths = @(Get-StatusPaths -StatusBody $statusBody)
    $forceAppChanges = @($statusBody | Where-Object { $_ -match "force-app[\\/]" })
    $aheadCount = 0
    $behindCount = 0

    if ($statusLine -match "ahead\s+(\d+)") {
        $aheadCount = [int]$Matches[1]
    }

    if ($statusLine -match "behind\s+(\d+)") {
        $behindCount = [int]$Matches[1]
    }

    return [pscustomobject]@{
        StatusLine         = $statusLine
        StatusBody         = @($statusBody)
        Paths              = @($paths)
        HasLocalChanges    = $trackedChangeLines.Count -gt 0
        HasUntracked       = $untrackedLines.Count -gt 0
        IsAhead            = $aheadCount -gt 0
        IsBehind           = $behindCount -gt 0
        AheadCount         = $aheadCount
        BehindCount        = $behindCount
        HasPendingCommit   = $statusBody.Count -gt 0
        HasPendingPush     = $aheadCount -gt 0
        HasForceAppChanges = $forceAppChanges.Count -gt 0
    }
}

function Convert-MarkdownTableValue {
    param([string]$Value)

    if ($null -eq $Value) {
        return ""
    }

    return ($Value -replace "\|", "/" -replace "`r?`n", " ").Trim()
}

function Get-TimeTotalText {
    param(
        [string]$StartTime,
        [string]$EndTime
    )

    if ([string]::IsNullOrWhiteSpace($StartTime) -or $StartTime -eq "No registrado") {
        return "No registrado"
    }

    try {
        $start = [datetime]::Parse($StartTime)
        $end = [datetime]::Parse($EndTime)

        if ($end -lt $start) {
            return "No registrado"
        }

        $duration = $end - $start
        return "{0:00}:{1:00}" -f [int]$duration.TotalHours, $duration.Minutes
    }
    catch {
        return "No registrado"
    }
}

function Append-LogText {
    param(
        [string]$Path,
        [string]$Text
    )

    Add-Content -LiteralPath $Path -Value ""
    Add-Content -LiteralPath $Path -Value $Text
}

function Normalize-GitPath {
    param([string]$Path)

    if ($null -eq $Path) {
        return ""
    }

    return ($Path.Trim().Trim('"') -replace "\\", "/")
}

function Get-NonLogPendingPaths {
    param([string[]]$Paths)

    $allowed = @("WORK_LOG.md", "WEEKLY_REPORT_LOG.md")
    $nonLog = @()

    foreach ($path in @($Paths)) {
        $normalized = Normalize-GitPath -Path $path
        if ($allowed -notcontains $normalized) {
            $nonLog += $normalized
        }
    }

    return @($nonLog | Sort-Object -Unique)
}

function Read-ActiveAssignment {
    param([string]$Path)

    $values = New-Object System.Collections.Hashtable ([System.StringComparer]::OrdinalIgnoreCase)
    $exists = Test-Path -LiteralPath $Path -PathType Leaf

    if (-not $exists) {
        return [pscustomobject]@{
            Exists = $false
            Path   = $Path
            Values = $values
        }
    }

    try {
        $lines = @(Get-Content -LiteralPath $Path -ErrorAction Stop)
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $line = $lines[$i]
            if ($line -notmatch "^\s*-\s*([^:]+):\s*(.*)$") {
                continue
            }

            $key = $Matches[1].Trim()
            $value = $Matches[2].Trim()
            $extra = @()
            $j = $i + 1

            while ($j -lt $lines.Count) {
                $next = $lines[$j]

                if ($next -match "^\s*-\s*[^:]+:\s*") {
                    break
                }

                if ($next -match "^\s*##\s+") {
                    break
                }

                if (-not [string]::IsNullOrWhiteSpace($next)) {
                    $clean = $next.Trim()
                    if ($clean -match "^\-\s+(.+)$") {
                        $clean = $Matches[1].Trim()
                    }

                    $extra += $clean
                }

                $j++
            }

            if ($extra.Count -gt 0) {
                if ([string]::IsNullOrWhiteSpace($value)) {
                    $value = $extra -join "; "
                }
                else {
                    $value = "$value; $($extra -join '; ')"
                }
            }

            $values[$key] = $value
            $i = $j - 1
        }
    }
    catch {
        Write-Host "Advertencia: no se pudo leer ACTIVE_ASSIGNMENT.md: $($_.Exception.Message)"
    }

    return [pscustomobject]@{
        Exists = $true
        Path   = $Path
        Values = $values
    }
}

function Get-AssignmentValue {
    param(
        [pscustomobject]$AssignmentData,
        [string]$Key,
        [string]$DefaultValue
    )

    if ($null -ne $AssignmentData -and $AssignmentData.Values.ContainsKey($Key)) {
        $value = "$($AssignmentData.Values[$Key])".Trim()
        if (-not [string]::IsNullOrWhiteSpace($value)) {
            return $value
        }
    }

    return $DefaultValue
}

function Get-SafeCommitAssignmentName {
    param([string]$Assignment)

    if (-not [string]::IsNullOrWhiteSpace($Assignment)) {
        $match = [regex]::Match($Assignment, "\b[A-Za-z]+-[A-Za-z]*\d+[A-Za-z0-9_-]*\b")
        if ($match.Success) {
            return $match.Value.ToUpperInvariant()
        }
    }

    return "assignment"
}

function Test-ProductionWasModified {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $false
    }

    return $Value.Trim() -match "^(yes|si|sí|true|modificada|modificado|modified)$"
}

function Get-TodaysCommits {
    param([string]$DateText)

    $since = "$DateText 00:00"
    $result = Invoke-LoggedCommand "git log del dia" "git" @("log", "--since=$since", "--oneline", "--decorate") -Quiet

    if ($result.ExitCode -ne 0) {
        return @()
    }

    return @($result.Output | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function New-DailySummary {
    param(
        [string]$AssignmentSummary,
        [string[]]$CommitsToday,
        [string[]]$ChangedFiles
    )

    if (-not [string]::IsNullOrWhiteSpace($AssignmentSummary)) {
        return $AssignmentSummary
    }

    $parts = @()
    $commitLines = @($CommitsToday | Select-Object -First 5)
    $fileLines = @($ChangedFiles | Select-Object -First 10)

    if ($commitLines.Count -gt 0) {
        $parts += "Commits del dia: $($commitLines -join '; ')"
    }

    if ($fileLines.Count -gt 0) {
        $parts += "Archivos modificados/untracked: $($fileLines -join ', ')"
    }

    if ($parts.Count -eq 0) {
        return "Sin commits del dia ni archivos modificados detectados; cierre de seguimiento de la asignacion activa."
    }

    return $parts -join ". "
}

function New-ClosureLogEntries {
    param(
        [string]$DateText,
        [string]$TimeText,
        [string]$Project,
        [string]$Device,
        [string]$Branch,
        [string]$Assignment,
        [string]$Status,
        [string]$ExpectedOrg,
        [string]$CurrentActivity,
        [string]$DailySummary,
        [string]$StartTime,
        [string]$SandboxStatus,
        [string]$ProductionModified,
        [string]$Notes,
        [string[]]$ChangedFiles,
        [string[]]$CommitsToday
    )

    $totalTime = Get-TimeTotalText -StartTime $StartTime -EndTime $TimeText

    $changedFilesForLog = if (@($ChangedFiles).Count -gt 0) {
        @($ChangedFiles) -join ", "
    }
    else {
        "Sin cambios pendientes detectados antes del cierre"
    }

    $commitsForLog = if (@($CommitsToday).Count -gt 0) {
        @($CommitsToday) -join "; "
    }
    else {
        "Sin commits del dia detectados"
    }

    $validations = @(
        "git status -sb",
        "git branch --show-current",
        "git log --oneline --decorate -1",
        "git add WORK_LOG.md WEEKLY_REPORT_LOG.md",
        "git commit",
        "git push",
        "git status -sb final",
        "git log --oneline --decorate -1 final"
    ) -join ", "

    $workLogEntry = @"
## $DateText - $Project - Cierre de trabajo

- Fecha: $DateText
- Equipo: $Device
- Repo: $Project
- Rama: $Branch
- Expected org: $ExpectedOrg
- Hora inicio: $StartTime
- Hora fin: $TimeText
- Asignacion: $Assignment
- Objetivo: Cierre automatico seguro de trabajo.
- Fuente de instruccion: Cierre ejecutado desde scripts/end-work.ps1 -Mode AutoSafe.
- Actividades realizadas:
  - $CurrentActivity
- Resumen diario:
  - $DailySummary
- Comandos relevantes:
  - $validations
- Commits del dia: $commitsForLog
- Archivos modificados antes de logs: $changedFilesForLog
- Sandbox scope/status: $SandboxStatus
- Produccion modificada: $ProductionModified
- Validaciones: Diagnostico Git y cierre automatico seguro ejecutados sin deploy/retrieve/reset/clean.
- Pendientes: Revisar bloqueos de negocio o seguimiento indicado en observaciones.
- Estado final: $Status
- Observaciones: $Notes
"@

    $weeklyRow = "| $(Convert-MarkdownTableValue $DateText) | $(Convert-MarkdownTableValue $Project) | $(Convert-MarkdownTableValue $Device) | $(Convert-MarkdownTableValue $Assignment) | $(Convert-MarkdownTableValue $CurrentActivity) | $(Convert-MarkdownTableValue $DailySummary) | $(Convert-MarkdownTableValue $StartTime) | $(Convert-MarkdownTableValue $TimeText) | $(Convert-MarkdownTableValue $totalTime) | $(Convert-MarkdownTableValue $Status) | $(Convert-MarkdownTableValue $Notes) |"

    return [pscustomobject]@{
        WorkLogEntry = $workLogEntry
        WeeklyRow    = $weeklyRow
    }
}

function Write-BlockedClose {
    param([string[]]$Reasons)

    Write-Host ""
    Write-Host "Cierre automatico bloqueado."
    Write-Host "Motivo:"

    foreach ($reason in @($Reasons)) {
        Write-Host "- $reason"
    }

    Write-Host ""
    Write-Host "No cierres todavia. Comparte este resumen en ChatGPT."
}

function Get-RemoteHeadHash {
    param([string]$Branch)

    if ([string]::IsNullOrWhiteSpace($Branch)) {
        return ""
    }

    $remoteResult = Invoke-LoggedCommand "git ls-remote origin" "git" @("ls-remote", "origin", "refs/heads/$Branch") -Quiet
    if ($remoteResult.ExitCode -eq 0) {
        $line = @($remoteResult.Output | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -First 1)
        if ($line.Count -gt 0 -and $line[0] -match "^([0-9a-fA-F]{7,40})") {
            return $Matches[1].Substring(0, [Math]::Min(7, $Matches[1].Length))
        }
    }

    $localResult = Invoke-LoggedCommand "git rev-parse HEAD" "git" @("rev-parse", "--short", "HEAD") -Quiet
    if ($localResult.ExitCode -eq 0) {
        $hash = @($localResult.Output | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -First 1)
        if ($hash.Count -gt 0) {
            return $hash[0].Trim()
        }
    }

    return "No detectado"
}

function Get-DeviceName {
    param([string]$CurrentPath)

    if ($CurrentPath.IndexOf("C:\Users\Claudia", [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
        return "PC"
    }

    if ($CurrentPath.IndexOf("C:\Users\dokur", [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
        return "Laptop"
    }

    return "Desconocido"
}

function Get-GitDiagnostics {
    Write-Section "Git"

    $statusResult = Invoke-LoggedCommand "git status -sb" "git" @("status", "-sb")
    $branchResult = Invoke-LoggedCommand "git branch --show-current" "git" @("branch", "--show-current")
    $logResult = Invoke-LoggedCommand "git log --oneline --decorate -1" "git" @("log", "--oneline", "--decorate", "-1")

    $branch = "No detectada"
    $lastCommit = "No detectado"

    $branchLine = @(Get-Array ($branchResult.Output | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -First 1))
    if ($branchLine.Count -gt 0) {
        $branch = $branchLine[0]
    }

    $commitLine = @(Get-Array ($logResult.Output | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -First 1))
    if ($commitLine.Count -gt 0) {
        $lastCommit = $commitLine[0]
    }

    $facts = Get-GitFacts -StatusOutput $statusResult.Output

    Write-Section "Resumen Git detectado"
    Write-Host "Rama actual: $branch"
    Write-Host "Ultimo commit: $lastCommit"
    Write-Host "Cambios locales tracked: $(if ($facts.HasLocalChanges) { 'Si' } else { 'No' })"
    Write-Host "Archivos untracked: $(if ($facts.HasUntracked) { 'Si' } else { 'No' })"
    Write-Host "Rama ahead: $(if ($facts.IsAhead) { "Si ($($facts.AheadCount))" } else { 'No' })"
    Write-Host "Rama behind: $(if ($facts.IsBehind) { "Si ($($facts.BehindCount))" } else { 'No' })"

    $paths = @(Get-Array $facts.Paths)
    if ($paths.Count -gt 0) {
        Write-Host "Archivos modificados/untracked: $($paths -join ', ')"
    }
    else {
        Write-Host "Archivos modificados/untracked: Sin archivos pendientes"
    }

    return [pscustomobject]@{
        StatusResult = $statusResult
        BranchResult = $branchResult
        LogResult    = $logResult
        Branch       = $branch
        LastCommit   = $lastCommit
        Facts        = $facts
    }
}

function Invoke-AutoSafeClose {
    $now = Get-Date
    $dateText = $now.ToString("yyyy-MM-dd")
    $timeText = $now.ToString("HH:mm:ss")
    $currentPath = (Get-Location).Path
    $project = "RedMotors"
    $device = Get-DeviceName -CurrentPath $currentPath
    $activeAssignmentPath = Join-Path $currentPath "docs\asignaciones\ACTIVE_ASSIGNMENT.md"
    $assignmentData = Read-ActiveAssignment -Path $activeAssignmentPath

    Write-Section "Cierre de trabajo"
    Write-Host "Modo: Cierre automatico seguro"
    Write-Host "Proyecto: $project"
    Write-Host "Equipo: $device"
    Write-Host "Fecha: $dateText"
    Write-Host "Hora fin: $timeText"
    Write-Host "Ruta: $currentPath"

    if ($assignmentData.Exists) {
        Write-Host "ACTIVE_ASSIGNMENT.md: Detectado"
    }
    else {
        Write-Host "ACTIVE_ASSIGNMENT.md: No detectado; se usaran valores razonables."
    }

    if (-not (Test-Tool "git")) {
        Write-BlockedClose -Reasons @("Git no esta disponible en PATH.")
        return
    }

    if (-not (Test-Path -LiteralPath ".git" -PathType Container)) {
        Write-BlockedClose -Reasons @("La ruta actual no parece ser un repositorio Git.")
        return
    }

    $diagnostics = Get-GitDiagnostics
    $facts = $diagnostics.Facts
    $branch = $diagnostics.Branch

    $assignment = Get-AssignmentValue -AssignmentData $assignmentData -Key "Assignment" -DefaultValue "Asignacion activa no especificada"
    $status = Get-AssignmentValue -AssignmentData $assignmentData -Key "Status" -DefaultValue "En progreso"
    $expectedBranch = Get-AssignmentValue -AssignmentData $assignmentData -Key "Expected branch" -DefaultValue ""
    $expectedOrg = Get-AssignmentValue -AssignmentData $assignmentData -Key "Expected org" -DefaultValue "No registrado"
    $currentActivity = Get-AssignmentValue -AssignmentData $assignmentData -Key "Current activity" -DefaultValue "Trabajo sobre asignacion activa"
    $assignmentSummary = Get-AssignmentValue -AssignmentData $assignmentData -Key "Daily summary" -DefaultValue ""
    $startTime = Get-AssignmentValue -AssignmentData $assignmentData -Key "Start time" -DefaultValue "No registrado"
    $sandboxStatus = Get-AssignmentValue -AssignmentData $assignmentData -Key "Sandbox scope/status" -DefaultValue "Alcance semanal cerrado en Sandbox."
    $productionModified = Get-AssignmentValue -AssignmentData $assignmentData -Key "Production modified" -DefaultValue "No"
    $closureNotes = Get-AssignmentValue -AssignmentData $assignmentData -Key "Closure notes" -DefaultValue ""
    $assignmentNotes = Get-AssignmentValue -AssignmentData $assignmentData -Key "Notes" -DefaultValue ""
    $notes = $closureNotes

    if ([string]::IsNullOrWhiteSpace($notes)) {
        $notes = $assignmentNotes
    }

    if ([string]::IsNullOrWhiteSpace($notes)) {
        $notes = "Produccion no modificada. $sandboxStatus"
    }

    Write-Section "Asignacion activa detectada"
    Write-Host "Assignment: $assignment"
    Write-Host "Status: $status"
    Write-Host "Expected branch: $(if ([string]::IsNullOrWhiteSpace($expectedBranch)) { 'No registrado' } else { $expectedBranch })"
    Write-Host "Expected org: $expectedOrg"
    Write-Host "Current activity: $currentActivity"
    Write-Host "Start time: $startTime"
    Write-Host "Sandbox scope/status: $sandboxStatus"
    Write-Host "Production modified: $productionModified"

    $blockReasons = @()

    if ($diagnostics.StatusResult.ExitCode -ne 0) {
        $blockReasons += "git status -sb fallo con codigo $($diagnostics.StatusResult.ExitCode)."
    }

    if ($diagnostics.BranchResult.ExitCode -ne 0 -or [string]::IsNullOrWhiteSpace($branch) -or $branch -eq "No detectada") {
        $blockReasons += "No se pudo detectar la rama actual."
    }

    if ($diagnostics.LogResult.ExitCode -ne 0) {
        $blockReasons += "git log --oneline --decorate -1 fallo con codigo $($diagnostics.LogResult.ExitCode)."
    }

    if (-not [string]::IsNullOrWhiteSpace($expectedBranch) -and $branch -ne $expectedBranch) {
        $blockReasons += "La rama actual '$branch' no coincide con Expected branch '$expectedBranch'."
    }

    if ($facts.IsBehind) {
        $blockReasons += "La rama esta behind por $($facts.BehindCount) commit(s); requiere revision antes de cerrar."
    }

    if (Test-ProductionWasModified -Value $productionModified) {
        $blockReasons += "ACTIVE_ASSIGNMENT.md indica Production modified: $productionModified."
    }

    $pendingPaths = @(Get-Array $facts.Paths)
    $nonLogPaths = @(Get-NonLogPendingPaths -Paths $pendingPaths)

    if ($nonLogPaths.Count -gt 0) {
        Write-Host ""
        Write-Host "No se puede cerrar automatico porque hay cambios no-log pendientes."
        Write-Host "Revisa con ChatGPT/Codex antes de cerrar."
        Write-Host "Cambios no-log detectados: $($nonLogPaths -join ', ')"
        $blockReasons += "Hay cambios pendientes fuera de WORK_LOG.md y WEEKLY_REPORT_LOG.md."
    }

    if ($blockReasons.Count -gt 0) {
        Write-BlockedClose -Reasons $blockReasons
        return
    }

    if (-not (Test-Path -LiteralPath "WORK_LOG.md" -PathType Leaf)) {
        Write-BlockedClose -Reasons @("No se encontro WORK_LOG.md.")
        return
    }

    if (-not (Test-Path -LiteralPath "WEEKLY_REPORT_LOG.md" -PathType Leaf)) {
        Write-BlockedClose -Reasons @("No se encontro WEEKLY_REPORT_LOG.md.")
        return
    }

    $commitsToday = @(Get-TodaysCommits -DateText $dateText)
    $dailySummary = New-DailySummary -AssignmentSummary $assignmentSummary -CommitsToday $commitsToday -ChangedFiles $pendingPaths
    $entries = New-ClosureLogEntries `
        -DateText $dateText `
        -TimeText $timeText `
        -Project $project `
        -Device $device `
        -Branch $branch `
        -Assignment $assignment `
        -Status $status `
        -ExpectedOrg $expectedOrg `
        -CurrentActivity $currentActivity `
        -DailySummary $dailySummary `
        -StartTime $startTime `
        -SandboxStatus $sandboxStatus `
        -ProductionModified $productionModified `
        -Notes $notes `
        -ChangedFiles $pendingPaths `
        -CommitsToday $commitsToday

    Write-Section "Escritura de logs"
    Append-LogText -Path "WORK_LOG.md" -Text $entries.WorkLogEntry
    Append-LogText -Path "WEEKLY_REPORT_LOG.md" -Text $entries.WeeklyRow
    Write-Host "Entradas agregadas a WORK_LOG.md y WEEKLY_REPORT_LOG.md."

    Write-Section "Validacion despues de escribir logs"
    $statusAfterLogs = Invoke-LoggedCommand "git status -sb despues de logs" "git" @("status", "-sb")
    $factsAfterLogs = Get-GitFacts -StatusOutput $statusAfterLogs.Output
    $pathsAfterLogs = @(Get-Array $factsAfterLogs.Paths)
    $nonLogAfterLogs = @(Get-NonLogPendingPaths -Paths $pathsAfterLogs)

    if ($statusAfterLogs.ExitCode -ne 0) {
        Write-BlockedClose -Reasons @("git status -sb fallo despues de escribir logs.")
        return
    }

    if ($nonLogAfterLogs.Count -gt 0) {
        Write-Host ""
        Write-Host "No se puede cerrar automatico porque hay cambios no-log pendientes."
        Write-Host "Revisa con ChatGPT/Codex antes de cerrar."
        Write-Host "Cambios no-log detectados: $($nonLogAfterLogs -join ', ')"
        Write-BlockedClose -Reasons @("Despues de escribir logs quedaron cambios fuera de WORK_LOG.md y WEEKLY_REPORT_LOG.md.")
        return
    }

    $scope = ($device -replace "[^A-Za-z0-9_-]", "").ToLowerInvariant()
    if ([string]::IsNullOrWhiteSpace($scope)) {
        $scope = "equipo"
    }

    $commitAssignment = Get-SafeCommitAssignmentName -Assignment $assignment
    $commitMessage = "docs($scope): log $commitAssignment closure session"

    Write-Section "Commit y push de logs"
    $addResult = Invoke-LoggedCommand "git add logs" "git" @("add", "WORK_LOG.md", "WEEKLY_REPORT_LOG.md")
    if ($addResult.ExitCode -ne 0) {
        Write-BlockedClose -Reasons @("git add WORK_LOG.md WEEKLY_REPORT_LOG.md fallo.")
        return
    }

    $commitResult = Invoke-LoggedCommand "git commit logs" "git" @("commit", "-m", $commitMessage)
    if ($commitResult.ExitCode -ne 0) {
        Write-BlockedClose -Reasons @("git commit de logs fallo.")
        return
    }

    $pushResult = Invoke-LoggedCommand "git push" "git" @("push")
    if ($pushResult.ExitCode -ne 0) {
        Write-BlockedClose -Reasons @("git push fallo; no cierres hasta revisar sincronizacion remota.")
        return
    }

    Write-Section "Verificacion despues del push"
    $finalStatusResult = Invoke-LoggedCommand "git status -sb final" "git" @("status", "-sb")
    $finalLogResult = Invoke-LoggedCommand "git log --oneline --decorate -1 final" "git" @("log", "--oneline", "--decorate", "-1")
    $finalFacts = Get-GitFacts -StatusOutput $finalStatusResult.Output

    if ($finalStatusResult.ExitCode -ne 0 -or $finalLogResult.ExitCode -ne 0) {
        Write-BlockedClose -Reasons @("La verificacion final Git fallo despues del push.")
        return
    }

    if ($finalFacts.HasPendingCommit -or $finalFacts.IsAhead -or $finalFacts.IsBehind) {
        Write-BlockedClose -Reasons @("El repo no quedo limpio y sincronizado despues del push.")
        return
    }

    $remoteHash = Get-RemoteHeadHash -Branch $branch

    Write-Host ""
    Write-Host "Cierre completo."
    Write-Host ""
    Write-Host "Repo limpio y sincronizado."
    Write-Host "Ultimo commit remoto: $remoteHash"
    Write-Host "Produccion no modificada."
    Write-Host $sandboxStatus
    Write-Host "Logs de cierre guardados y pusheados."
    Write-Host ""
    Write-Host "Ya puedes cerrar VS Code, PowerShell y Salesforce."
}

function Read-ValueWithDefault {
    param(
        [string]$Prompt,
        [string]$DefaultValue
    )

    $promptText = if ([string]::IsNullOrWhiteSpace($DefaultValue)) {
        $Prompt
    }
    else {
        "$Prompt [$DefaultValue]"
    }

    $value = Read-Host $promptText
    if ([string]::IsNullOrWhiteSpace($value)) {
        if ([string]::IsNullOrWhiteSpace($DefaultValue)) {
            return "No especificado"
        }

        return $DefaultValue
    }

    return $value.Trim()
}

function Show-TextBlock {
    param(
        [string]$Title,
        [string]$Text
    )

    Write-Section $Title
    Write-Host $Text
}

function Invoke-ManualClose {
    $now = Get-Date
    $dateText = $now.ToString("yyyy-MM-dd")
    $timeText = $now.ToString("HH:mm:ss")
    $currentPath = (Get-Location).Path
    $project = "RedMotors"
    $device = Get-DeviceName -CurrentPath $currentPath
    $assignmentData = Read-ActiveAssignment -Path (Join-Path $currentPath "docs\asignaciones\ACTIVE_ASSIGNMENT.md")

    Write-Section "Cierre de trabajo"
    Write-Host "Modo: Cierre manual / corregir datos"
    Write-Host "Proyecto: $project"
    Write-Host "Equipo: $device"
    Write-Host "Fecha: $dateText"
    Write-Host "Hora fin: $timeText"
    Write-Host "Ruta: $currentPath"

    $gitAvailable = Test-Tool "git"
    $branch = "No detectada"
    $facts = [pscustomobject]@{
        Paths              = @()
        HasPendingCommit   = $false
        HasPendingPush     = $false
        HasForceAppChanges = $false
    }

    if ($gitAvailable -and (Test-Path -LiteralPath ".git" -PathType Container)) {
        $diagnostics = Get-GitDiagnostics
        $branch = $diagnostics.Branch
        $facts = $diagnostics.Facts
    }
    else {
        Write-Host "Git no esta disponible o la ruta actual no parece ser repositorio Git."
    }

    $assignmentDefault = Get-AssignmentValue -AssignmentData $assignmentData -Key "Assignment" -DefaultValue "No especificado"
    $activityDefault = Get-AssignmentValue -AssignmentData $assignmentData -Key "Current activity" -DefaultValue "Trabajo sobre asignacion activa"
    $summaryDefault = Get-AssignmentValue -AssignmentData $assignmentData -Key "Daily summary" -DefaultValue "Cierre manual de asignacion activa."
    $startTimeDefault = Get-AssignmentValue -AssignmentData $assignmentData -Key "Start time" -DefaultValue "No registrado"
    $statusDefault = Get-AssignmentValue -AssignmentData $assignmentData -Key "Status" -DefaultValue "En progreso"
    $sandboxDefault = Get-AssignmentValue -AssignmentData $assignmentData -Key "Sandbox scope/status" -DefaultValue "Alcance semanal cerrado en Sandbox."
    $productionDefault = Get-AssignmentValue -AssignmentData $assignmentData -Key "Production modified" -DefaultValue "No"
    $notesDefault = Get-AssignmentValue -AssignmentData $assignmentData -Key "Closure notes" -DefaultValue ""

    if ([string]::IsNullOrWhiteSpace($notesDefault)) {
        $notesDefault = Get-AssignmentValue -AssignmentData $assignmentData -Key "Notes" -DefaultValue "Sin observaciones adicionales"
    }

    $assignment = Read-ValueWithDefault "Asignacion" $assignmentDefault
    $activity = Read-ValueWithDefault "Actividad" $activityDefault
    $description = Read-ValueWithDefault "Descripcion corta" $summaryDefault
    $startTime = Read-ValueWithDefault "Hora inicio" $startTimeDefault
    $status = Read-ValueWithDefault "Estado" $statusDefault
    $notes = Read-ValueWithDefault "Observaciones" $notesDefault
    $sandboxStatus = Read-ValueWithDefault "Sandbox scope/status" $sandboxDefault
    $productionModified = Read-ValueWithDefault "Production modified" $productionDefault
    $expectedOrg = Get-AssignmentValue -AssignmentData $assignmentData -Key "Expected org" -DefaultValue "No registrado"
    $totalTime = Get-TimeTotalText -StartTime $startTime -EndTime $timeText

    $factPaths = @(Get-Array $facts.Paths)
    $changedFilesForLog = if ($factPaths.Count -gt 0) {
        $factPaths -join ", "
    }
    else {
        "Sin cambios detectados"
    }

    $validations = @(
        "git status -sb",
        "git branch --show-current",
        "git log --oneline --decorate -1"
    ) -join ", "

    $workLogEntry = @"
## $dateText - $project - Cierre de trabajo

- Fecha: $dateText
- Equipo: $device
- Repo: $project
- Rama: $branch
- Expected org: $expectedOrg
- Hora inicio: $startTime
- Hora fin: $timeText
- Asignacion: $assignment
- Objetivo: Cierre operativo de trabajo.
- Fuente de instruccion: Cierre ejecutado desde scripts/end-work.ps1 -Mode Manual.
- Actividades realizadas:
  - $activity
- Resumen diario:
  - $description
- Comandos relevantes:
  - $validations
- Archivos modificados: $changedFilesForLog
- Sandbox scope/status: $sandboxStatus
- Produccion modificada: $productionModified
- Validaciones: Diagnostico de cierre Git ejecutado sin deploy/retrieve.
- Pendientes: $(if ($facts.HasPendingCommit -or $facts.HasPendingPush) { 'Revisar commit/push pendiente.' } else { 'Sin pendientes Git detectados.' })
- Estado final: $status
- Observaciones: $notes
"@

    $weeklyRow = "| $(Convert-MarkdownTableValue $dateText) | $(Convert-MarkdownTableValue $project) | $(Convert-MarkdownTableValue $device) | $(Convert-MarkdownTableValue $assignment) | $(Convert-MarkdownTableValue $activity) | $(Convert-MarkdownTableValue $description) | $(Convert-MarkdownTableValue $startTime) | $(Convert-MarkdownTableValue $timeText) | $(Convert-MarkdownTableValue $totalTime) | $(Convert-MarkdownTableValue $status) | $(Convert-MarkdownTableValue $notes) |"

    Show-TextBlock -Title "Entrada propuesta para WORK_LOG.md" -Text $workLogEntry
    Show-TextBlock -Title "Fila propuesta para WEEKLY_REPORT_LOG.md" -Text $weeklyRow

    $confirmWrite = Read-Host "Confirmas escribir estas entradas en los logs? (S/N)"
    if ($confirmWrite -notmatch "^[sS]$") {
        Write-Host "No se modificaron archivos de log."
        return
    }

    if (-not (Test-Path -LiteralPath "WORK_LOG.md" -PathType Leaf)) {
        Write-Host "No se encontro WORK_LOG.md. No se escribieron logs."
        return
    }

    if (-not (Test-Path -LiteralPath "WEEKLY_REPORT_LOG.md" -PathType Leaf)) {
        Write-Host "No se encontro WEEKLY_REPORT_LOG.md. No se escribieron logs."
        return
    }

    Append-LogText -Path "WORK_LOG.md" -Text $workLogEntry
    Append-LogText -Path "WEEKLY_REPORT_LOG.md" -Text $weeklyRow
    Write-Host "Entradas agregadas a WORK_LOG.md y WEEKLY_REPORT_LOG.md."
    Write-Host "No se hizo git add, commit ni push en modo manual."
}

if ($Mode -eq "Manual") {
    Invoke-ManualClose
}
else {
    Invoke-AutoSafeClose
}
