param(
    [string]$SourceRoot = "D:\Codex",
    [string]$HaConfigRoot = "\\homeassistant\config",
    [string[]]$Paths = @(),
    [switch]$Backup,
    [switch]$WhatIf,
    [switch]$DeleteRemoved,
    [string]$BackupRoot = "",
    [string]$LogFile = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $line = "[$timestamp] $Message"
    Write-Host $line
    if (-not [string]::IsNullOrWhiteSpace($LogFile)) {
        Add-Content -Path $LogFile -Value $line
    }
}

function Assert-PathExists {
    param([string]$Path, [string]$Label)
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "$Label does not exist: $Path"
    }
}

function New-BackupPath {
    param([string]$RelativePath)
    $stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $safeRelative = $RelativePath -replace ':', '_' -replace '[\\/]+', '\\'
    return Join-Path $BackupRoot (Join-Path $stamp $safeRelative)
}

function Ensure-ParentDirectory {
    param([string]$Path)
    $parent = Split-Path -Path $Path -Parent
    if (-not [string]::IsNullOrWhiteSpace($parent) -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
}

function Copy-WithOptionalBackup {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$RelativePath
    )

    if ((Test-Path -LiteralPath $Destination -PathType Leaf) -and $Backup) {
        $backupPath = New-BackupPath -RelativePath $RelativePath
        Ensure-ParentDirectory -Path $backupPath
        Write-Log "Backing up file: $RelativePath"
        if (-not $WhatIf) {
            Copy-Item -LiteralPath $Destination -Destination $backupPath -Force
        }
    }

    Ensure-ParentDirectory -Path $Destination
    Write-Log "Copy file: $RelativePath"
    if (-not $WhatIf) {
        Copy-Item -LiteralPath $Source -Destination $Destination -Force
    }
}

function Mirror-Directory {
    param(
        [string]$SourceDir,
        [string]$TargetDir,
        [string]$RelativeRoot
    )

    Assert-PathExists -Path $SourceDir -Label 'Source directory'

    if (-not (Test-Path -LiteralPath $TargetDir)) {
        Write-Log "Create directory: $RelativeRoot"
        if (-not $WhatIf) {
            New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
        }
    }

    $sourceFiles = Get-ChildItem -LiteralPath $SourceDir -Recurse -File
    foreach ($file in $sourceFiles) {
        $relative = $file.FullName.Substring($SourceDir.Length).TrimStart('\\')
        $relativePath = if ([string]::IsNullOrWhiteSpace($RelativeRoot)) { $relative } else { Join-Path $RelativeRoot $relative }
        $destFile = Join-Path $TargetDir $relative
        Copy-WithOptionalBackup -Source $file.FullName -Destination $destFile -RelativePath $relativePath
    }

    if ($DeleteRemoved) {
        $targetFiles = @()
        if (Test-Path -LiteralPath $TargetDir) {
            $targetFiles = Get-ChildItem -LiteralPath $TargetDir -Recurse -File
        }
        foreach ($targetFile in $targetFiles) {
            $relative = $targetFile.FullName.Substring($TargetDir.Length).TrimStart('\\')
            $sourceEquivalent = Join-Path $SourceDir $relative
            if (-not (Test-Path -LiteralPath $sourceEquivalent)) {
                $relativePath = if ([string]::IsNullOrWhiteSpace($RelativeRoot)) { $relative } else { Join-Path $RelativeRoot $relative }
                if ($Backup) {
                    $backupPath = New-BackupPath -RelativePath $relativePath
                    Ensure-ParentDirectory -Path $backupPath
                    Write-Log "Backing up removed file: $relativePath"
                    if (-not $WhatIf) {
                        Copy-Item -LiteralPath $targetFile.FullName -Destination $backupPath -Force
                    }
                }
                Write-Log "Delete removed file: $relativePath"
                if (-not $WhatIf) {
                    Remove-Item -LiteralPath $targetFile.FullName -Force
                }
            }
        }
    }
}

function Deploy-Path {
    param([string]$RelativePath)

    $sourcePath = Join-Path $SourceRoot $RelativePath
    $destPath = Join-Path $HaConfigRoot $RelativePath

    if (-not (Test-Path -LiteralPath $sourcePath)) {
        throw "Source path not found: $sourcePath"
    }

    $item = Get-Item -LiteralPath $sourcePath
    if ($item.PSIsContainer) {
        Mirror-Directory -SourceDir $sourcePath -TargetDir $destPath -RelativeRoot $RelativePath
    }
    else {
        Copy-WithOptionalBackup -Source $sourcePath -Destination $destPath -RelativePath $RelativePath
    }
}

try {
    Assert-PathExists -Path $SourceRoot -Label 'Source root'
    Assert-PathExists -Path $HaConfigRoot -Label 'Home Assistant config root'

    if ([string]::IsNullOrWhiteSpace($BackupRoot)) {
        $BackupRoot = Join-Path $HaConfigRoot 'backup_deploy'
    }

    if ($Paths.Count -eq 0) {
        throw "No -Paths specified. Refusing to deploy with implicit defaults."
    }

    if ($Backup -and -not $WhatIf -and -not (Test-Path -LiteralPath $BackupRoot)) {
        New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null
    }

    Write-Log "Deploy start"
    Write-Log "Source root: $SourceRoot"
    Write-Log "HA config root: $HaConfigRoot"
    Write-Log "Backup enabled: $Backup"
    Write-Log "WhatIf mode: $WhatIf"
    Write-Log "DeleteRemoved: $DeleteRemoved"

    foreach ($relativePath in $Paths) {
        Write-Log "Deploy path: $relativePath"
        Deploy-Path -RelativePath $relativePath
    }

    Write-Log 'Deploy finished successfully'
}
catch {
    Write-Error $_
    exit 1
}
