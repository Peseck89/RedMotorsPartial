<#
Local power mode helper for DevLaunchpad.

Safety rules:
- Uses only Windows powercfg diagnostics/settings.
- Does not touch Git, Salesforce, force-app, apps, commits, pushes, deploys or retrieves.
- Does not shut down, restart, suspend, hibernate, or close applications.
#>

[CmdletBinding()]
param(
    [ValidateSet("Status", "WorkPlugged", "MobileBattery", "Auto")]
    [string]$Mode
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

function Write-Section {
    param([string]$Title)

    Write-Host ""
    Write-Host "=== $Title ==="
}

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

function Get-DetectedDevice {
    $userPath = Get-UserPath

    if ($userPath.IndexOf("C:\Users\Claudia", [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
        return "PC"
    }

    if ($userPath.IndexOf("C:\Users\dokur", [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
        return "Laptop"
    }

    return "Desconocido"
}

function Get-BatteryInfo {
    $batteries = @()

    try {
        $batteries = @(Get-CimInstance -ClassName Win32_Battery -ErrorAction Stop)
    }
    catch {
        Write-Host "Advertencia: no se pudo consultar bateria con Win32_Battery. $($_.Exception.Message)"
    }

    $hasBattery = ($batteries.Count -gt 0)
    $onBattery = $false

    foreach ($battery in $batteries) {
        if ($null -ne $battery.BatteryStatus -and $battery.BatteryStatus -eq 1) {
            $onBattery = $true
        }
    }

    return [pscustomobject]@{
        HasBattery = $hasBattery
        OnBattery  = $onBattery
    }
}

function Test-PowerCfgAvailable {
    return ($null -ne (Get-Command "powercfg.exe" -ErrorAction SilentlyContinue))
}

function Invoke-PowerCfg {
    param([string[]]$Arguments)

    if (-not (Test-PowerCfgAvailable)) {
        Write-Host "Advertencia: powercfg no esta disponible en PATH."
        return $false
    }

    try {
        $output = @(& powercfg.exe @Arguments 2>&1 | ForEach-Object { "$_" })
        $exitCode = $LASTEXITCODE

        if ($exitCode -ne 0) {
            Write-Host "Advertencia: powercfg fallo al ejecutar: powercfg $($Arguments -join ' ')"
            foreach ($line in $output) {
                if (-not [string]::IsNullOrWhiteSpace($line)) {
                    Write-Host $line
                }
            }
            return $false
        }

        foreach ($line in $output) {
            if (-not [string]::IsNullOrWhiteSpace($line)) {
                Write-Host $line
            }
        }

        return $true
    }
    catch {
        Write-Host "Advertencia: no se pudo ejecutar powercfg $($Arguments -join ' '). $($_.Exception.Message)"
        return $false
    }
}

function Invoke-PowerCfgChange {
    param(
        [string]$SettingName,
        [int]$Minutes
    )

    Write-Host "Aplicando: powercfg /change $SettingName $Minutes"
    return Invoke-PowerCfg -Arguments @("/change", $SettingName, "$Minutes")
}

function Write-ActivePowerScheme {
    Write-Host ""
    Write-Host "Plan activo:"

    if (-not (Test-PowerCfgAvailable)) {
        Write-Host "Advertencia: powercfg no esta disponible en PATH."
        return
    }

    try {
        $output = @(& powercfg.exe /getactivescheme 2>&1 | ForEach-Object { "$_" })
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Advertencia: no se pudo leer el plan activo con powercfg /getactivescheme."
            foreach ($line in $output) {
                if (-not [string]::IsNullOrWhiteSpace($line)) {
                    Write-Host $line
                }
            }
            return
        }

        foreach ($line in $output) {
            Write-Host $line
        }
    }
    catch {
        Write-Host "Advertencia: no se pudo leer el plan activo. $($_.Exception.Message)"
    }
}

function Get-PowerCfgSettingQuery {
    param([string]$SettingName)

    if ($SettingName -like "monitor-timeout-*") {
        return @("SUB_VIDEO", "VIDEOIDLE")
    }

    if ($SettingName -like "standby-timeout-*") {
        return @("SUB_SLEEP", "STANDBYIDLE")
    }

    if ($SettingName -like "hibernate-timeout-*") {
        return @("SUB_SLEEP", "HIBERNATEIDLE")
    }

    return @()
}

function Convert-PowerCfgValueToSeconds {
    param([string]$ValueText)

    $cleanValue = $ValueText.Trim()
    [long]$seconds = 0

    if ($cleanValue -match "^0x[0-9a-fA-F]+$") {
        return [Convert]::ToInt64($cleanValue, 16)
    }

    if ([long]::TryParse($cleanValue, [ref]$seconds)) {
        return $seconds
    }

    return $null
}

function Get-PowerCfgSettingSeconds {
    param(
        [string]$SettingName,
        [string[]]$Output
    )

    $isAc = $SettingName.EndsWith("-ac")
    $localizedPattern = if ($isAc) { "corriente alterna|current ac|ac power" } else { "corriente continua|current dc|dc power" }
    $valuePattern = "(0x[0-9a-fA-F]+|\d+)\s*$"

    $line = @($Output | Where-Object {
            $_ -match $localizedPattern -and $_ -match $valuePattern
        } | Select-Object -First 1)

    if ($line.Count -gt 0 -and $line[0] -match $valuePattern) {
        return Convert-PowerCfgValueToSeconds -ValueText $Matches[1]
    }

    $indexLines = @($Output | Where-Object {
            $_ -match "configuraci[oó]n.*actual|setting.*index" -and $_ -match $valuePattern
        })

    $index = if ($isAc) { 0 } else { 1 }
    if ($indexLines.Count -gt $index -and $indexLines[$index] -match $valuePattern) {
        return Convert-PowerCfgValueToSeconds -ValueText $Matches[1]
    }

    return $null
}

function Format-PowerCfgMinutes {
    param([long]$Seconds)

    if ($Seconds -eq 0) {
        return "Nunca (0 segundos)"
    }

    $minutes = [Math]::Floor($Seconds / 60)
    return "$minutes minutos ($Seconds segundos)"
}

function Write-PowerCfgSetting {
    param([string]$SettingName)

    if (-not (Test-PowerCfgAvailable)) {
        Write-Host "$SettingName : no detectado. Diagnostico: powercfg no disponible."
        return
    }

    $query = @(Get-PowerCfgSettingQuery -SettingName $SettingName)
    if ($query.Count -ne 2) {
        Write-Host "$SettingName : no detectado. Diagnostico: configuracion desconocida."
        return
    }

    try {
        $output = @(& powercfg.exe /query SCHEME_CURRENT $query[0] $query[1] 2>&1 | ForEach-Object { "$_" })

        if ($LASTEXITCODE -ne 0 -or $output.Count -eq 0) {
            Write-Host "$SettingName : no detectado. Diagnostico: fallo powercfg /query $($query -join ' ')."
            return
        }

        $seconds = Get-PowerCfgSettingSeconds -SettingName $SettingName -Output $output

        if ($null -eq $seconds) {
            Write-Host "$SettingName : no detectado. Diagnostico: salida powercfg sin indice AC/DC reconocible."
            return
        }

        Write-Host "$SettingName : $(Format-PowerCfgMinutes -Seconds $seconds)"
    }
    catch {
        Write-Host "$SettingName : no detectado. Diagnostico: $($_.Exception.Message)"
    }
}

function Show-Status {
    $device = Get-DetectedDevice
    $battery = Get-BatteryInfo

    Write-Section "Estado de energia"
    Write-Host "Equipo detectado: $device"
    Write-Host "Bateria detectada: $(if ($battery.HasBattery) { "Si" } else { "No" })"

    if ($battery.HasBattery) {
        Write-Host "Estado de bateria: $(if ($battery.OnBattery) { "En bateria" } else { "Conectada a corriente o cargando" })"
    }

    Write-ActivePowerScheme

    Write-Host ""
    Write-Host "Configuracion actual basica:"
    Write-PowerCfgSetting -SettingName "monitor-timeout-ac"
    Write-PowerCfgSetting -SettingName "standby-timeout-ac"
    Write-PowerCfgSetting -SettingName "hibernate-timeout-ac"
    Write-PowerCfgSetting -SettingName "monitor-timeout-dc"
    Write-PowerCfgSetting -SettingName "standby-timeout-dc"
    Write-PowerCfgSetting -SettingName "hibernate-timeout-dc"
}

function Set-WorkPluggedMode {
    param([switch]$SkipSection)

    $device = Get-DetectedDevice
    $battery = Get-BatteryInfo

    if (-not $SkipSection) {
        Write-Section "Modo trabajo conectado"
    }

    if ($device -eq "Laptop" -and $battery.OnBattery) {
        Write-Host "Estas en bateria. Este modo esta pensado para corriente."
    }

    $ok = $true
    $ok = (Invoke-PowerCfgChange -SettingName "monitor-timeout-ac" -Minutes 0) -and $ok
    $ok = (Invoke-PowerCfgChange -SettingName "standby-timeout-ac" -Minutes 0) -and $ok
    $ok = (Invoke-PowerCfgChange -SettingName "hibernate-timeout-ac" -Minutes 0) -and $ok

    if ($ok) {
        Write-Host "Modo trabajo conectado aplicado. No se suspendera mientras este conectada a corriente."
    }
    else {
        Write-Host "Advertencia: no se pudo aplicar completamente el modo trabajo conectado."
    }

    return $ok
}

function Set-MobileBatteryMode {
    param([switch]$SkipSection)

    if (-not $SkipSection) {
        Write-Section "Modo movil/bateria"
    }

    $ok = $true
    $ok = (Invoke-PowerCfgChange -SettingName "monitor-timeout-dc" -Minutes 5) -and $ok
    $ok = (Invoke-PowerCfgChange -SettingName "standby-timeout-dc" -Minutes 15) -and $ok
    $ok = (Invoke-PowerCfgChange -SettingName "hibernate-timeout-dc" -Minutes 30) -and $ok

    if ($ok) {
        Write-Host "Modo movil/bateria aplicado."
    }
    else {
        Write-Host "Advertencia: no se pudo aplicar completamente el modo movil/bateria."
    }

    return $ok
}

function Set-AutoPowerMode {
    $battery = Get-BatteryInfo
    $useWorkPlugged = (-not $battery.HasBattery) -or (-not $battery.OnBattery)

    if ($useWorkPlugged) {
        $ok = Set-WorkPluggedMode -SkipSection

        if ($ok) {
            Write-Host "Modo energia automatico: Trabajo conectado aplicado."
            Write-Host "Modo energia automatico aplicado: Trabajo conectado."
            Write-Host "AC: pantalla Nunca / suspension Nunca / hibernacion Nunca"
        }
        else {
            Write-Host "Advertencia: fallo el modo energia automatico de trabajo conectado."
        }

        return $ok
    }

    $ok = Set-MobileBatteryMode -SkipSection

    if ($ok) {
        Write-Host "Modo energia automatico: Movil / bateria aplicado."
        Write-Host "Modo energia automatico aplicado: Movil / bateria."
        Write-Host "DC: pantalla 5 min / suspension 15 min / hibernacion 30 min"
    }
    else {
        Write-Host "Advertencia: fallo el modo energia automatico movil / bateria."
    }

    return $ok
}

function Show-ModeMenu {
    Write-Section "Modo energia"
    Write-Host "1. Status"
    Write-Host "2. WorkPlugged"
    Write-Host "3. MobileBattery"
    Write-Host "4. Cancelar"
    Write-Host ""

    $choice = Read-Host "Selecciona una opcion (1-4)"

    switch ($choice) {
        "1" {
            Show-Status
        }
        "2" {
            Set-WorkPluggedMode | Out-Null
        }
        "3" {
            Set-MobileBatteryMode | Out-Null
        }
        "4" {
            Write-Host "Operacion cancelada."
        }
        default {
            Write-Host "Opcion no reconocida. No se ejecuto ninguna accion."
        }
    }
}

if ([string]::IsNullOrWhiteSpace($Mode)) {
    Show-ModeMenu
}
else {
    switch ($Mode) {
        "Status" {
            Show-Status
        }
        "WorkPlugged" {
            Set-WorkPluggedMode | Out-Null
        }
        "MobileBattery" {
            Set-MobileBatteryMode | Out-Null
        }
        "Auto" {
            $ok = Set-AutoPowerMode
            if (-not $ok) {
                exit 1
            }
        }
    }
}
