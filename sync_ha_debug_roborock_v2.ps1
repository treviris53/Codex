param(
    [string]$HaUrl = $env:HA_URL,
    [string]$HaToken = $env:HA_TOKEN,
    [string]$OutputRoot = ".\_ha_debug\roborock",
    [int]$HoursBack = 1,
    [datetime]$StartTime,
    [datetime]$EndTime,
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

function Invoke-HaGet {
    param([string]$Uri)
    return Invoke-RestMethod -Uri $Uri -Headers $script:headers -Method Get
}

function New-TargetDirectory {
    if ($WhatIf) {
        Write-Log "Would create debug directory: $script:targetDir"
        return
    }
    New-Item -ItemType Directory -Path $script:targetDir -Force | Out-Null
}

function Save-JsonFile {
    param(
        [string]$FileName,
        [object]$Data
    )
    $path = Join-Path $script:targetDir $FileName
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
    $path = Join-Path $script:targetDir $FileName
    if ($WhatIf) {
        Write-Log "Would write: $path"
        return
    }
    $Content | Out-File -LiteralPath $path -Encoding utf8
    Write-Log "Saved: $path"
}

function Get-EntityState {
    param([string]$EntityId)
    $url = "$script:haBase/api/states/${EntityId}"
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

function Get-EntityHistory {
    param(
        [string]$EntityId,
        [string]$StartIso,
        [string]$EndIso
    )
    $encodedEntity = [uri]::EscapeDataString($EntityId)
    $url = "$script:haBase/api/history/period/${StartIso}?filter_entity_id=${encodedEntity}&end_time=${EndIso}&minimal_response=0&no_attributes=0"
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

function Get-LogbookWindow {
    param(
        [string]$StartIso,
        [string]$EndIso
    )
    $encodedEnd = [uri]::EscapeDataString($EndIso)
    $url = "$script:haBase/api/logbook/${StartIso}?end_time=${encodedEnd}"
    try {
        return Invoke-HaGet -Uri $url
    }
    catch {
        return @{
            error = $_.Exception.Message
        }
    }
}

function Get-CaptureWindow {
    if ($script:HasEndTime -and -not $script:HasStartTime) {
        throw "EndTime requires StartTime."
    }

    if ($script:HasStartTime) {
        $localStart = $StartTime
        $localEnd = if ($script:HasEndTime) { $EndTime } else { Get-Date }
    }
    else {
        $localEnd = Get-Date
        $localStart = $localEnd.AddHours(-1 * $HoursBack)
    }

    if ($localEnd -lt $localStart) {
        throw "EndTime must be greater than or equal to StartTime."
    }

    $utcStart = $localStart.ToUniversalTime()
    $utcEnd = $localEnd.ToUniversalTime()

    return @{
        LocalStart = $localStart
        LocalEnd = $localEnd
        Start = $utcStart.ToString("o")
        End = $utcEnd.ToString("o")
    }
}

function New-SafeFileName {
    param([string]$EntityId)
    return $EntityId.Replace('.', '_')
}

function Get-PropertyValue {
    param(
        [object]$InputObject,
        [string]$PropertyName
    )

    if ($null -eq $InputObject) {
        return $null
    }

    $property = $InputObject.PSObject.Properties[$PropertyName]
    if ($null -eq $property) {
        return $null
    }

    return $property.Value
}

function Get-RelevantLogbookEntries {
    param(
        [object[]]$Entries,
        [string[]]$EntityIds
    )

    $entityLookup = @{}
    foreach ($entityId in $EntityIds) {
        $entityLookup[$entityId] = $true
    }

    $namePatterns = @(
        'Roborock Scheduler',
        'Roborock - Execution Cleanup',
        'Roborock - Program Sequence Executor',
        'Roborock - Job Chain Executor',
        'Roborock - Sicheres Einzelprogramm starten'
    )

    $filtered = New-Object System.Collections.Generic.List[object]
    foreach ($entry in $Entries) {
        $entryEntityId = [string](Get-PropertyValue -InputObject $entry -PropertyName 'entity_id')
        $entryName = [string](Get-PropertyValue -InputObject $entry -PropertyName 'name')
        $entryMessage = [string](Get-PropertyValue -InputObject $entry -PropertyName 'message')

        $include = $false
        if (-not [string]::IsNullOrWhiteSpace($entryEntityId) -and $entityLookup.ContainsKey($entryEntityId)) {
            $include = $true
        }
        elseif (-not [string]::IsNullOrWhiteSpace($entryName) -and $namePatterns -contains $entryName) {
            $include = $true
        }
        elseif (-not [string]::IsNullOrWhiteSpace($entryMessage) -and $entryMessage -match 'Roborock') {
            $include = $true
        }

        if ($include) {
            $filtered.Add($entry)
        }
    }

    return $filtered
}

function Build-Readme {
    param(
        [hashtable]$Window,
        [hashtable]$Manifest,
        [object[]]$CurrentStates,
        [int]$RelevantLogbookCount
    )

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# Roborock Debug Capture v2")
    $lines.Add("")
    $lines.Add("Created: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
    $lines.Add("HA URL: $script:haBase")
    $lines.Add("History window local:")
    $lines.Add("- start: $($Window.LocalStart.ToString('yyyy-MM-dd HH:mm:ss zzz'))")
    $lines.Add("- end:   $($Window.LocalEnd.ToString('yyyy-MM-dd HH:mm:ss zzz'))")
    $lines.Add("History window UTC:")
    $lines.Add("- start: $($Window.Start)")
    $lines.Add("- end:   $($Window.End)")
    $lines.Add("")
    $lines.Add("Captured groups:")
    $lines.Add("- history_entities: $($Manifest.history_entities.Count)")
    $lines.Add("- current_only_entities: $($Manifest.current_only_entities.Count)")
    $lines.Add("- scheduler_snapshot_entities: $($Manifest.scheduler_snapshot_entities.Count)")
    $lines.Add("- button_entities: $($Manifest.button_entities.Count)")
    $lines.Add("- filtered_logbook_entries: $RelevantLogbookCount")
    $lines.Add("")
    $lines.Add("Current state highlights:")
    foreach ($item in $CurrentStates) {
        if ($item.PSObject.Properties.Name -contains 'state') {
            $lines.Add("- $($item.entity_id) = $($item.state)")
        }
        else {
            $lines.Add("- $($item.entity_id) = ERROR: $($item.error)")
        }
    }
    if ($IncludeTraceHints) {
        $lines.Add("")
        $lines.Add("Suggested manual trace exports:")
        $lines.Add("- script.roborock_execute_program_job")
        $lines.Add("- script.roborock_execute_job_chain")
        $lines.Add("- script.roborock_finalize_execution")
        $lines.Add("- automation.roborock_scheduler_woche_3_slots_4_jobs")
    }

    return ($lines -join [Environment]::NewLine)
}

if ([string]::IsNullOrWhiteSpace($HaUrl) -or [string]::IsNullOrWhiteSpace($HaToken)) {
    throw "HA_URL and HA_TOKEN must be available via parameters or environment variables."
}

$script:headers = @{
    Authorization = "Bearer $HaToken"
    "Content-Type" = "application/json"
}

$script:haBase = $HaUrl.TrimEnd('/')
$script:HasStartTime = $PSBoundParameters.ContainsKey('StartTime')
$script:HasEndTime = $PSBoundParameters.ContainsKey('EndTime')
$stamp = Get-Date -Format 'yyyy-MM-dd_HHmmss'
$script:targetDir = Join-Path $OutputRoot $stamp

$days = @('mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun')
$slots = @(1, 2, 3)

$coreHistoryEntities = @(
    'sensor.saros_20_set_status',
    'sensor.saros_20_set_letzter_reinigungsbeginn',
    'sensor.saros_20_set_letztes_reinigungsende',
    'sensor.saros_20_set_staubsauger_fehler',
    'input_boolean.roborock_busy',
    'input_datetime.roborock_busy_since',
    'input_text.roborock_current_program',
    'input_text.roborock_last_error',
    'input_text.roborock_last_job',
    'input_text.roborock_last_program_sequence',
    'input_text.roborock_last_slot',
    'binary_sensor.roborock_program_ready',
    'binary_sensor.roborock_program_blocked',
    'script.roborock_execute_job_chain',
    'script.roborock_execute_program_job',
    'script.roborock_finalize_execution',
    'script.roborock_run_named_program',
    'automation.roborock_scheduler_woche_3_slots_4_jobs'
)

$buttonEntities = @(
    'button.saros_20_set_wohn_saugen_2',
    'button.saros_20_set_wohn_saug_wisch',
    'button.saros_20_set_wohn_saugen',
    'button.saros_20_set_saugen_schlafzimmer',
    'button.saros_20_set_schlaf_saug_wisch',
    'button.saros_20_set_schlaf_vac_mop',
    'button.saros_20_set_reinigung_von_haustierbedarf',
    'button.saros_20_set_flur_saug_wisch',
    'button.saros_20_set_flur_vac_mop',
    'button.saros_20_set_flur_saugen'
)

$currentOnlyEntities = @(
    'vacuum.saros_20_set',
    'sensor.saros_20_set_batterie',
    'sensor.saros_20_set_aktueller_raum',
    'sensor.saros_20_set_reinigungszeit'
)

$schedulerSnapshotEntities = @(
    'input_boolean.roborock_schedule_enabled',
    'input_boolean.roborock_slot_time_bootstrap_done'
)

foreach ($day in $days) {
    foreach ($slot in $slots) {
        $schedulerSnapshotEntities += "input_boolean.roborock_slot_enabled_${day}_${slot}"
        $schedulerSnapshotEntities += "input_datetime.roborock_time_${day}_${slot}"
        $schedulerSnapshotEntities += "input_text.roborock_jobs_${day}_${slot}"
    }
}

$allCurrentEntities = @(
    $coreHistoryEntities +
    $buttonEntities +
    $currentOnlyEntities +
    $schedulerSnapshotEntities
) | Select-Object -Unique

$historyEntities = @(
    $coreHistoryEntities +
    $buttonEntities
) | Select-Object -Unique

$manifest = @{
    history_entities = $historyEntities
    current_only_entities = $currentOnlyEntities
    scheduler_snapshot_entities = $schedulerSnapshotEntities
    button_entities = $buttonEntities
}

Write-Log "Starting Roborock debug capture v2"
Write-Log "HA URL: $script:haBase"
Write-Log "Output root: $OutputRoot"
Write-Log "HoursBack: $HoursBack"
Write-Log "WhatIf: $WhatIf"

$window = Get-CaptureWindow
Write-Log "Capture window local: $($window.LocalStart.ToString('yyyy-MM-dd HH:mm:ss zzz')) -> $($window.LocalEnd.ToString('yyyy-MM-dd HH:mm:ss zzz'))"

$currentStates = New-Object System.Collections.Generic.List[object]
$schedulerSnapshot = New-Object System.Collections.Generic.List[object]

New-TargetDirectory

foreach ($entityId in $allCurrentEntities) {
    Write-Log "Fetch current state: $entityId"
    $state = Get-EntityState -EntityId $entityId
    $currentStates.Add($state)

    if ($schedulerSnapshotEntities -contains $entityId) {
        $schedulerSnapshot.Add($state)
    }
}

foreach ($entityId in $historyEntities) {
    Write-Log "Fetch history: $entityId"
    $history = Get-EntityHistory -EntityId $entityId -StartIso $window.Start -EndIso $window.End
    $safeName = New-SafeFileName -EntityId $entityId
    Save-JsonFile -FileName "${safeName}_history.json" -Data $history
}

Write-Log "Fetch logbook window"
$logbookWindow = Get-LogbookWindow -StartIso $window.Start -EndIso $window.End
if ($logbookWindow -is [System.Collections.IEnumerable] -and -not ($logbookWindow -is [string])) {
    $relevantLogbook = Get-RelevantLogbookEntries -Entries $logbookWindow -EntityIds $allCurrentEntities
    Save-JsonFile -FileName "logbook_relevant.json" -Data $relevantLogbook
    $relevantLogbookCount = $relevantLogbook.Count
}
else {
    Save-JsonFile -FileName "logbook_relevant.json" -Data $logbookWindow
    $relevantLogbookCount = 0
}

Save-JsonFile -FileName "entity_manifest.json" -Data $manifest
Save-JsonFile -FileName "current_states.json" -Data $currentStates
Save-JsonFile -FileName "schedule_snapshot.json" -Data $schedulerSnapshot
Save-TextFile -FileName "README.txt" -Content (Build-Readme -Window $window -Manifest $manifest -CurrentStates $currentStates -RelevantLogbookCount $relevantLogbookCount)

Write-Log "Roborock debug capture v2 completed"
