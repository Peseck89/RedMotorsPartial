<#
RedMotors pause-work diagnostic script.

Safety rules:
- Diagnostics only.
- No Salesforce metadata changes.
- No deploy, retrieve, reset, clean, add, commit, push, pull, or automatic fix.
- Suggested Git commands are printed only; they are never executed here.
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

function Invoke-GitCapture {
    param([string[]]$Arguments)

    try {
        $global:LASTEXITCODE = $null
        $output = @(& git @Arguments 2>&1 | ForEach-Object { "$_" })
        $exitCode = if ($null -ne $global:LASTEXITCODE) {
            [int]$global:LASTEXITCODE
        }
        else {
            0
        }

        return [pscustomobject]@{
            ExitCode = $exitCode
            Output   = $output
        }
    }
    catch {
        return [pscustomobject]@{
            ExitCode = 1
            Output   = @("No se pudo ejecutar git $($Arguments -join ' '): $($_.Exception.Message)")
        }
    }
}

function Write-LinesOrEmpty {
    param(
        [string[]]$Lines,
        [string]$EmptyText = "(sin salida)"
    )

    $items = @($Lines)
    if ($items.Count -eq 0) {
        Write-Host $EmptyText
        return
    }

    foreach ($line in $items) {
        Write-Host $line
    }
}

function Get-ExpectedBranch {
    param([string]$RepoPath)

    $activeAssignmentPath = Join-Path $RepoPath "docs\asignaciones\ACTIVE_ASSIGNMENT.md"
    if (-not (Test-Path -LiteralPath $activeAssignmentPath -PathType Leaf)) {
        return ""
    }

    try {
        $line = @(Get-Content -LiteralPath $activeAssignmentPath -ErrorAction Stop | Where-Object {
                $_ -match "^\s*-\s*Expected branch\s*:\s*(.+?)\s*$"
            } | Select-Object -First 1)

        if ($line.Count -gt 0 -and $line[0] -match "^\s*-\s*Expected branch\s*:\s*(.+?)\s*$") {
            return $Matches[1].Trim()
        }
    }
    catch {
        Write-Host "Advertencia: no se pudo leer ACTIVE_ASSIGNMENT.md."
    }

    return ""
}

function Get-StatusLine {
    param([string[]]$Lines)

    $line = @($Lines | Where-Object { $_ -like "## *" } | Select-Object -First 1)
    if ($line.Count -eq 0) {
        return ""
    }

    return $line[0]
}

function Get-AffectedPath {
    param([string]$StatusLine)

    if ([string]::IsNullOrWhiteSpace($StatusLine) -or $StatusLine.Length -lt 4) {
        return ""
    }

    $path = $StatusLine.Substring(3).Trim()
    if ($path -match "\s->\s(.+)$") {
        return $Matches[1].Trim()
    }

    return $path
}

function Format-GitPath {
    param([string]$Path)

    return '"' + ($Path -replace '"', '\"') + '"'
}

$now = Get-Date
$dateText = $now.ToString("yyyy-MM-dd")
$timeText = $now.ToString("HH:mm:ss")
$currentPath = (Get-Location).Path

$device = "Desconocido"
if ($currentPath.IndexOf("C:\Users\Claudia", [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
    $device = "PC"
}
elseif ($currentPath.IndexOf("C:\Users\dokur", [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
    $device = "Laptop"
}

Write-Section "Pausa / cambio de equipo"
Write-Host "Proyecto: RedMotors"
Write-Host "Equipo: $device"
Write-Host "Fecha: $dateText"
Write-Host "Hora: $timeText"
Write-Host "Ruta: $currentPath"

if (-not (Test-Tool "git")) {
    Write-Host ""
    Write-Host "Git no esta disponible en PATH. No cambies de equipo todavia."
    return
}

if (-not (Test-Path -LiteralPath (Join-Path $currentPath ".git"))) {
    Write-Host ""
    Write-Host "La ruta actual no parece ser un repositorio Git. No cambies de equipo todavia."
    return
}

$expectedBranch = Get-ExpectedBranch -RepoPath $currentPath
$branchResult = Invoke-GitCapture @("branch", "--show-current")
$lastCommitResult = Invoke-GitCapture @("log", "--oneline", "--decorate", "-1")
$statusResult = Invoke-GitCapture @("status", "-sb")
$porcelainResult = Invoke-GitCapture @("status", "--porcelain=v1")
$diffStatResult = Invoke-GitCapture @("diff", "--stat")
$diffNameResult = Invoke-GitCapture @("diff", "--name-only")

$branch = @($branchResult.Output | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -First 1)
$currentBranch = if ($branch.Count -gt 0) { $branch[0] } else { "No detectada" }
$lastCommit = @($lastCommitResult.Output | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -First 1)
$lastCommitText = if ($lastCommit.Count -gt 0) { $lastCommit[0] } else { "No detectado" }

$statusLine = Get-StatusLine -Lines $statusResult.Output
$aheadCount = 0
$behindCount = 0
if ($statusLine -match "ahead\s+(\d+)") {
    $aheadCount = [int]$Matches[1]
}
if ($statusLine -match "behind\s+(\d+)") {
    $behindCount = [int]$Matches[1]
}

$statusBody = @($porcelainResult.Output | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
$untrackedLines = @($statusBody | Where-Object { $_ -match "^\?\?\s+" })
$hasLocalChanges = $statusBody.Count -gt 0
$hasUntracked = $untrackedLines.Count -gt 0
$isAhead = $aheadCount -gt 0
$isBehind = $behindCount -gt 0
$affectedFiles = @($statusBody | ForEach-Object { Get-AffectedPath $_ } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique)

Write-Section "Asignacion activa"
if (-not [string]::IsNullOrWhiteSpace($expectedBranch)) {
    Write-Host "Rama esperada: $expectedBranch"
}
else {
    Write-Host "Rama esperada: No detectada"
}

Write-Section "Git"
Write-Host "Rama actual: $currentBranch"
Write-Host "Ultimo commit: $lastCommitText"

Write-Host ""
Write-Host "git status -sb:"
Write-LinesOrEmpty -Lines $statusResult.Output

Write-Host ""
Write-Host "git diff --stat:"
Write-LinesOrEmpty -Lines $diffStatResult.Output

Write-Host ""
Write-Host "git diff --name-only:"
Write-LinesOrEmpty -Lines $diffNameResult.Output

Write-Section "Diagnostico"
Write-Host "Ahead: $(if ($isAhead) { "Si ($aheadCount)" } else { "No" })"
Write-Host "Behind: $(if ($isBehind) { "Si ($behindCount)" } else { "No" })"
Write-Host "Cambios locales: $(if ($hasLocalChanges) { "Si" } else { "No" })"
Write-Host "Untracked: $(if ($hasUntracked) { "Si" } else { "No" })"

if ($affectedFiles.Count -gt 0) {
    Write-Host ""
    Write-Host "Archivos afectados:"
    foreach ($file in $affectedFiles) {
        Write-Host "- $file"
    }
}

Write-Section "Resultado"

if (-not $hasLocalChanges -and -not $isAhead -and -not $isBehind) {
    Write-Host "LISTO PARA CAMBIAR DE EQUIPO"
    Write-Host "Puedes continuar en la otra maquina con: DevLaunchpad -> Continuar asignacion activa -> RedMotors"
    return
}

if ($isAhead) {
    Write-Host "Falta push antes de cambiar de equipo."
    Write-Host "Sugerencia:"
    Write-Host "git push"
}

if ($isBehind) {
    Write-Host "La rama esta behind. No cambies de equipo hasta revisar pull/merge."
}

if ($hasLocalChanges) {
    Write-Host ""
    $answer = Read-Host "Hay cambios sin guardar en Git. ¿Deseas preparar un commit de pausa? (S/N)"

    if ($answer -match "^[sS]$") {
        $deviceSlug = switch ($device) {
            "PC" { "pc" }
            "Laptop" { "laptop" }
            default { "device" }
        }
        $addTargets = if ($affectedFiles.Count -gt 0) {
            ($affectedFiles | ForEach-Object { Format-GitPath $_ }) -join " "
        }
        else {
            "<archivos>"
        }

        Write-Host ""
        Write-Host "Comandos sugeridos:"
        Write-Host "git add -- $addTargets"
        Write-Host "git commit -m `"wip($deviceSlug): pause RedMotors work before switching device`""
        Write-Host "git push"
        Write-Host ""
        Write-Host "Ejecuta estos comandos solo si ya revisaste el diff."
    }
    else {
        Write-Host ""
        Write-Host "No cambies de equipo todavia. Revisa cambios con Codex o haz commit/push antes de salir."
    }
}
elseif ($isAhead) {
    Write-Host ""
    Write-Host "No cambies de equipo todavia. Haz push o revisa la rama antes de salir."
}
elseif ($isBehind) {
    Write-Host ""
    Write-Host "No cambies de equipo todavia. Revisa pull/merge con Codex o ChatGPT antes de salir."
}
