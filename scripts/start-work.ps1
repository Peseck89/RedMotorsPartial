<#
RedMotors start-work diagnostic script.

Safety rules:
- Diagnostics only.
- No Salesforce metadata changes.
- No deploy, retrieve, reset, clean, commit, push, pull, or automatic fix.
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

$Risks = New-Object System.Collections.Generic.List[string]

function Add-Risk {
    param([string]$Reason)

    if (-not [string]::IsNullOrWhiteSpace($Reason)) {
        [void]$script:Risks.Add($Reason)
    }
}

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
            Add-Risk "$Label fallo con codigo $exitCode."
        }

        return [pscustomobject]@{
            ExitCode = $exitCode
            Output   = $lines
        }
    }
    catch {
        Add-Risk "$Label no se pudo ejecutar: $($_.Exception.Message)"
        return [pscustomobject]@{
            ExitCode = 1
            Output   = @()
        }
    }
}

function Remove-AnsiEscape {
    param([string]$Text)

    if ($null -eq $Text) {
        return ""
    }

    $escape = [char]27
    return $Text -replace "$escape\[[0-?]*[ -/]*[@-~]", ""
}

function Get-JsonObjectText {
    param([string]$Text)

    $cleanText = Remove-AnsiEscape $Text
    $firstBrace = $cleanText.IndexOf("{")
    $lastBrace = $cleanText.LastIndexOf("}")

    if ($firstBrace -lt 0 -or $lastBrace -lt 0 -or $lastBrace -lt $firstBrace) {
        return $null
    }

    return $cleanText.Substring($firstBrace, $lastBrace - $firstBrace + 1)
}

function Invoke-JsonCommand {
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
        $text = Remove-AnsiEscape (($lines -join "`n").Trim())
        $jsonText = Get-JsonObjectText $text

        $exitCode = if ($null -ne $global:LASTEXITCODE) {
            [int]$global:LASTEXITCODE
        }
        else {
            0
        }

        if ($exitCode -ne 0) {
            Add-Risk "$Label fallo con codigo $exitCode."
        }

        $json = $null
        if ([string]::IsNullOrWhiteSpace($text)) {
            Add-Risk "$Label no devolvio salida JSON."
        }
        elseif ([string]::IsNullOrWhiteSpace($jsonText)) {
            Add-Risk "$Label no contiene un bloque JSON valido entre '{' y '}'."
            Write-Host "No se encontro bloque JSON valido en la salida de $Label."
        }
        else {
            try {
                $json = $jsonText | ConvertFrom-Json -ErrorAction Stop
                Write-Host "JSON recibido y parseado."
            }
            catch {
                Add-Risk "$Label devolvio una salida que no pudo parsearse como JSON."
                Write-Host "No se pudo parsear JSON de $Label."
            }
        }

        return [pscustomobject]@{
            ExitCode = $exitCode
            Json     = $json
            Output   = $lines
        }
    }
    catch {
        Add-Risk "$Label no se pudo ejecutar: $($_.Exception.Message)"
        return [pscustomobject]@{
            ExitCode = 1
            Json     = $null
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

function Test-StatusFlag {
    param(
        [string]$StatusLine,
        [string]$Flag
    )

    if ([string]::IsNullOrWhiteSpace($StatusLine)) {
        return $false
    }

    return $StatusLine -match $Flag
}

function Get-ObjectPropertyValue {
    param(
        [object]$Object,
        [string[]]$Names
    )

    if ($null -eq $Object) {
        return $null
    }

    foreach ($name in $Names) {
        $property = @($Object.PSObject.Properties | Where-Object { $_.Name -ieq $name } | Select-Object -First 1)
        if ($property.Count -gt 0) {
            return $property[0].Value
        }
    }

    return $null
}

function Get-TargetOrgFromConfigJson {
    param([object]$ConfigJson)

    $result = Get-ObjectPropertyValue $ConfigJson @("result")
    if ($null -eq $result) {
        return $null
    }

    $directValue = Get-ObjectPropertyValue $result @("target-org", "targetOrg")
    if (-not [string]::IsNullOrWhiteSpace("$directValue")) {
        return "$directValue"
    }

    foreach ($item in @($result)) {
        $name = Get-ObjectPropertyValue $item @("name", "key")
        $value = Get-ObjectPropertyValue $item @("value")

        if ("$name" -eq "target-org" -and -not [string]::IsNullOrWhiteSpace("$value")) {
            return "$value"
        }
    }

    return $null
}

function Get-OrgRecordsFromOrgListJson {
    param([object]$OrgListJson)

    $records = @()
    $result = Get-ObjectPropertyValue $OrgListJson @("result")
    if ($null -eq $result) {
        return $records
    }

    foreach ($org in @($result)) {
        $aliasValue = Get-ObjectPropertyValue $org @("alias", "aliases")
        $usernameValue = Get-ObjectPropertyValue $org @("username")
        $orgIdValue = Get-ObjectPropertyValue $org @("orgId", "id")
        $connectionValue = Get-ObjectPropertyValue $org @("connectedStatus", "status")

        if ($null -ne $aliasValue -or $null -ne $usernameValue -or $null -ne $orgIdValue -or $null -ne $connectionValue) {
            $records += $org
        }
    }

    foreach ($section in @($result.PSObject.Properties)) {
        $value = $section.Value

        if ($null -eq $value -or $value -is [string] -or $value -is [System.ValueType]) {
            continue
        }

        foreach ($org in @($value)) {
            $aliasValue = Get-ObjectPropertyValue $org @("alias", "aliases")
            $usernameValue = Get-ObjectPropertyValue $org @("username")
            $orgIdValue = Get-ObjectPropertyValue $org @("orgId", "id")
            $connectionValue = Get-ObjectPropertyValue $org @("connectedStatus", "status")

            if ($null -ne $aliasValue -or $null -ne $usernameValue -or $null -ne $orgIdValue -or $null -ne $connectionValue) {
                $records += $org
            }
        }
    }

    return $records
}

function Test-OnlyInitialScriptUntracked {
    param([string[]]$UntrackedPaths)

    $paths = @($UntrackedPaths | ForEach-Object { ($_ -replace "\\", "/").Trim() })
    if ($paths.Count -eq 0) {
        return $false
    }

    if ($paths.Count -eq 1 -and $paths[0] -eq "scripts/start-work.ps1") {
        return $true
    }

    if ($paths.Count -eq 1 -and $paths[0] -eq "scripts/") {
        $scriptPath = Join-Path (Get-Location).Path "scripts/start-work.ps1"
        if (-not (Test-Path -LiteralPath $scriptPath)) {
            return $false
        }

        $files = @(Get-ChildItem -LiteralPath (Join-Path (Get-Location).Path "scripts") -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
                ($_.FullName.Substring((Get-Location).Path.Length + 1) -replace "\\", "/")
            })

        return ($files.Count -eq 1 -and $files[0] -eq "scripts/start-work.ps1")
    }

    return $false
}

function Test-OrgHasAlias {
    param(
        [object]$Org,
        [string]$Alias
    )

    $aliasValue = Get-ObjectPropertyValue $Org @("alias")
    $aliasesValue = Get-ObjectPropertyValue $Org @("aliases")

    foreach ($candidate in @($aliasValue) + @($aliasesValue)) {
        if ("$candidate" -eq $Alias) {
            return $true
        }
    }

    return $false
}

function Get-OrgConnectionStatus {
    param(
        [object[]]$OrgRecords,
        [string]$Alias
    )

    $matches = @($OrgRecords | Where-Object { Test-OrgHasAlias -Org $_ -Alias $Alias })
    if ($matches.Count -eq 0) {
        return "Missing"
    }

    foreach ($org in $matches) {
        $connectedStatus = Get-ObjectPropertyValue $org @("connectedStatus", "status")
        if ("$connectedStatus".Trim() -eq "Connected") {
            return "Connected"
        }
    }

    return "Not Connected"
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

$requiredContextFiles = @(
    ".git",
    "CLAUDE.md",
    "AI_HANDOFF.md",
    "WORK_LOG.md",
    "WEEKLY_REPORT_LOG.md"
)

$contextStatus = [ordered]@{}
foreach ($item in $requiredContextFiles) {
    $exists = Test-Path -LiteralPath (Join-Path $currentPath $item)
    $contextStatus[$item] = $exists

    if (-not $exists) {
        Add-Risk "Falta $item en la ruta actual."
    }
}

if ($device -eq "Desconocido") {
    Add-Risk "No se pudo identificar si el equipo es PC o Laptop por la ruta."
}

Write-Section "Inicio"
Write-Host "Proyecto: RedMotors"
Write-Host "Equipo: $device"
Write-Host "Fecha: $dateText"
Write-Host "Hora inicio: $timeText"
Write-Host "Ruta: $currentPath"

Write-Section "Contexto IA"
foreach ($item in $requiredContextFiles) {
    $status = if ($contextStatus[$item]) { "OK" } else { "FALTA" }
    Write-Host "${item}: $status"
}

$gitInstalled = Test-Tool "git"
$gitStatusBefore = $null
$gitStatusAfter = $null
$gitBranch = ""
$gitRemote = $null
$gitLog = $null
$hasLocalChanges = $false
$hasUntracked = $false
$onlyInitialScriptUntracked = $false
$isAhead = $false
$isBehind = $false
$hasOrigin = $false

Write-Section "Git"
if (-not $gitInstalled) {
    Add-Risk "git no esta disponible en PATH."
    Write-Host "git no esta disponible en PATH."
}
elseif (-not $contextStatus[".git"]) {
    Add-Risk "La ruta actual no parece ser un repositorio Git."
    Write-Host "La ruta actual no parece ser un repositorio Git."
}
else {
    $gitStatusBefore = Invoke-DiagnosticCommand "git status -sb inicial" "git" @("status", "-sb")
    $branchResult = Invoke-DiagnosticCommand "git branch --show-current" "git" @("branch", "--show-current")
    $gitBranch = (@($branchResult.Output | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }) | Select-Object -First 1)
    $gitRemote = Invoke-DiagnosticCommand "git remote -v" "git" @("remote", "-v")
    $fetchResult = Invoke-DiagnosticCommand "git fetch" "git" @("fetch")
    $gitStatusAfter = Invoke-DiagnosticCommand "git status -sb despues de fetch" "git" @("status", "-sb")
    $gitLog = Invoke-DiagnosticCommand "git log --oneline --decorate -1" "git" @("log", "--oneline", "--decorate", "-1")

    $statusLine = Get-FirstStatusLine $gitStatusAfter.Output
    $statusBody = @($gitStatusAfter.Output | Where-Object { $_ -and ($_ -notlike "## *") })
    $untrackedLines = @($statusBody | Where-Object { $_ -match "^\?\?\s+" })
    $trackedChangeLines = @($statusBody | Where-Object { $_ -notmatch "^\?\?\s+" })
    $untrackedPaths = @($untrackedLines | ForEach-Object {
            ($_ -replace "^\?\?\s+", "" -replace "\\", "/").Trim()
        })

    $hasLocalChanges = $statusBody.Count -gt 0
    $hasUntracked = $untrackedLines.Count -gt 0
    $onlyInitialScriptUntracked = $hasUntracked -and $trackedChangeLines.Count -eq 0 -and (Test-OnlyInitialScriptUntracked -UntrackedPaths $untrackedPaths)
    $isAhead = Test-StatusFlag $statusLine "ahead\s+\d+"
    $isBehind = Test-StatusFlag $statusLine "behind\s+\d+"
    $hasOrigin = @($gitRemote.Output | Where-Object { $_ -match "^origin\s+" }).Count -gt 0

    if ([string]::IsNullOrWhiteSpace($gitBranch)) {
        Add-Risk "No se pudo detectar la rama actual."
    }
    elseif ($gitBranch -ne "main") {
        Add-Risk "La rama actual es $gitBranch; para iniciar asignacion se esperaba main."
    }

    if (-not $hasOrigin) {
        Add-Risk "No se detecto remote origin."
    }

    if ($trackedChangeLines.Count -gt 0) {
        Add-Risk "Hay cambios locales sin cerrar."
    }

    if ($hasUntracked -and -not $onlyInitialScriptUntracked) {
        Add-Risk "Hay archivos untracked."
    }
    elseif ($onlyInitialScriptUntracked) {
        Write-Host ""
        Write-Host "Nota: solo aparece sin versionar scripts/start-work.ps1 durante la prueba inicial; no se considera riesgo real."
    }

    if ($isAhead) {
        Add-Risk "La rama local esta ahead de su upstream."
    }

    if ($isBehind) {
        Add-Risk "La rama local esta behind de su upstream; revisar y hacer pull manual si corresponde."
    }

    if ($fetchResult.ExitCode -ne 0) {
        Add-Risk "No se pudo completar git fetch; no asumir sincronizacion con origin."
    }
}

$sfInstalled = Test-Tool "sf"
$sfVersion = $null
$sfConfig = $null
$sfOrgList = $null
$targetOrg = $null
$sandboxConnectionStatus = "Missing"
$prodConnectionStatus = "Missing"

Write-Section "Salesforce"
if (-not $sfInstalled) {
    Add-Risk "sf CLI no esta disponible en PATH."
    Write-Host "sf CLI no esta disponible en PATH."
}
else {
    $sfVersion = Invoke-DiagnosticCommand "sf --version" "sf" @("--version")
    $sfConfig = Invoke-JsonCommand "sf config list --json" "sf" @("config", "list", "--json")
    $sfOrgList = Invoke-JsonCommand "sf org list --json" "sf" @("org", "list", "--json")

    $targetOrg = Get-TargetOrgFromConfigJson $sfConfig.Json
    $orgRecords = Get-OrgRecordsFromOrgListJson $sfOrgList.Json
    $sandboxConnectionStatus = Get-OrgConnectionStatus -OrgRecords $orgRecords -Alias "RedMotorsSandbox"
    $prodConnectionStatus = Get-OrgConnectionStatus -OrgRecords $orgRecords -Alias "RedMotorsProd"

    Write-Host ""
    Write-Host "target-org: $(if ($targetOrg) { $targetOrg } else { 'No detectado' })"
    Write-Host "RedMotorsSandbox: $sandboxConnectionStatus"
    Write-Host "RedMotorsProd: $prodConnectionStatus"

    if ([string]::IsNullOrWhiteSpace($targetOrg)) {
        Add-Risk "No se detecto target-org en sf config list --json."
    }
    elseif ($targetOrg -ne "RedMotorsSandbox") {
        Add-Risk "El target-org detectado es $targetOrg; para RedMotors se espera RedMotorsSandbox."
    }

    if ($sandboxConnectionStatus -ne "Connected") {
        Add-Risk "RedMotorsSandbox esta $sandboxConnectionStatus en sf org list --json."
    }

    if ($prodConnectionStatus -ne "Connected") {
        Add-Risk "RedMotorsProd esta $prodConnectionStatus en sf org list --json."
    }
}

$contextSummary = if (@($contextStatus.GetEnumerator() | Where-Object { -not $_.Value }).Count -eq 0) {
    "OK"
}
else {
    "Incompleto"
}

$gitSummary = if ($gitInstalled -and $contextStatus[".git"] -and -not $hasLocalChanges -and -not $isAhead -and -not $isBehind -and $hasOrigin) {
    "Limpio y sincronizado"
}
elseif ($gitInstalled -and $contextStatus[".git"] -and $onlyInitialScriptUntracked -and -not $isAhead -and -not $isBehind -and $hasOrigin) {
    "Sincronizado; solo scripts/start-work.ps1 sin commit inicial"
}
elseif ($gitInstalled -and $contextStatus[".git"]) {
    "Revisar"
}
else {
    "No disponible"
}

$originSummary = if ($hasOrigin) { "origin detectado" } else { "origin no detectado" }
$salesforceSummary = if ($targetOrg) { $targetOrg } else { "No detectado" }

$finalState = if ($Risks.Count -eq 0) {
    "LISTO PARA RECIBIR ASIGNACION"
}
else {
    "NO COMENZAR TODAVIA"
}

if ($isBehind) {
    $pullRecommendation = "Revisar diferencias y hacer pull manual si corresponde."
}
elseif ($finalState -eq "LISTO PARA RECIBIR ASIGNACION" -and ($gitSummary -eq "Limpio y sincronizado" -or $gitSummary -like "Sincronizado;*")) {
    $pullRecommendation = "No se requiere pull manual; puedes comenzar."
}
else {
    $pullRecommendation = "No se recomienda pull manual por ahora."
}

Write-Section "Resumen final"
Write-Host "Proyecto: RedMotors"
Write-Host "Equipo: $device"
Write-Host "Fecha: $dateText"
Write-Host "Hora: $timeText"
Write-Host "Ruta: $currentPath"
Write-Host "Rama: $gitBranch"
Write-Host "Git: $gitSummary"
Write-Host "Origin: $originSummary"
Write-Host "Salesforce target-org: $salesforceSummary"
Write-Host "RedMotorsSandbox: $sandboxConnectionStatus"
Write-Host "RedMotorsProd: $prodConnectionStatus"
Write-Host "Contexto IA: $contextSummary"
Write-Host "Estado final: $finalState"
Write-Host "Recomendacion: $pullRecommendation"

if ($Risks.Count -gt 0) {
    Write-Host ""
    Write-Host "Razones:"
    foreach ($risk in $Risks) {
        Write-Host "- $risk"
    }
}

Write-Host ""
Write-Host $finalState
Write-Host ""
Write-Host "Siguiente paso:"
Write-Host "Abre ChatGPT o Claude en el proyecto correcto y pega ahi la transcripcion, WhatsApp, documento o explicacion de Luis."
Write-Host "No pegues esa informacion en PowerShell."
