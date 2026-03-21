param(
    [string]$HaUrl = $env:HA_URL,
    [string]$HaToken = $env:HA_TOKEN,
    [string]$OutputRoot = ".\_ha_debug\roborock",
    [int]$HoursBack = 12,
    [switch]$WhatIf,
    [switch]$IncludeTraceHints
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Write-Host "[$timestamp] $Message"
}

if ([string]::IsNullOrWhiteSpace($HaUrl) -or [string]::IsNullOrWhiteSpace($HaToken)) {
    throw "HA_URL and HA_TOKEN must be available via parameters or environment variables."
}

$headers = @{
    Authorization = "Bearer $HaToken"
    "Content-Type" = "application/json"
}

$haBase = $HaUrl.TrimEnd('/')
$stamp = Get-Date -Format 'yyyy-MM-dd_HHmmss'
$targetDir = Join-Path $OutputRoot $stamp

$entities = @(
    "sensor.saros_20_set_status",
    "sensor.saros_20_set_letzter_reinigungsbeginn",
    "sensor.saros_20_set_letztes_reinigungsende",
    "input_boolean.roborock_busy",
    "input_text.roborock_current_program",
    "input_text.roborock_last_error",
    "input_text.roborock_last_program_sequence",
    "input_text.roborock_last_slot"
)

function Invoke-HaGet {
    param([string]$Uri)
    return Invoke-RestMethod -Uri $Uri -Headers $headers -Method Get
}

function New-TargetDirectory {
    if ($WhatIf) {
        Write-Log "Would create debug directory: $targetDir"
        return
    }
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

function Save-JsonFile {
    param(
        [string]$FileName,
        [object]$Data
    )
    $path = Join-Path $targetDir $FileName
    $json = $Data | ConvertTo-Json -Depth 100
    if ($WhatIf) {
        Write-Log "Would write: $path"
        return
    }
    $json | Out-File -LiteralPath $path -Encoding utf8
    Write-Log "Saved: $path"
}

function Save-TextFile {
    param(
        [string]$FileName,
        [string]$Content
    )
    $path = Join-Path $targetDir $FileName
    if ($WhatIf) {
        Write-Log "Would write: $path"
        return
    }
    $Content | Out-File -LiteralPath $path -Encoding utf8
    Write-Log "Saved: $path"
}

function Get-EntityState {
    param([string]$EntityId)
    $url = "$haBase/api/states/${EntityId}"
    try {
        return Invoke-HaGet -Uri $url
    }
    catch {
        return @{
            entity_id = $EntityId
            error = $_.Exception.Message
        }
    }
}

function Get-HistoryWindow {
    param([int]$Hours)
    $utcEnd = (Get-Date).ToUniversalTime()
    $utcStart = $utcEnd.AddHours(-1 * $Hours)
    return @{
        Start = $utcStart.ToString("o")
        End   = $utcEnd.ToString("o")
    }
}

function Get-EntityHistory {
    param(
        [string]$EntityId,
        [string]$StartIso,
        [string]$EndIso
    )
    $encodedEntity = [uri]::EscapeDataString($EntityId)
    $url = "$haBase/api/history/period/${StartIso}?filter_entity_id=${encodedEntity}&end_time=${EndIso}&minimal_response=0&no_attributes=0"
    try {
        return Invoke-HaGet -Uri $url
    }
    catch {
        return @{
            entity_id = $EntityId
            error = $_.Exception.Message
        }
    }
}

function Build-Summary {
    param(
        [hashtable]$Window,
        [object[]]$States
    )

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# Roborock Debug Capture")
    $lines.Add("")
    $lines.Add("Created: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
    $lines.Add("HA URL: $haBase")
    $lines.Add("History window UTC:")
    $lines.Add("- start: $($Window.Start)")
    $lines.Add("- end:   $($Window.End)")
    $lines.Add("")
    $lines.Add("Captured current states:")
    foreach ($item in $States) {
        if ($item.PSObject.Properties.Name -contains 'state') {
            $lines.Add("- $($item.entity_id) = $($item.state)")
        }
        else {
            $lines.Add("- $($item.entity_id) = ERROR: $($item.error)")
        }
    }
    if ($IncludeTraceHints) {
        $lines.Add("")
        $lines.Add("Suggested trace correlation targets:")
        $lines.Add("- script.roborock_execute_program_job")
        $lines.Add("- script.roborock_execute_job_chain")
        $lines.Add("- script.roborock_finalize_execution")
    }
    return ($lines -join [Environment]::NewLine)
}

Write-Log "Starting Roborock debug capture"
Write-Log "HA URL: $haBase"
Write-Log "Output root: $OutputRoot"
Write-Log "HoursBack: $HoursBack"
Write-Log "WhatIf: $WhatIf"

$window = Get-HistoryWindow -Hours $HoursBack
$currentStates = @()

New-TargetDirectory

foreach ($entityId in $entities) {
    Write-Log "Fetch current state: $entityId"
    $state = Get-EntityState -EntityId $entityId
    $currentStates += $state

    Write-Log "Fetch history: $entityId"
    $history = Get-EntityHistory -EntityId $entityId -StartIso $window.Start -EndIso $window.End

    $safeName = $entityId.Replace('.', '_')
    Save-JsonFile -FileName "${safeName}_history.json" -Data $history
}

Save-JsonFile -FileName "current_states.json" -Data $currentStates
Save-TextFile -FileName "README.txt" -Content (Build-Summary -Window $window -States $currentStates)

Write-Log "Roborock debug capture completed"