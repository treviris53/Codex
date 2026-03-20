param(
    [string]$HaConfigRoot = "W:\",
    [string]$LocalSnapshotRoot = "D:\Codex\_ha_runtime_snapshot",
    [string[]]$Files = @(
        "core.entity_registry",
        "core.device_registry",
        "core.config_entries",
        "core.restore_state"
    ),
    [switch]$Backup,
    [switch]$WhatIf
)

function Log($msg) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$ts] $msg"
}

$sourceStorage = Join-Path $HaConfigRoot ".storage"
$targetStorage = Join-Path $LocalSnapshotRoot ".storage"

Log "HA source: $sourceStorage"
Log "Local target: $targetStorage"

if (!(Test-Path $sourceStorage)) {
    throw "HA .storage path not found: $sourceStorage"
}

if (!(Test-Path $targetStorage)) {
    Log "Creating local snapshot directory"
    if (-not $WhatIf) {
        New-Item -ItemType Directory -Path $targetStorage -Force | Out-Null
    }
}

foreach ($file in $Files) {
    $src = Join-Path $sourceStorage $file
    $dst = Join-Path $targetStorage $file

    if (!(Test-Path $src)) {
        Log "SKIP (not found): $file"
        continue
    }

    if ($Backup -and (Test-Path $dst)) {
        $backupDir = Join-Path $LocalSnapshotRoot "backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        $backupPath = Join-Path $backupDir $file

        Log "Backup: $file"
        if (-not $WhatIf) {
            New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
            Copy-Item $dst $backupPath -Force
        }
    }

    Log "Copy: $file"
    if (-not $WhatIf) {
        Copy-Item $src $dst -Force
    }
}

Log "Snapshot sync completed"