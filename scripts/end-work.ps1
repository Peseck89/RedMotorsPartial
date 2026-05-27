<#
RedMotors end-work diagnostic script.

Safety rules:
- Diagnostics and optional log append only.
- No deploy, retrieve, git reset, git clean, git add, commit, push, or pull.
- If force-app changed, review with Codex before commit.
#>

[CmdletBinding()]
param()

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

function Invoke-DiagnosticCommand {
    param(
        [string]$Label,
        [string]$FilePath,
        [string[]]$ArgumentList = @()
    )

    $commandText = if ($ArgumentList.Count -gt 0) {
        "$FilePath $($ArgumentList -join ' ')"
    }
    else {
        $FilePath
    }

    Write-Host ""
    Write-Host "> $commandText"

    try {
        $global:LASTEXITCODE = $null
        $output = & $FilePath @ArgumentList 2>&1
        $lines = @($output | ForEach-Object { "$_" })

        foreach ($line in $lines) {
            Write-Host $line
        }

        $exitCode = if ($null -ne $global:LASTEXITCODE) {
            [int]$global:LASTEXITCODE
        }
        else {
            0
        }

        if ($exitCode -ne 0) {
            Write-Host "Advertencia: $Label fallo con codigo $exitCode."
        }

        return [pscustomobject]@{
            ExitCode = $exitCode
            Output   = $lines
        }
    }
    catch {
        Write-Host "Advertencia: $Label no se pudo ejecutar: $($_.Exception.Message)"
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

function Get-Array {
    param([object]$Value)

    if ($null -eq $Value) {
        return @()
    }

    return @($Value)
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

    return [pscustomobject]@{
        StatusLine          = $statusLine
        StatusBody          = @($statusBody)
        Paths               = @($paths)
        HasLocalChanges     = $trackedChangeLines.Count -gt 0
        HasUntracked        = $untrackedLines.Count -gt 0
        IsAhead             = $statusLine -match "ahead\s+\d+"
        IsBehind            = $statusLine -match "behind\s+\d+"
        HasPendingCommit    = $statusBody.Count -gt 0
        HasPendingPush      = $statusLine -match "ahead\s+\d+"
        HasForceAppChanges  = $forceAppChanges.Count -gt 0
    }
}

function Read-RequiredValue {
    param([string]$Prompt)

    $value = Read-Host $Prompt
    if ([string]::IsNullOrWhiteSpace($value)) {
        return "No especificado"
    }

    return $value.Trim()
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

    try {
        $start = [datetime]::Parse($StartTime)
        $end = [datetime]::Parse($EndTime)

        if ($end -lt $start) {
            return ""
        }

        $duration = $end - $start
        return "{0:00}:{1:00}" -f [int]$duration.TotalHours, $duration.Minutes
    }
    catch {
        return ""
    }
}

function Show-TextBlock {
    param(
        [string]$Title,
        [string]$Text
    )

    Write-Section $Title
    Write-Host $Text
}

function Append-LogText {
    param(
        [string]$Path,
        [string]$Text
    )

    Add-Content -LiteralPath $Path -Value ""
    Add-Content -LiteralPath $Path -Value $Text
}

$now = Get-Date
$dateText = $now.ToString("yyyy-MM-dd")
$timeText = $now.ToString("HH:mm:ss")
$currentPath = (Get-Location).Path
$project = "RedMotors"

$device = "Desconocido"
if ($currentPath.IndexOf("C:\Users\Claudia", [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
    $device = "PC"
}
elseif ($currentPath.IndexOf("C:\Users\dokur", [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
    $device = "Laptop"
}

Write-Section "Cierre de trabajo"
Write-Host "Proyecto: $project"
Write-Host "Equipo: $device"
Write-Host "Fecha: $dateText"
Write-Host "Hora fin: $timeText"
Write-Host "Ruta: $currentPath"

$gitAvailable = Test-Tool "git"
$statusResult = $null
$branchResult = $null
$diffStatResult = $null
$diffNameResult = $null
$logResult = $null
$branch = "No detectada"
$lastCommit = "No detectado"
$facts = [pscustomobject]@{
    StatusLine         = ""
    StatusBody         = @()
    Paths              = @()
    HasLocalChanges    = $false
    HasUntracked       = $false
    IsAhead            = $false
    IsBehind           = $false
    HasPendingCommit   = $false
    HasPendingPush     = $false
    HasForceAppChanges = $false
}

Write-Section "Git"
if (-not $gitAvailable) {
    Write-Host "Git no esta disponible en PATH."
}
elseif (-not (Test-Path -LiteralPath ".git")) {
    Write-Host "La ruta actual no parece ser un repositorio Git."
}
else {
    $statusResult = Invoke-DiagnosticCommand "git status -sb" "git" @("status", "-sb")
    $branchResult = Invoke-DiagnosticCommand "git branch --show-current" "git" @("branch", "--show-current")
    $diffStatResult = Invoke-DiagnosticCommand "git diff --stat" "git" @("diff", "--stat")
    $diffNameResult = Invoke-DiagnosticCommand "git diff --name-only" "git" @("diff", "--name-only")
    $logResult = Invoke-DiagnosticCommand "git log --oneline --decorate -1" "git" @("log", "--oneline", "--decorate", "-1")

    $branchLine = @(Get-Array ($branchResult.Output | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -First 1))
    if ($branchLine.Count -gt 0) {
        $branch = $branchLine[0]
    }

    $commitLine = @(Get-Array ($logResult.Output | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -First 1))
    if ($commitLine.Count -gt 0) {
        $lastCommit = $commitLine[0]
    }

    $facts = Get-GitFacts -StatusOutput $statusResult.Output
}

Write-Section "Resumen Git detectado"
Write-Host "Rama actual: $branch"
Write-Host "Ultimo commit: $lastCommit"
Write-Host "Cambios locales: $(if ($facts.HasLocalChanges) { 'Si' } else { 'No' })"
Write-Host "Archivos untracked: $(if ($facts.HasUntracked) { 'Si' } else { 'No' })"
Write-Host "Rama ahead: $(if ($facts.IsAhead) { 'Si' } else { 'No' })"
Write-Host "Rama behind: $(if ($facts.IsBehind) { 'Si' } else { 'No' })"
Write-Host "Pendiente de commit: $(if ($facts.HasPendingCommit) { 'Si' } else { 'No' })"
Write-Host "Pendiente de push: $(if ($facts.HasPendingPush) { 'Si' } else { 'No' })"

$logsWereWritten = $false
$prepareLogs = Read-Host "Deseas preparar entrada para WORK_LOG.md y WEEKLY_REPORT_LOG.md? (S/N)"
if ($prepareLogs -match "^[sS]$") {
    $assignment = Read-RequiredValue "Asignacion"
    $activity = Read-RequiredValue "Actividad"
    $description = Read-RequiredValue "Descripcion corta"
    $startTime = Read-RequiredValue "Hora inicio"
    $status = Read-RequiredValue "Estado"
    $notes = Read-RequiredValue "Observaciones"
    $totalTime = Get-TimeTotalText -StartTime $startTime -EndTime $timeText

    $factPaths = @(Get-Array $facts.Paths)
    $changedFilesForLog = if ($factPaths.Count -gt 0) {
        ($factPaths -join ", ")
    }
    else {
        "Sin cambios detectados"
    }

    $validations = @(
        "git status -sb",
        "git branch --show-current",
        "git diff --stat",
        "git diff --name-only",
        "git log --oneline --decorate -1"
    ) -join ", "

    $workLogEntry = @"
## $dateText - $project - Cierre de trabajo

- Fecha: $dateText
- Equipo: $device
- Repo: $project
- Rama: $branch
- Hora inicio: $startTime
- Hora fin: $timeText
- Asignacion: $assignment
- Objetivo: Cierre operativo de trabajo.
- Fuente de instruccion: Cierre ejecutado desde scripts/end-work.ps1.
- Actividades realizadas:
  - $activity
- Comandos relevantes:
  - $validations
- Archivos modificados: $changedFilesForLog
- Validaciones: Diagnostico de cierre Git ejecutado sin deploy/retrieve.
- Pendientes: $(if ($facts.HasPendingCommit -or $facts.HasPendingPush) { 'Revisar commit/push pendiente.' } else { 'Sin pendientes Git detectados.' })
- Estado final: $status
- Observaciones: $notes
"@

    $weeklyRow = "| $(Convert-MarkdownTableValue $dateText) | $(Convert-MarkdownTableValue $project) | $(Convert-MarkdownTableValue $device) | $(Convert-MarkdownTableValue $assignment) | $(Convert-MarkdownTableValue $activity) | $(Convert-MarkdownTableValue $description) | $(Convert-MarkdownTableValue $startTime) | $(Convert-MarkdownTableValue $timeText) | $(Convert-MarkdownTableValue $totalTime) | $(Convert-MarkdownTableValue $status) | $(Convert-MarkdownTableValue $notes) |"

    Show-TextBlock -Title "Entrada propuesta para WORK_LOG.md" -Text $workLogEntry
    Show-TextBlock -Title "Fila propuesta para WEEKLY_REPORT_LOG.md" -Text $weeklyRow

    $confirmWrite = Read-Host "Confirmas escribir estas entradas en los logs? (S/N)"
    if ($confirmWrite -match "^[sS]$") {
        if (-not (Test-Path -LiteralPath "WORK_LOG.md")) {
            Write-Host "No se encontro WORK_LOG.md. No se escribieron logs."
        }
        elseif (-not (Test-Path -LiteralPath "WEEKLY_REPORT_LOG.md")) {
            Write-Host "No se encontro WEEKLY_REPORT_LOG.md. No se escribieron logs."
        }
        else {
            Append-LogText -Path "WORK_LOG.md" -Text $workLogEntry
            Append-LogText -Path "WEEKLY_REPORT_LOG.md" -Text $weeklyRow
            $logsWereWritten = $true
            Write-Host "Entradas agregadas a WORK_LOG.md y WEEKLY_REPORT_LOG.md."
            Write-Host "No se hizo git add, commit ni push."
        }
    }
    else {
        Write-Host "No se modificaron archivos de log."
    }
}
else {
    Write-Host "No se prepararon entradas de log."
}

if ($logsWereWritten -and $gitAvailable -and (Test-Path -LiteralPath ".git")) {
    Write-Section "Estado Git despues de escribir logs"
    $finalStatusResult = Invoke-DiagnosticCommand "git status -sb final" "git" @("status", "-sb")
    $facts = Get-GitFacts -StatusOutput $finalStatusResult.Output
}

$factPaths = @(Get-Array $facts.Paths)
$modifiedFiles = if ($factPaths.Count -gt 0) {
    $factPaths -join ", "
}
else {
    "Sin archivos modificados detectados"
}

$recommendation = "Repo limpio; puedes cerrar."
if ($facts.HasForceAppChanges) {
    $recommendation = "Hay cambios en force-app; revisar con Codex antes de commit."
}
elseif ($facts.HasPendingCommit -or $facts.HasPendingPush) {
    $recommendation = "Hacer commit y push antes de cerrar"
}

Write-Section "Resumen final"
Write-Host "Archivos modificados: $modifiedFiles"
Write-Host "Falta commit: $(if ($facts.HasPendingCommit) { 'Si' } else { 'No' })"
Write-Host "Falta push: $(if ($facts.HasPendingPush) { 'Si' } else { 'No' })"
Write-Host "Recomendacion: $recommendation"

Write-Host ""
Write-Host "Importante:"
Write-Host "- No hacer deploy/retrieve desde este script."
Write-Host "- No hacer reset/clean."
Write-Host "- Si hay cambios en force-app, revisar con Codex antes de commit."
