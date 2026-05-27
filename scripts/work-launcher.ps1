<#
General work launcher for local operating modes.

Safety rules:
- Diagnostics and navigation only.
- No deploy, retrieve, git reset, git clean, automatic pull, push, or file edits.
- RedMotors can delegate diagnostics to scripts/start-work.ps1.
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

function Get-UserPath {
    $path = [Environment]::GetFolderPath("UserProfile")

    if ([string]::IsNullOrWhiteSpace($path)) {
        $path = $env:USERPROFILE
    }

    if ([string]::IsNullOrWhiteSpace($path)) {
        $path = (Get-Location).Path
    }

    return $path
}

function Get-LauncherEnvironment {
    $userPath = Get-UserPath
    $device = "Desconocido"
    $baseRepos = $null
    $redMotorsPath = $null
    $alticaPath = $null

    if ($userPath.IndexOf("C:\Users\Claudia", [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
        $device = "PC"
        $baseRepos = "C:\Users\Claudia\Documents\Repositorios"
        $redMotorsPath = "C:\Users\Claudia\Documents\Repositorios\RedMotorsPartial-Sandbox"
        $alticaPath = "C:\Users\Claudia\Documents\Repositorios\Altica"
    }
    elseif ($userPath.IndexOf("C:\Users\dokur", [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
        $device = "Laptop"
        $baseRepos = "C:\Users\dokur\Documents\Repositorios"
        $redMotorsPath = "C:\Users\dokur\Documents\Repositorios\RedMotorsPartial-Sandbox"
        $alticaPath = "C:\Users\dokur\Documents\Repositorios\Altica"
    }

    return [pscustomobject]@{
        UserPath      = $userPath
        Device        = $device
        BaseRepos     = $baseRepos
        RedMotorsPath = $redMotorsPath
        AlticaPath    = $alticaPath
    }
}

function Write-Section {
    param([string]$Title)

    Write-Host ""
    Write-Host "=== $Title ==="
}

function Test-Folder {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $false
    }

    return Test-Path -LiteralPath $Path -PathType Container
}

function Test-File {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $false
    }

    return Test-Path -LiteralPath $Path -PathType Leaf
}

function Write-LimitedOutput {
    param(
        [string[]]$Lines,
        [int]$Limit = 25
    )

    $items = @($Lines)
    foreach ($line in @($items | Select-Object -First $Limit)) {
        Write-Host $line
    }

    if ($items.Count -gt $Limit) {
        Write-Host "... salida truncada: $($items.Count - $Limit) lineas adicionales."
    }
}

function Invoke-GitQuickReview {
    param(
        [string]$ProjectName,
        [string]$RepoPath
    )

    Write-Section $ProjectName

    if (-not (Test-Folder $RepoPath)) {
        Write-Host "Carpeta: No existe"
        Write-Host "Ruta esperada: $RepoPath"
        return
    }

    Write-Host "Carpeta: OK"
    Write-Host "Ruta: $RepoPath"

    Push-Location -LiteralPath $RepoPath
    try {
        if (-not (Test-Path -LiteralPath ".git")) {
            Write-Host ".git: FALTA"
            return
        }

        Write-Host ".git: OK"

        if ($null -eq (Get-Command "git" -ErrorAction SilentlyContinue)) {
            Write-Host "Git: no disponible en PATH"
            return
        }

        $branchOutput = @(& git branch --show-current 2>&1 | ForEach-Object { "$_" })
        $statusOutput = @(& git status -sb 2>&1 | ForEach-Object { "$_" })

        $branch = @($branchOutput | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -First 1)
        if ($branch.Count -gt 0) {
            Write-Host "Rama: $($branch[0])"
        }
        else {
            Write-Host "Rama: No detectada"
        }

        Write-Host "git status -sb:"
        Write-LimitedOutput -Lines $statusOutput -Limit 25
    }
    finally {
        Pop-Location
    }
}

function Open-VsCodeIfRequested {
    $answer = Read-Host "Deseas abrir VS Code ahora? (S/N)"

    if ($answer -match "^[sS]$") {
        if ($null -eq (Get-Command "code" -ErrorAction SilentlyContinue)) {
            Write-Host "No se encontro el comando code en PATH. Abre VS Code manualmente si lo necesitas."
            return
        }

        Write-Host "Abriendo VS Code con: code ."
        & code .
    }
    else {
        Write-Host "No se abrio VS Code."
    }
}

function Start-RedMotorsWork {
    param([string]$RepoPath)

    Write-Section "RedMotors"

    if (-not (Test-Folder $RepoPath)) {
        Write-Host "RedMotors no existe en la ruta esperada:"
        Write-Host $RepoPath
        return
    }

    $startWorkPath = Join-Path $RepoPath "scripts\start-work.ps1"
    if (-not (Test-File $startWorkPath)) {
        Write-Host "No se encontro scripts/start-work.ps1 en RedMotors."
        Write-Host "Ruta revisada: $startWorkPath"
        return
    }

    Push-Location -LiteralPath $RepoPath
    try {
        Write-Host "Ejecutando diagnostico RedMotors:"
        Write-Host ".\scripts\start-work.ps1"
        & ".\scripts\start-work.ps1"

        Write-Host ""
        Write-Host "Sugerencia para abrir VS Code:"
        Write-Host "code ."
        Open-VsCodeIfRequested
    }
    finally {
        Pop-Location
    }
}

function Start-AlticaWork {
    param([string]$RepoPath)

    Write-Section "Altica"

    if (-not (Test-Folder $RepoPath)) {
        Write-Host "Altica todavia no esta configurado en este equipo."
        Write-Host "Ruta esperada: $RepoPath"
        return
    }

    $startWorkPath = Join-Path $RepoPath "scripts\start-work.ps1"
    if (-not (Test-File $startWorkPath)) {
        Write-Host "Altica existe, pero aun no tiene script start-work.ps1."
        Write-Host "Ruta revisada: $startWorkPath"
        return
    }

    Write-Host "Altica tiene script start-work.ps1, pero este launcher todavia no lo ejecuta."
    Write-Host "Primero se debe validar el protocolo especifico de Altica."
}

function Show-WorkProjectMenu {
    param([pscustomobject]$Environment)

    Write-Section "Proyecto"
    Write-Host "En que proyecto vamos a trabajar?"
    Write-Host ""
    Write-Host "1. RedMotors"
    Write-Host "2. Altica"
    Write-Host "3. Otro / nueva empresa"
    Write-Host "4. Cancelar"
    Write-Host ""

    $projectChoice = Read-Host "Selecciona una opcion (1-4)"

    switch ($projectChoice) {
        "1" {
            Start-RedMotorsWork -RepoPath $Environment.RedMotorsPath
        }
        "2" {
            Start-AlticaWork -RepoPath $Environment.AlticaPath
        }
        "3" {
            Write-Host "Proyecto nuevo pendiente de configurar. Primero se debe crear ruta, aliases Salesforce y contexto IA."
        }
        "4" {
            Write-Host "Operacion cancelada."
        }
        default {
            Write-Host "Opcion no reconocida. No se ejecuto ninguna accion."
        }
    }
}

function Show-QuickReview {
    param([pscustomobject]$Environment)

    Write-Section "Revision rapida"
    Write-Host "No se hara fetch, pull, push ni cambios locales."

    Invoke-GitQuickReview -ProjectName "RedMotors" -RepoPath $Environment.RedMotorsPath

    if (Test-Folder $Environment.AlticaPath) {
        Invoke-GitQuickReview -ProjectName "Altica" -RepoPath $Environment.AlticaPath
    }
    else {
        Write-Section "Altica"
        Write-Host "Altica pendiente de configurar."
        Write-Host "Ruta esperada: $($Environment.AlticaPath)"
    }
}

function Show-MainMenu {
    param([pscustomobject]$Environment)

    Write-Section "Launcher de trabajo"
    Write-Host "Equipo: $($Environment.Device)"
    Write-Host "Usuario/ruta detectada: $($Environment.UserPath)"

    if ($Environment.BaseRepos) {
        Write-Host "BaseRepos: $($Environment.BaseRepos)"
        Write-Host "RedMotors: $($Environment.RedMotorsPath)"

        if (Test-Folder $Environment.AlticaPath) {
            Write-Host "Altica: $($Environment.AlticaPath)"
        }
        else {
            Write-Host "Altica: Altica pendiente de configurar"
        }
    }
    else {
        Write-Host "Rutas conocidas: no configuradas para este equipo."
    }

    Write-Host ""
    Write-Host "Que quieres hacer?"
    Write-Host ""
    Write-Host "1. Trabajar en una asignacion"
    Write-Host "2. Uso casual / no laboral"
    Write-Host "3. Revision rapida de estado"
    Write-Host "4. Mantenimiento / limpieza mensual"
    Write-Host "5. Salir"
    Write-Host ""
}

$environment = Get-LauncherEnvironment

Show-MainMenu -Environment $environment
$choice = Read-Host "Selecciona una opcion (1-5)"

switch ($choice) {
    "1" {
        Show-WorkProjectMenu -Environment $environment
    }
    "2" {
        Write-Host "Modo casual seleccionado. No se ejecuto Git, Salesforce ni VS Code."
    }
    "3" {
        Show-QuickReview -Environment $environment
    }
    "4" {
        Write-Host "Mantenimiento mensual pendiente de implementar. No se ejecutaron acciones."
    }
    "5" {
        Write-Host "Salida solicitada. No se ejecuto ninguna accion."
    }
    default {
        Write-Host "Opcion no reconocida. No se ejecuto ninguna accion."
    }
}
