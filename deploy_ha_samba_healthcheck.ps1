param(
    [string]$SourceRoot = "D:\Codex",
    [string]$HaConfigRoot = "W:\",
    [string[]]$Paths = @(),
    [switch]$Backup,
    [switch]$WhatIf,
    [switch]$DeleteRemoved,
    [string]$BackupRoot = "",
    [string]$LogFile = "",
    [switch]$HealthCheck,
    [string]$HaUrl = "",
    [string]$HaToken = "",
    [string[]]$CheckEntities = @(
        "input_boolean.roborock_busy",
        "input_datetime.roborock_busy_since",
        "input_boolean.roborock_schedule_enabled"
    ),
    [switch]$StrictModeDeploy,
    [switch]$DiffOnly,
    [switch]$PostReload,
    [string[]]$ReloadServices = @(
        "automation.reload",
        "script.reload"
    )
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
    $safeRelative = $RelativePath -replace ':', '_' -replace '[\\/]+', '\'
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
        $relative = $file.FullName.Substring($SourceDir.Length).TrimStart('\')
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
            $relative = $targetFile.FullName.Substring($TargetDir.Length).TrimStart('\')
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

function Get-FileHashSafe {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return $null
    }
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
}

function Show-DiffSummary {
    param([string]$RelativePath)

    $sourcePath = Join-Path $SourceRoot $RelativePath
    $destPath = Join-Path $HaConfigRoot $RelativePath

    if (-not (Test-Path -LiteralPath $sourcePath)) {
        throw "Source path not found: $sourcePath"
    }

    $item = Get-Item -LiteralPath $sourcePath
    if ($item.PSIsContainer) {
        Write-Log "Diff directory: $RelativePath"
        $sourceFiles = Get-ChildItem -LiteralPath $sourcePath -Recurse -File
        $seen = @{}

        foreach ($file in $sourceFiles) {
            $relative = $file.FullName.Substring($sourcePath.Length).TrimStart('\')
            $destFile = Join-Path $destPath $relative
            $seen[$relative] = $true
            if (-not (Test-Path -LiteralPath $destFile -PathType Leaf)) {
                Write-Log "ADD    $RelativePath\$relative"
                continue
            }
            $srcHash = Get-FileHashSafe -Path $file.FullName
            $dstHash = Get-FileHashSafe -Path $destFile
            if ($srcHash -ne $dstHash) {
                Write-Log "CHANGE $RelativePath\$relative"
            }
        }

        if ($DeleteRemoved -and (Test-Path -LiteralPath $destPath)) {
            $targetFiles = Get-ChildItem -LiteralPath $destPath -Recurse -File
            foreach ($targetFile in $targetFiles) {
                $relative = $targetFile.FullName.Substring($destPath.Length).TrimStart('\')
                if (-not $seen.ContainsKey($relative)) {
                    Write-Log "DELETE $RelativePath\$relative"
                }
            }
        }
    }
    else {
        $srcHash = Get-FileHashSafe -Path $sourcePath
        $dstHash = Get-FileHashSafe -Path $destPath
        if (-not (Test-Path -LiteralPath $destPath -PathType Leaf)) {
            Write-Log "ADD    $RelativePath"
        }
        elseif ($srcHash -ne $dstHash) {
            Write-Log "CHANGE $RelativePath"
        }
        else {
            Write-Log "SAME   $RelativePath"
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

function Get-HaHeaders {
    if ([string]::IsNullOrWhiteSpace($HaToken)) {
        throw "HaToken is required for API operations."
    }
    return @{
        Authorization = "Bearer $HaToken"
        "Content-Type" = "application/json"
    }
}

function Invoke-HaHealthCheck {
    if (-not $HealthCheck) {
        return
    }

    if ($WhatIf -or $DiffOnly) {
        Write-Log "Skip health check in WhatIf/DiffOnly mode"
        return
    }

    $headers = Get-HaHeaders
    $apiUrl = ($HaUrl.TrimEnd('/')) + "/api/"
    Write-Log "Health check: GET $apiUrl"
    $apiResult = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get
    Write-Log "Health check ok: $($apiResult.message)"

    foreach ($entityId in $CheckEntities) {
        $stateUrl = ($HaUrl.TrimEnd('/')) + "/api/states/$entityId"
        try {
            $stateResult = Invoke-RestMethod -Uri $stateUrl -Headers $headers -Method Get
            Write-Log "Entity ok: $entityId = $($stateResult.state)"
        }
        catch {
            Write-Log "Entity missing or unreadable: $entityId"
            throw
        }
    }
}

function Invoke-HaReloads {
    if (-not $PostReload) {
        return
    }

    if ($WhatIf -or $DiffOnly) {
        Write-Log "Skip reload in WhatIf/DiffOnly mode"
        return
    }

    $headers = Get-HaHeaders

    foreach ($serviceName in $ReloadServices) {
        if ($serviceName -notmatch '^[^\.]+\.[^\.]+$') {
            throw "Invalid reload service format: $serviceName"
        }
        $domain, $service = $serviceName -split '\.', 2
        $serviceUrl = ($HaUrl.TrimEnd('/')) + "/api/services/$domain/$service"
        Write-Log "Post reload: POST $serviceUrl"
        Invoke-RestMethod -Uri $serviceUrl -Headers $headers -Method Post -Body "{}" | Out-Null
        Write-Log "Reload ok: $serviceName"
    }
}

try {
    Assert-PathExists -Path $SourceRoot -Label 'Source root'
    Assert-PathExists -Path $HaConfigRoot -Label 'Home Assistant config root'
        # --- HA ENV FALLBACK ---
    if ([string]::IsNullOrWhiteSpace($HaUrl)) {
        $HaUrl = $env:HA_URL
    }

    if ([string]::IsNullOrWhiteSpace($HaToken)) {
        $HaToken = $env:HA_TOKEN
    }

    # --- VALIDATION (nur wenn benötigt) ---
    if (($HealthCheck -or $PostReload) -and [string]::IsNullOrWhiteSpace($HaUrl)) {
        throw "HA URL missing (parameter or env:HA_URL)"
    }

    if (($HealthCheck -or $PostReload) -and [string]::IsNullOrWhiteSpace($HaToken)) {
        throw "HA token missing (parameter or env:HA_TOKEN)"
    }

    if ([string]::IsNullOrWhiteSpace($BackupRoot)) {
        $BackupRoot = Join-Path $HaConfigRoot 'backup_deploy'
    }

    if ($Paths.Count -eq 0) {
        throw "No -Paths specified. Refusing to deploy with implicit defaults."
    }

    if ($StrictModeDeploy) {
        if (-not $Backup) {
            throw "StrictModeDeploy requires -Backup."
        }
        if ($WhatIf) {
            throw "StrictModeDeploy does not allow -WhatIf."
        }
    }

    if ($Backup -and -not $WhatIf -and -not $DiffOnly -and -not (Test-Path -LiteralPath $BackupRoot)) {
        New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null
    }

    Write-Log "Deploy start"
    Write-Log "Source root: $SourceRoot"
    Write-Log "HA config root: $HaConfigRoot"
    Write-Log "Backup root: $BackupRoot"
    Write-Log "Backup enabled: $Backup"
    Write-Log "WhatIf mode: $WhatIf"
    Write-Log "DeleteRemoved: $DeleteRemoved"
    Write-Log "HealthCheck: $HealthCheck"
    Write-Log "StrictModeDeploy: $StrictModeDeploy"
    Write-Log "DiffOnly: $DiffOnly"
    Write-Log "PostReload: $PostReload"

    foreach ($relativePath in $Paths) {
        Write-Log "Deploy path: $relativePath"
        if ($DiffOnly) {
            Show-DiffSummary -RelativePath $relativePath
        }
        else {
            Deploy-Path -RelativePath $relativePath
        }
    }

    if (-not $DiffOnly) {
        Invoke-HaReloads
        Invoke-HaHealthCheck
    }

    Write-Log 'Deploy finished successfully'
}
catch {
    Write-Error $_
    exit 1
}
