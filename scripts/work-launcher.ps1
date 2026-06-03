<#
General work launcher for local operating modes.

Safety rules:
- Diagnostics and navigation only.
- No deploy, retrieve, git reset, git clean, or automatic pull.
- End-of-day closure may delegate safe log add/commit/push to scripts/end-work.ps1.
- RedMotors can delegate diagnostics to scripts/start-work.ps1 and scripts/pause-work.ps1.
#>

[CmdletBinding()]
param(
    [switch]$SkipAutoPower
)

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

function Get-LauncherBatteryInfo {
    $batteries = @()

    try {
        $batteries = @(Get-CimInstance -ClassName Win32_Battery -ErrorAction Stop)
    }
    catch {
        return [pscustomobject]@{
            HasBattery = $false
            OnBattery  = $false
            Error       = $_.Exception.Message
        }
    }

    $onBattery = $false
    foreach ($battery in $batteries) {
        if ($null -ne $battery.BatteryStatus -and $battery.BatteryStatus -eq 1) {
            $onBattery = $true
        }
    }

    return [pscustomobject]@{
        HasBattery = ($batteries.Count -gt 0)
        OnBattery  = $onBattery
        Error       = ""
    }
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

function Start-ShortcutTarget {
    param(
        [string]$Label,
        [string]$ShortcutPath
    )

    if ([string]::IsNullOrWhiteSpace($ShortcutPath)) {
        return $false
    }

    try {
        Start-Process -FilePath $ShortcutPath -ErrorAction Stop
        Write-Host "Abriendo $Label."
        return $true
    }
    catch {
        return $false
    }
}

function Start-ExplorerTarget {
    param(
        [string]$Label,
        [string]$Target
    )

    if ([string]::IsNullOrWhiteSpace($Target)) {
        return $false
    }

    try {
        Start-Process -FilePath "explorer.exe" -ArgumentList $Target -ErrorAction Stop
        Write-Host "Abriendo $Label."
        return $true
    }
    catch {
        return $false
    }
}

function Start-DetachedExecutable {
    param(
        [string]$Label,
        [string]$FilePath
    )

    if ([string]::IsNullOrWhiteSpace($FilePath) -or -not (Test-File $FilePath)) {
        return $false
    }

    try {
        $escapedPath = $FilePath.Replace('"', '\"')
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c start """" ""$escapedPath""" -WindowStyle Hidden -ErrorAction Stop
        Write-Host "Abriendo $Label."
        return $true
    }
    catch {
        return $false
    }
}

function Start-AppShortcut {
    param(
        [string]$Label,
        [string]$ShortcutPattern
    )

    $startMenuFolders = @()

    if (-not [string]::IsNullOrWhiteSpace($env:APPDATA)) {
        $startMenuFolders += (Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs")
    }

    if (-not [string]::IsNullOrWhiteSpace($env:ProgramData)) {
        $startMenuFolders += (Join-Path $env:ProgramData "Microsoft\Windows\Start Menu\Programs")
    }

    foreach ($folder in $startMenuFolders) {
        if (-not (Test-Folder $folder)) {
            continue
        }

        $shortcut = @(Get-ChildItem -LiteralPath $folder -Recurse -Filter $ShortcutPattern -ErrorAction SilentlyContinue | Select-Object -First 1)
        if ($shortcut.Count -gt 0 -and (Start-ShortcutTarget -Label $Label -ShortcutPath $shortcut[0].FullName)) {
            return $true
        }
    }

    return $false
}

function Start-AppsFolderApp {
    param(
        [string]$Label,
        [string[]]$NamePatterns
    )

    try {
        $shell = New-Object -ComObject Shell.Application
        $appsFolder = $shell.Namespace("shell:AppsFolder")

        if ($null -eq $appsFolder) {
            return $false
        }

        foreach ($item in @($appsFolder.Items())) {
            foreach ($pattern in $NamePatterns) {
                if ($item.Name -like $pattern) {
                    $item.InvokeVerb("open")
                    Write-Host "Abriendo $Label."
                    return $true
                }
            }
        }
    }
    catch {
        return $false
    }

    return $false
}

function Start-AppProtocol {
    param(
        [string]$Label,
        [string]$Protocol
    )

    if ([string]::IsNullOrWhiteSpace($Protocol)) {
        return $false
    }

    $registryPath = "Registry::HKEY_CLASSES_ROOT\$Protocol"
    if (-not (Test-Path -LiteralPath $registryPath)) {
        return $false
    }

    return Start-ExplorerTarget -Label $Label -Target "${Protocol}:"
}

function Get-ChromePath {
    $candidates = @()

    if (-not [string]::IsNullOrWhiteSpace($env:ProgramFiles)) {
        $candidates += (Join-Path $env:ProgramFiles "Google\Chrome\Application\chrome.exe")
    }

    if (-not [string]::IsNullOrWhiteSpace(${env:ProgramFiles(x86)})) {
        $candidates += (Join-Path ${env:ProgramFiles(x86)} "Google\Chrome\Application\chrome.exe")
    }

    foreach ($candidate in $candidates) {
        if (Test-File $candidate) {
            return $candidate
        }
    }

    $command = Get-Command "chrome.exe" -ErrorAction SilentlyContinue
    if ($null -ne $command) {
        return $command.Source
    }

    return $null
}

function Open-Chrome {
    $chromePath = Get-ChromePath
    if ($chromePath) {
        try {
            Start-Process -FilePath $chromePath -ErrorAction Stop
            Write-Host "Abriendo Google Chrome."
            return
        }
        catch {
            Write-Host "Advertencia: no se pudo abrir Chrome desde $chromePath."
        }
    }

    if (Start-AppShortcut -Label "Google Chrome" -ShortcutPattern "*Chrome*.lnk") {
        return
    }

    Write-Host "Advertencia: no se pudo abrir Google Chrome. Abre Chrome manualmente si lo necesitas."
}

function Open-VsCode {
    if ($null -eq (Get-Command "code" -ErrorAction SilentlyContinue)) {
        Write-Host "No se encontro el comando code en PATH. Abre VS Code manualmente si lo necesitas."
        return
    }

    Write-Host "Abriendo VS Code con: code ."
    & code .
}

function Open-WhatsApp {
    if (Start-AppShortcut -Label "WhatsApp de escritorio" -ShortcutPattern "*WhatsApp*.lnk") {
        return
    }

    if (Start-AppsFolderApp -Label "WhatsApp de escritorio" -NamePatterns @("*WhatsApp*")) {
        return
    }

    if (Start-AppProtocol -Label "WhatsApp de escritorio" -Protocol "whatsapp") {
        return
    }

    $candidates = @()

    if (-not [string]::IsNullOrWhiteSpace($env:LOCALAPPDATA)) {
        $candidates += (Join-Path $env:LOCALAPPDATA "WhatsApp\WhatsApp.exe")
    }

    if (-not [string]::IsNullOrWhiteSpace($env:ProgramFiles)) {
        $candidates += (Join-Path $env:ProgramFiles "WhatsApp\WhatsApp.exe")
    }

    if (-not [string]::IsNullOrWhiteSpace(${env:ProgramFiles(x86)})) {
        $candidates += (Join-Path ${env:ProgramFiles(x86)} "WhatsApp\WhatsApp.exe")
    }

    foreach ($candidate in $candidates) {
        if (Start-DetachedExecutable -Label "WhatsApp de escritorio" -FilePath $candidate) {
            return
        }
    }

    $command = Get-Command "WhatsApp.exe" -ErrorAction SilentlyContinue
    if ($null -ne $command -and (Start-DetachedExecutable -Label "WhatsApp de escritorio" -FilePath $command.Source)) {
        return
    }

    Write-Host "Advertencia: no se pudo abrir WhatsApp de escritorio. No se abrira WhatsApp en Chrome."
}

function Open-ChatGptApp {
    if (Start-AppShortcut -Label "ChatGPT app" -ShortcutPattern "*ChatGPT*.lnk") {
        return
    }

    if (Start-AppsFolderApp -Label "ChatGPT app" -NamePatterns @("*ChatGPT*", "*OpenAI*")) {
        return
    }

    if (Start-AppProtocol -Label "ChatGPT app" -Protocol "chatgpt") {
        return
    }

    $candidates = @()

    if (-not [string]::IsNullOrWhiteSpace($env:LOCALAPPDATA)) {
        $candidates += (Join-Path $env:LOCALAPPDATA "Programs\ChatGPT\ChatGPT.exe")
        $candidates += (Join-Path $env:LOCALAPPDATA "OpenAI\ChatGPT\ChatGPT.exe")
    }

    if (-not [string]::IsNullOrWhiteSpace($env:ProgramFiles)) {
        $candidates += (Join-Path $env:ProgramFiles "ChatGPT\ChatGPT.exe")
        $candidates += (Join-Path $env:ProgramFiles "OpenAI\ChatGPT\ChatGPT.exe")
    }

    foreach ($candidate in $candidates) {
        if (Start-DetachedExecutable -Label "ChatGPT app" -FilePath $candidate) {
            return
        }
    }

    $command = Get-Command "ChatGPT.exe" -ErrorAction SilentlyContinue
    if ($null -ne $command -and (Start-DetachedExecutable -Label "ChatGPT app" -FilePath $command.Source)) {
        return
    }

    Write-Host "Advertencia: no se pudo abrir ChatGPT app. No se abrira ChatGPT en Chrome."
}

function Open-ClaudeApp {
    if (Start-AppShortcut -Label "Claude app" -ShortcutPattern "*Claude*.lnk") {
        return
    }

    if (Start-AppsFolderApp -Label "Claude app" -NamePatterns @("*Claude*", "*Anthropic*")) {
        return
    }

    if (Start-AppProtocol -Label "Claude app" -Protocol "claude") {
        return
    }

    $candidates = @()

    if (-not [string]::IsNullOrWhiteSpace($env:LOCALAPPDATA)) {
        $candidates += (Join-Path $env:LOCALAPPDATA "Programs\Claude\Claude.exe")
        $candidates += (Join-Path $env:LOCALAPPDATA "AnthropicClaude\Claude.exe")
    }

    if (-not [string]::IsNullOrWhiteSpace($env:ProgramFiles)) {
        $candidates += (Join-Path $env:ProgramFiles "Claude\Claude.exe")
        $candidates += (Join-Path $env:ProgramFiles "Anthropic\Claude\Claude.exe")
    }

    foreach ($candidate in $candidates) {
        if (Start-DetachedExecutable -Label "Claude app" -FilePath $candidate) {
            return
        }
    }

    $command = Get-Command "Claude.exe" -ErrorAction SilentlyContinue
    if ($null -ne $command -and (Start-DetachedExecutable -Label "Claude app" -FilePath $command.Source)) {
        return
    }

    Write-Host "Advertencia: no se pudo abrir Claude app. No se abrira Claude en Chrome."
}

function Open-AiToolIfRequested {
    Write-Host ""
    Write-Host "Que IA vas a usar para analizar la asignacion?"
    Write-Host ""
    Write-Host "1. ChatGPT app"
    Write-Host "2. Claude app"
    Write-Host "3. Ninguna por ahora"
    Write-Host ""

    $aiChoice = Read-Host "Selecciona una opcion (1-3)"

    switch ($aiChoice) {
        "1" {
            Open-ChatGptApp
        }
        "2" {
            Open-ClaudeApp
        }
        "3" {
            Write-Host "No se abrio IA."
        }
        default {
            Write-Host "Opcion no reconocida. No se abrio IA."
        }
    }
}

function Get-WorkspaceShortcutSearchFolders {
    $folders = @()

    if (-not [string]::IsNullOrWhiteSpace($env:USERPROFILE)) {
        $folders += (Join-Path $env:USERPROFILE "Desktop")
    }

    if (-not [string]::IsNullOrWhiteSpace($env:PUBLIC)) {
        $folders += (Join-Path $env:PUBLIC "Desktop")
    }

    return @($folders | Where-Object {
            -not [string]::IsNullOrWhiteSpace($_)
        } | Select-Object -Unique)
}

function Get-WorkspaceShortcutFileName {
    param([string]$ShortcutName)

    if ([string]::IsNullOrWhiteSpace($ShortcutName)) {
        return ""
    }

    if ($ShortcutName.EndsWith(".lnk", [System.StringComparison]::OrdinalIgnoreCase)) {
        return $ShortcutName
    }

    return "$ShortcutName.lnk"
}

function Get-WorkspaceShortcutPath {
    param([string]$ShortcutName)

    $shortcutFileName = Get-WorkspaceShortcutFileName -ShortcutName $ShortcutName
    if ([string]::IsNullOrWhiteSpace($shortcutFileName)) {
        return $null
    }

    if ($shortcutFileName -ieq "Dev Launchpad.lnk") {
        return $null
    }

    foreach ($folder in @(Get-WorkspaceShortcutSearchFolders)) {
        if (-not (Test-Folder $folder)) {
            continue
        }

        $candidate = Join-Path $folder $shortcutFileName
        if (Test-File $candidate) {
            return $candidate
        }
    }

    return $null
}

function Write-MissingWorkspaceShortcutWarning {
    param(
        [string]$Label,
        [string]$ShortcutName
    )

    $shortcutFileName = Get-WorkspaceShortcutFileName -ShortcutName $ShortcutName

    Write-Host "Advertencia: no se encontro el acceso directo del area de trabajo '$Label'."
    Write-Host "Nombre esperado: $shortcutFileName"
    Write-Host "Rutas revisadas:"

    foreach ($folder in @(Get-WorkspaceShortcutSearchFolders)) {
        Write-Host "- $folder"
    }

    Write-Host "El flujo no se bloquea; abre el area manualmente si la necesitas."
}

function Open-WorkspaceShortcut {
    param(
        [string]$Label,
        [string]$ShortcutName
    )

    $shortcutFileName = Get-WorkspaceShortcutFileName -ShortcutName $ShortcutName
    if ($shortcutFileName -ieq "Dev Launchpad.lnk") {
        Write-Host "Advertencia: Dev Launchpad.lnk es el acceso directo del launcher y no se abrira desde DevLaunchpad."
        return
    }

    $shortcutPath = Get-WorkspaceShortcutPath -ShortcutName $ShortcutName
    if ([string]::IsNullOrWhiteSpace($shortcutPath)) {
        Write-MissingWorkspaceShortcutWarning -Label $Label -ShortcutName $ShortcutName
        return
    }

    if (-not (Start-ShortcutTarget -Label "area de trabajo $Label" -ShortcutPath $shortcutPath)) {
        Write-Host "Advertencia: no se pudo abrir el area de trabajo '$Label'."
        Write-Host "Ruta: $shortcutPath"
    }
}

function Write-NoWorkspaceOpened {
    Write-Host "No se abrio area de trabajo."
}

function Write-ManualWorkspaceMessage {
    Write-Host "No se abrieron apps automaticamente. Abre manualmente lo que necesites."
}

function Open-WorkspaceIfRequested {
    param([string]$Device)

    $areaText = "$([char]0x00E1)rea"
    $question = "$([char]0x00BF)Deseas abrir $([char]0x00E1)rea de trabajo?"

    Write-Host ""
    Write-Host $question
    Write-Host ""

    if ($Device -eq "PC") {
        Write-Host "1. Salesforce Dev PC"
        Write-Host "2. No abrir $areaText de trabajo"
        Write-Host "3. Abrir apps manualmente / no hacer nada"
        Write-Host ""

        $workspaceChoice = Read-Host "Selecciona una opcion (1-3)"

        switch ($workspaceChoice) {
            "1" {
                Open-WorkspaceShortcut -Label "Salesforce Dev PC" -ShortcutName "Salesforce Dev PC"
            }
            "2" {
                Write-NoWorkspaceOpened
            }
            "3" {
                Write-ManualWorkspaceMessage
            }
            default {
                Write-Host "Opcion no reconocida. No se abrio area de trabajo."
            }
        }

        return
    }

    if ($Device -eq "Laptop") {
        Write-Host "1. Laptop con monitores"
        Write-Host "2. Solo Laptop"
        Write-Host "3. No abrir $areaText de trabajo"
        Write-Host "4. Abrir apps manualmente / no hacer nada"
        Write-Host ""

        $workspaceChoice = Read-Host "Selecciona una opcion (1-4)"

        switch ($workspaceChoice) {
            "1" {
                Open-WorkspaceShortcut -Label "Laptop con monitores" -ShortcutName "Laptop con monitores"
            }
            "2" {
                Open-WorkspaceShortcut -Label "Solo Laptop" -ShortcutName "Solo Laptop"
            }
            "3" {
                Write-NoWorkspaceOpened
            }
            "4" {
                Write-ManualWorkspaceMessage
            }
            default {
                Write-Host "Opcion no reconocida. No se abrio area de trabajo."
            }
        }

        return
    }

    Write-Host "No hay areas de trabajo configuradas para este equipo."
    Write-NoWorkspaceOpened
}

function Get-ActiveAssignmentExpectedBranch {
    param([string]$RepoPath)

    $activeAssignmentPath = Join-Path $RepoPath "docs\asignaciones\ACTIVE_ASSIGNMENT.md"

    if (-not (Test-File $activeAssignmentPath)) {
        return ""
    }

    try {
        $line = @(Get-Content -LiteralPath $activeAssignmentPath -ErrorAction Stop | Where-Object {
                $_ -match "^\s*-\s*Expected branch\s*:\s*(.+?)\s*$"
            } | Select-Object -First 1)

        if ($line.Count -eq 0) {
            return ""
        }

        if ($line[0] -match "^\s*-\s*Expected branch\s*:\s*(.+?)\s*$") {
            return $Matches[1].Trim()
        }
    }
    catch {
        Write-Host "Advertencia: no se pudo leer ACTIVE_ASSIGNMENT.md."
    }

    return ""
}

function Invoke-AutoPowerMode {
    param(
        [string]$RepoPath,
        [string]$Device,
        [switch]$Skip
    )

    if ($Skip) {
        Write-Host "Modo energia automatico omitido por parametro."
        return
    }

    if ($Device -eq "PC") {
        Write-Host "Modo energia automatico omitido: PC detectada."
        return
    }

    if ($Device -ne "Laptop") {
        Write-Host "Modo energia automatico omitido: equipo no Laptop."
        return
    }

    Write-Section "Modo energia automatico"

    $powerModePath = Join-Path $RepoPath "scripts\power-mode.ps1"
    if (-not (Test-File $powerModePath)) {
        Write-Host "Advertencia: no se encontro scripts/power-mode.ps1. Se continua sin bloquear inicio de trabajo."
        return
    }

    try {
        Write-Host ".\scripts\power-mode.ps1 -Mode Auto"
        & ".\scripts\power-mode.ps1" -Mode Auto

        if ($LASTEXITCODE -ne 0) {
            Write-Host "Advertencia: power-mode.ps1 fallo durante modo energia automatico. Se continua con el flujo normal."
        }
    }
    catch {
        Write-Host "Advertencia: no se pudo ejecutar modo energia automatico. Se continua con el flujo normal."
        Write-Host $_.Exception.Message
    }
}

function Get-CurrentPowerShellPath {
    try {
        $process = Get-Process -Id $PID -ErrorAction Stop
        if (-not [string]::IsNullOrWhiteSpace($process.Path) -and (Test-File $process.Path)) {
            return $process.Path
        }
    }
    catch {
    }

    $pwsh = Get-Command "pwsh.exe" -ErrorAction SilentlyContinue
    if ($null -ne $pwsh) {
        return $pwsh.Source
    }

    $powershell = Get-Command "powershell.exe" -ErrorAction SilentlyContinue
    if ($null -ne $powershell) {
        return $powershell.Source
    }

    return "powershell.exe"
}

function Invoke-StartWorkDiagnostic {
    param(
        [string]$WorkMode,
        [string]$ExpectedBranch
    )

    $powerShellPath = Get-CurrentPowerShellPath
    $arguments = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", ".\scripts\start-work.ps1", "-Mode", $WorkMode)

    if ($WorkMode -eq "Continue" -and -not [string]::IsNullOrWhiteSpace($ExpectedBranch)) {
        $arguments += @("-ExpectedBranch", $ExpectedBranch)
    }

    $output = @(& $powerShellPath @arguments 2>&1 | ForEach-Object {
            $line = "$_"
            Write-Host $line
            $line
        })

    $state = "Unknown"
    if (@($output | Where-Object { $_ -match "NO COMENZAR TODAVIA" }).Count -gt 0) {
        $state = "Blocked"
    }
    elseif (@($output | Where-Object { $_ -match "LISTO PARA RECIBIR ASIGNACION|LISTO - CONTINUAR ASIGNACION" }).Count -gt 0) {
        $state = "Ready"
    }

    return [pscustomobject]@{
        State    = $state
        ExitCode = $LASTEXITCODE
        Output   = $output
    }
}

function Start-RedMotorsWork {
    param(
        [string]$RepoPath,
        [string]$Device,
        [ValidateSet("New", "Continue")]
        [string]$WorkMode = "New"
    )

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
        $expectedBranch = ""
        if ($WorkMode -eq "Continue") {
            $expectedBranch = Get-ActiveAssignmentExpectedBranch -RepoPath $RepoPath
            if (-not [string]::IsNullOrWhiteSpace($expectedBranch)) {
                Write-Host "Rama esperada detectada en ACTIVE_ASSIGNMENT.md: $expectedBranch"
            }
            else {
                Write-Host "No se detecto rama esperada en ACTIVE_ASSIGNMENT.md; se validara modo Continue sin ExpectedBranch."
            }
        }

        Write-Host "Ejecutando diagnostico RedMotors:"
        $diagnostic = $null
        if ($WorkMode -eq "Continue" -and -not [string]::IsNullOrWhiteSpace($expectedBranch)) {
            Write-Host ".\scripts\start-work.ps1 -Mode Continue -ExpectedBranch `"$expectedBranch`""
            $diagnostic = Invoke-StartWorkDiagnostic -WorkMode Continue -ExpectedBranch $expectedBranch
        }
        else {
            Write-Host ".\scripts\start-work.ps1 -Mode $WorkMode"
            $diagnostic = Invoke-StartWorkDiagnostic -WorkMode $WorkMode -ExpectedBranch ""
        }

        if ($null -eq $diagnostic -or $diagnostic.State -ne "Ready") {
            Write-Host ""
            if ($null -eq $diagnostic -or $diagnostic.State -eq "Unknown") {
                Write-Host "Advertencia: no se pudo detectar claramente si el entorno esta LISTO."
            }
            Write-Host "Entorno NO validado. No continues todavia."
            Write-Host "Copia el resumen anterior y compartelo en ChatGPT para decidir el siguiente paso."
            Write-Host "Nota: modo energia aplicado no significa entorno validado."
            return
        }

        Write-Host ""
        Invoke-AutoPowerMode -RepoPath $RepoPath -Device $Device -Skip:$SkipAutoPower
        Write-Host ""
        Open-WorkspaceIfRequested -Device $Device
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

function Start-RedMotorsClose {
    param([string]$RepoPath)

    Write-Section "Cierre RedMotors"

    if (-not (Test-Folder $RepoPath)) {
        Write-Host "RedMotors no existe en la ruta esperada:"
        Write-Host $RepoPath
        return
    }

    $endWorkPath = Join-Path $RepoPath "scripts\end-work.ps1"
    if (-not (Test-File $endWorkPath)) {
        Write-Host "No se encontro scripts/end-work.ps1 en RedMotors."
        Write-Host "Ruta revisada: $endWorkPath"
        return
    }

    Push-Location -LiteralPath $RepoPath
    try {
        Write-Host "Selecciona el tipo de cierre:"
        Write-Host ""
        Write-Host "1. Cierre automatico seguro (recomendado)"
        Write-Host "2. Cierre manual / corregir datos"
        Write-Host "3. Cancelar"
        Write-Host ""

        $closeModeChoice = Read-Host "Selecciona una opcion (1-3, Enter = 1)"
        if ([string]::IsNullOrWhiteSpace($closeModeChoice)) {
            $closeModeChoice = "1"
        }

        switch ($closeModeChoice) {
            "1" {
                Write-Host "Ejecutando cierre RedMotors:"
                Write-Host ".\scripts\end-work.ps1 -Mode AutoSafe"
                & ".\scripts\end-work.ps1" -Mode AutoSafe
            }
            "2" {
                Write-Host "Ejecutando cierre RedMotors:"
                Write-Host ".\scripts\end-work.ps1 -Mode Manual"
                & ".\scripts\end-work.ps1" -Mode Manual
            }
            "3" {
                Write-Host "Operacion cancelada."
            }
            default {
                Write-Host "Opcion no reconocida. No se ejecuto ninguna accion."
            }
        }
    }
    finally {
        Pop-Location
    }
}

function Start-AlticaClose {
    Write-Section "Cierre Altica"
    Write-Host "Altica todavia no esta configurado para cierre automatico."
}

function Start-RedMotorsPause {
    param(
        [string]$RepoPath,
        [string]$Device
    )

    Write-Section "Pausa RedMotors"

    if (-not (Test-Folder $RepoPath)) {
        Write-Host "RedMotors no existe en la ruta esperada:"
        Write-Host $RepoPath
        return
    }

    $pauseWorkPath = Join-Path $RepoPath "scripts\pause-work.ps1"
    if (-not (Test-File $pauseWorkPath)) {
        Write-Host "No se encontro scripts/pause-work.ps1 en RedMotors."
        Write-Host "Ruta revisada: $pauseWorkPath"
        return
    }

    if ($Device -eq "Laptop") {
        $battery = Get-LauncherBatteryInfo
        if ($battery.OnBattery) {
            Write-Host "Modo movil/bateria recomendado para traslado."
        }
        else {
            Write-Host "Si vas a desconectar y salir, puedes aplicar Movil / bateria desde Modo energia."
        }
    }

    Push-Location -LiteralPath $RepoPath
    try {
        Write-Host "Ejecutando pausa RedMotors:"
        Write-Host ".\scripts\pause-work.ps1"
        & ".\scripts\pause-work.ps1"
    }
    finally {
        Pop-Location
    }
}

function Start-AlticaPause {
    Write-Section "Pausa Altica"
    Write-Host "Altica todavia no esta configurado para pausa/cambio de equipo."
}

function Show-WorkProjectMenu {
    param(
        [pscustomobject]$Environment,
        [ValidateSet("New", "Continue")]
        [string]$WorkMode = "New"
    )

    Write-Section "Proyecto"
    if ($WorkMode -eq "New") {
        Write-Host "En que proyecto vamos a iniciar una nueva asignacion?"
    }
    else {
        Write-Host "En que proyecto vamos a continuar la asignacion activa?"
    }
    Write-Host ""
    Write-Host "1. RedMotors"
    Write-Host "2. Altica"
    Write-Host "3. Otro / nueva empresa"
    Write-Host "4. Cancelar"
    Write-Host ""

    $projectChoice = Read-Host "Selecciona una opcion (1-4)"

    switch ($projectChoice) {
        "1" {
            Start-RedMotorsWork -RepoPath $Environment.RedMotorsPath -Device $Environment.Device -WorkMode $WorkMode
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

function Show-PauseProjectMenu {
    param([pscustomobject]$Environment)

    Write-Section "Pausar / cambiar de equipo"
    Write-Host "Que proyecto vamos a pausar?"
    Write-Host ""
    Write-Host "1. RedMotors"
    Write-Host "2. Altica"
    Write-Host "3. Otro / nueva empresa"
    Write-Host "4. Cancelar"
    Write-Host ""

    $projectChoice = Read-Host "Selecciona una opcion (1-4)"

    switch ($projectChoice) {
        "1" {
            Start-RedMotorsPause -RepoPath $Environment.RedMotorsPath -Device $Environment.Device
        }
        "2" {
            Start-AlticaPause
        }
        "3" {
            Write-Host "Proyecto nuevo pendiente de configurar."
        }
        "4" {
            Write-Host "Operacion cancelada."
        }
        default {
            Write-Host "Opcion no reconocida. No se ejecuto ninguna accion."
        }
    }
}

function Show-CloseProjectMenu {
    param([pscustomobject]$Environment)

    Write-Section "Cierre de proyecto"
    Write-Host "Que proyecto vamos a cerrar?"
    Write-Host ""
    Write-Host "1. RedMotors"
    Write-Host "2. Altica"
    Write-Host "3. Otro / nueva empresa"
    Write-Host "4. Cancelar"
    Write-Host ""

    $projectChoice = Read-Host "Selecciona una opcion (1-4)"

    switch ($projectChoice) {
        "1" {
            Start-RedMotorsClose -RepoPath $Environment.RedMotorsPath
        }
        "2" {
            Start-AlticaClose
        }
        "3" {
            Write-Host "Proyecto nuevo pendiente de configurar."
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

function Show-PowerModeMenu {
    param([pscustomobject]$Environment)

    Write-Section "Modo energia"

    if (-not (Test-Folder $Environment.RedMotorsPath)) {
        Write-Host "RedMotors no existe en la ruta esperada:"
        Write-Host $Environment.RedMotorsPath
        return
    }

    $powerModePath = Join-Path $Environment.RedMotorsPath "scripts\power-mode.ps1"
    if (-not (Test-File $powerModePath)) {
        Write-Host "No se encontro scripts/power-mode.ps1 en RedMotors."
        Write-Host "Ruta revisada: $powerModePath"
        return
    }

    Write-Host "1. Ver estado de energia"
    Write-Host "2. Trabajo conectado a corriente"
    Write-Host "3. Movil / bateria"
    Write-Host "4. Cancelar"
    Write-Host ""

    $powerChoice = Read-Host "Selecciona una opcion (1-4)"

    Push-Location -LiteralPath $Environment.RedMotorsPath
    try {
        switch ($powerChoice) {
            "1" {
                & ".\scripts\power-mode.ps1" -Mode Status
            }
            "2" {
                & ".\scripts\power-mode.ps1" -Mode WorkPlugged
            }
            "3" {
                & ".\scripts\power-mode.ps1" -Mode MobileBattery
            }
            "4" {
                Write-Host "Operacion cancelada."
            }
            default {
                Write-Host "Opcion no reconocida. No se ejecuto ninguna accion."
            }
        }
    }
    finally {
        Pop-Location
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
    Write-Host "1. Nueva asignacion"
    Write-Host "2. Continuar asignacion activa"
    Write-Host "3. Pausar / cambiar de equipo"
    Write-Host "4. Cerrar dia / trabajo"
    Write-Host "5. Revision rapida de estado"
    Write-Host "6. Mantenimiento / limpieza mensual"
    Write-Host "7. Salir"
    Write-Host "8. Modo energia"
    Write-Host ""
}

$environment = Get-LauncherEnvironment

Show-MainMenu -Environment $environment
$choice = Read-Host "Selecciona una opcion (1-8)"

switch ($choice) {
    "1" {
        Show-WorkProjectMenu -Environment $environment -WorkMode New
    }
    "2" {
        Show-WorkProjectMenu -Environment $environment -WorkMode Continue
    }
    "3" {
        Show-PauseProjectMenu -Environment $environment
    }
    "4" {
        Show-CloseProjectMenu -Environment $environment
    }
    "5" {
        Show-QuickReview -Environment $environment
    }
    "6" {
        Write-Host "Mantenimiento mensual pendiente de implementar. No se ejecutaron acciones."
    }
    "7" {
        Write-Host "Salida solicitada. No se ejecuto ninguna accion."
    }
    "8" {
        Show-PowerModeMenu -Environment $environment
    }
    default {
        Write-Host "Opcion no reconocida. No se ejecuto ninguna accion."
    }
}
