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
    ),
    [string]$Environment = "live",
    [switch]$ChangedSinceLastDeploy,
    [switch]$AllowDirtyWorktree,
    [string]$RequireBranch = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message)

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$timestamp] $Message"
    Write-Host $line

    if (-not [string]::IsNullOrWhiteSpace($LogFile)) {
        Add-Content -LiteralPath $LogFile -Value $line
    }
}

function Assert-PathExists {
    param([string]$Path, [string]$Label)

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "$Label does not exist: $Path"
    }
}

function Invoke-Git {
    param([string[]]$Arguments)

    $output = & git -C $SourceRoot @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Git command failed: git -C $SourceRoot $($Arguments -join ' ')`n$output"
    }

    if ($null -eq $output) {
        return @()
    }

    if ($output -is [System.Array]) {
        return $output
    }

    return @([string]$output)
}

function Get-NormalizedRootPath {
    param([string]$Path)

    $fullPath = [System.IO.Path]::GetFullPath($Path)
    return $fullPath.TrimEnd("\")
}

function Resolve-RepoRelativePath {
    param([string]$RelativePath)

    if ([string]::IsNullOrWhiteSpace($RelativePath)) {
        throw "Empty path values are not allowed."
    }

    if ([System.IO.Path]::IsPathRooted($RelativePath)) {
        throw "Absolute paths are not allowed: $RelativePath"
    }

    $candidatePath = Join-Path $SourceRoot $RelativePath
    $resolvedPath = [System.IO.Path]::GetFullPath($candidatePath)
    $rootWithSeparator = $script:NormalizedSourceRoot + "\"

    if (($resolvedPath -ne $script:NormalizedSourceRoot) -and (-not $resolvedPath.StartsWith($rootWithSeparator, [System.StringComparison]::OrdinalIgnoreCase))) {
        throw "Path escapes the repository root: $RelativePath"
    }

    return $resolvedPath
}

function Get-RelativePathForState {
    param([string]$RelativePath)

    return ($RelativePath -replace "\\", "/").Trim()
}

function Test-YamlExtension {
    param([string]$Path)

    return [System.IO.Path]::GetExtension($Path) -in @(".yaml", ".yml")
}

function Get-ParentRelativePath {
    param([string]$RelativePath)

    $windowsPath = ($RelativePath -replace "/", "\").Trim("\")
    if ([string]::IsNullOrWhiteSpace($windowsPath)) {
        return ""
    }

    $parent = Split-Path -Path $windowsPath -Parent
    if ([string]::IsNullOrWhiteSpace($parent) -or $parent -eq ".") {
        return ""
    }

    return Get-RelativePathForState -RelativePath $parent
}

function Test-YamlOnlyDirectory {
    param([string]$RelativeDirectoryPath)

    if ([string]::IsNullOrWhiteSpace($RelativeDirectoryPath)) {
        return $false
    }

    $resolvedPath = Resolve-RepoRelativePath -RelativePath $RelativeDirectoryPath
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Container)) {
        return $false
    }

    $files = @(Get-ChildItem -LiteralPath $resolvedPath -Recurse -File)
    if ($files.Count -eq 0) {
        return $false
    }

    $invalidFiles = @(
        $files | Where-Object {
            [System.IO.Path]::GetExtension($_.Name) -notin @(".yaml", ".yml")
        }
    )

    return $invalidFiles.Count -eq 0
}

function Assert-YamlOnlyPath {
    param([string]$RelativePath)

    $resolvedPath = Resolve-RepoRelativePath -RelativePath $RelativePath
    Assert-PathExists -Path $resolvedPath -Label "Deploy path"

    $item = Get-Item -LiteralPath $resolvedPath
    if (-not $item.PSIsContainer) {
        $extension = [System.IO.Path]::GetExtension($item.Name)
        if ($extension -notin @(".yaml", ".yml")) {
            throw "Non-YAML file is not deployable: $RelativePath"
        }
        return
    }

    $files = Get-ChildItem -LiteralPath $resolvedPath -Recurse -File
    if ($files.Count -eq 0) {
        throw "Directory does not contain any files: $RelativePath"
    }

    $invalidFiles = @(
        $files | Where-Object {
            [System.IO.Path]::GetExtension($_.Name) -notin @(".yaml", ".yml")
        }
    )

    if ($invalidFiles.Count -gt 0) {
        $samplePaths = $invalidFiles |
            Select-Object -First 5 |
            ForEach-Object { $_.FullName.Substring($script:NormalizedSourceRoot.Length + 1) -replace "\\", "/" }

        throw "Directory contains non-YAML files and cannot be deployed as-is: $RelativePath`n$($samplePaths -join "`n")"
    }
}

function Get-DeployStatePath {
    $stateDirectory = Join-Path $SourceRoot ".deploy-state"
    return Join-Path $stateDirectory ($Environment + ".toml")
}

function Get-DeployStateValue {
    param(
        [string]$Content,
        [string]$Key
    )

    $pattern = '(?m)^\s*' + [Regex]::Escape($Key) + '\s*=\s*"(?<value>(?:[^"\\]|\\.)*)"\s*$'
    $match = [Regex]::Match($Content, $pattern)
    if (-not $match.Success) {
        return $null
    }

    $value = $match.Groups["value"].Value
    $value = $value -replace '\\\\', '\'
    $value = $value -replace '\\"', '"'
    return $value
}

function Add-UniquePath {
    param(
        [System.Collections.Generic.List[string]]$List,
        [System.Collections.Generic.HashSet[string]]$Seen,
        [string]$Value
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return
    }

    if ($Seen.Add($Value)) {
        $null = $List.Add($Value)
    }
}

function Get-SafeDeletedPathSuggestion {
    param([string]$RelativePath)

    $currentParent = Get-ParentRelativePath -RelativePath $RelativePath
    while (-not [string]::IsNullOrWhiteSpace($currentParent)) {
        if (Test-YamlOnlyDirectory -RelativeDirectoryPath $currentParent) {
            return $currentParent
        }
        $currentParent = Get-ParentRelativePath -RelativePath $currentParent
    }

    return $null
}

function Show-ChangedSinceLastDeployPreview {
    param(
        [string]$CurrentCommit,
        [bool]$DirtyWorktree
    )

    $statePath = Get-DeployStatePath
    Assert-PathExists -Path $statePath -Label "Deploy state"

    $stateContent = Get-Content -LiteralPath $statePath -Raw
    $lastDeployCommit = Get-DeployStateValue -Content $stateContent -Key "commit"
    if ([string]::IsNullOrWhiteSpace($lastDeployCommit)) {
        throw "Deploy state does not contain a commit value: $statePath"
    }

    $lastDeployCommit = $lastDeployCommit.Trim()
    $null = Invoke-Git -Arguments @("cat-file", "-e", "$lastDeployCommit^{commit}")

    Write-Log "Changed-since-last-deploy preview"
    Write-Log "Environment: $Environment"
    Write-Log "Last successful deploy commit: $lastDeployCommit"
    Write-Log "Current HEAD commit: $CurrentCommit"
    Write-Log "Dirty worktree: $DirtyWorktree"

    if ($DirtyWorktree) {
        Write-Log "Note: uncommitted changes are not included in this preview"
    }

    $diffLines = @(
        Invoke-Git -Arguments @("diff", "--name-status", "--find-renames", "$lastDeployCommit..HEAD")
    )

    $changedYamlItems = [System.Collections.Generic.List[string]]::new()
    $existingYamlFiles = [System.Collections.Generic.List[string]]::new()
    $deletedYamlPaths = [System.Collections.Generic.List[string]]::new()

    foreach ($line in $diffLines) {
        if ([string]::IsNullOrWhiteSpace($line)) {
            continue
        }

        $parts = $line -split "`t"
        if ($parts.Count -lt 2) {
            continue
        }

        $statusToken = $parts[0].Trim()
        if ([string]::IsNullOrWhiteSpace($statusToken)) {
            continue
        }

        $statusCode = $statusToken.Substring(0, 1)

        switch ($statusCode) {
            "A" {
                $path = Get-RelativePathForState -RelativePath $parts[1]
                if (Test-YamlExtension -Path $path) {
                    $null = $changedYamlItems.Add("A $path")
                    $null = $existingYamlFiles.Add($path)
                }
            }
            "C" {
                if ($parts.Count -ge 3) {
                    $sourcePath = Get-RelativePathForState -RelativePath $parts[1]
                    $targetPath = Get-RelativePathForState -RelativePath $parts[2]
                    if (Test-YamlExtension -Path $targetPath) {
                        $null = $changedYamlItems.Add("C $sourcePath -> $targetPath")
                        $null = $existingYamlFiles.Add($targetPath)
                    }
                }
                else {
                    $path = Get-RelativePathForState -RelativePath $parts[1]
                    if (Test-YamlExtension -Path $path) {
                        $null = $changedYamlItems.Add("C $path")
                        $null = $existingYamlFiles.Add($path)
                    }
                }
            }
            "D" {
                $path = Get-RelativePathForState -RelativePath $parts[1]
                if (Test-YamlExtension -Path $path) {
                    $null = $changedYamlItems.Add("D $path")
                    $null = $deletedYamlPaths.Add($path)
                }
            }
            "M" {
                $path = Get-RelativePathForState -RelativePath $parts[1]
                if (Test-YamlExtension -Path $path) {
                    $null = $changedYamlItems.Add("M $path")
                    $null = $existingYamlFiles.Add($path)
                }
            }
            "R" {
                if ($parts.Count -lt 3) {
                    continue
                }

                $oldPath = Get-RelativePathForState -RelativePath $parts[1]
                $newPath = Get-RelativePathForState -RelativePath $parts[2]

                if ((Test-YamlExtension -Path $oldPath) -or (Test-YamlExtension -Path $newPath)) {
                    $null = $changedYamlItems.Add("R $oldPath -> $newPath")
                }

                if (Test-YamlExtension -Path $oldPath) {
                    $null = $deletedYamlPaths.Add($oldPath)
                }

                if (Test-YamlExtension -Path $newPath) {
                    $null = $existingYamlFiles.Add($newPath)
                }
            }
        }
    }

    if ($changedYamlItems.Count -eq 0) {
        Write-Log "No committed YAML changes since the last successful guarded deploy."
        return
    }

    Write-Log "Committed YAML changes since last deploy: $($changedYamlItems.Count)"
    foreach ($item in $changedYamlItems) {
        Write-Log "CHANGE  $item"
    }

    $suggestions = [System.Collections.Generic.List[string]]::new()
    $seenSuggestions = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

    $existingFileGroups = $existingYamlFiles |
        Sort-Object -Unique |
        Group-Object { Get-ParentRelativePath -RelativePath $_ }

    foreach ($group in $existingFileGroups) {
        $parentPath = [string]$group.Name
        $groupFiles = @($group.Group | Sort-Object -Unique)

        if (
            $groupFiles.Count -gt 1 -and
            -not [string]::IsNullOrWhiteSpace($parentPath) -and
            (Test-YamlOnlyDirectory -RelativeDirectoryPath $parentPath)
        ) {
            Add-UniquePath -List $suggestions -Seen $seenSuggestions -Value $parentPath
            continue
        }

        foreach ($filePath in $groupFiles) {
            Add-UniquePath -List $suggestions -Seen $seenSuggestions -Value $filePath
        }
    }

    $unresolvedPaths = [System.Collections.Generic.List[string]]::new()
    foreach ($deletedPath in ($deletedYamlPaths | Sort-Object -Unique)) {
        $suggestedDirectory = Get-SafeDeletedPathSuggestion -RelativePath $deletedPath
        if ([string]::IsNullOrWhiteSpace($suggestedDirectory)) {
            $null = $unresolvedPaths.Add($deletedPath)
            continue
        }

        Add-UniquePath -List $suggestions -Seen $seenSuggestions -Value $suggestedDirectory
    }

    if ($suggestions.Count -eq 0) {
        Write-Log "No safe automatic YAML deploy suggestions could be derived."
    }
    else {
        Write-Log "Suggested guarded deploy paths:"
        foreach ($suggestion in $suggestions) {
            Write-Log "SUGGEST $suggestion"
        }
    }

    if ($unresolvedPaths.Count -gt 0) {
        Write-Log "Manual review required for YAML deletions/renames without a safe directory suggestion:"
        foreach ($path in $unresolvedPaths) {
            Write-Log "UNRESOLVED $path"
        }
    }
}

function Convert-ToTomlString {
    param([AllowNull()][string]$Value)

    if ($null -eq $Value) {
        return '""'
    }

    $escapedValue = $Value.Replace("\", "\\").Replace('"', '\"')
    return '"' + $escapedValue + '"'
}

function Convert-ToTomlArray {
    param([string[]]$Values)

    if ($null -eq $Values -or $Values.Count -eq 0) {
        return "[]"
    }

    $quotedValues = foreach ($value in $Values) {
        Convert-ToTomlString -Value $value
    }

    return "[" + ($quotedValues -join ", ") + "]"
}

function Get-DeployMode {
    $modeParts = [System.Collections.Generic.List[string]]::new()

    if ($Backup) {
        $null = $modeParts.Add("backup")
    }
    if ($DeleteRemoved) {
        $null = $modeParts.Add("delete-removed")
    }
    if ($PostReload) {
        $null = $modeParts.Add("postreload")
    }
    if ($HealthCheck) {
        $null = $modeParts.Add("healthcheck")
    }
    if ($StrictModeDeploy) {
        $null = $modeParts.Add("strict")
    }

    if ($modeParts.Count -eq 0) {
        return "copy-only"
    }

    return ($modeParts -join "+")
}

function Write-DeployState {
    param(
        [string]$Branch,
        [string]$Commit,
        [bool]$DirtyWorktree,
        [string[]]$DeployPaths
    )

    $stateDirectory = Join-Path $SourceRoot ".deploy-state"
    $statePath = Join-Path $stateDirectory ($Environment + ".toml")
    $tempPath = $statePath + ".tmp"

    if (-not (Test-Path -LiteralPath $stateDirectory)) {
        New-Item -ItemType Directory -Path $stateDirectory -Force | Out-Null
    }

    $utcNow = (Get-Date).ToUniversalTime()
    $localNow = Get-Date
    $shortCommitLength = [Math]::Min(7, $Commit.Length)
    $shortCommit = $Commit.Substring(0, $shortCommitLength)
    $normalizedPaths = @($DeployPaths | ForEach-Object { Get-RelativePathForState -RelativePath $_ })
    $operator = if ([string]::IsNullOrWhiteSpace($env:USERNAME)) { "unknown" } else { $env:USERNAME }

    $content = @(
        "environment = $(Convert-ToTomlString -Value $Environment)"
        "repo_root = $(Convert-ToTomlString -Value $script:NormalizedSourceRoot)"
        "ha_config_root = $(Convert-ToTomlString -Value $HaConfigRoot)"
        "last_success_utc = $(Convert-ToTomlString -Value $utcNow.ToString("o"))"
        "last_success_local = $(Convert-ToTomlString -Value $localNow.ToString("yyyy-MM-dd HH:mm:ss zzz"))"
        "branch = $(Convert-ToTomlString -Value $Branch)"
        "commit = $(Convert-ToTomlString -Value $Commit)"
        "commit_short = $(Convert-ToTomlString -Value $shortCommit)"
        "dirty_worktree = $($DirtyWorktree.ToString().ToLowerInvariant())"
        "paths = $(Convert-ToTomlArray -Values $normalizedPaths)"
        "content_policy = ""yaml-only"""
        "deploy_mode = $(Convert-ToTomlString -Value (Get-DeployMode))"
        "operator = $(Convert-ToTomlString -Value $operator)"
    )

    Set-Content -LiteralPath $tempPath -Value $content -Encoding UTF8
    Move-Item -LiteralPath $tempPath -Destination $statePath -Force
}

try {
    Assert-PathExists -Path $SourceRoot -Label "Source root"

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        throw "Git is required on PATH for deploy_ha_git_guard.ps1."
    }

    if ($ChangedSinceLastDeploy -and $Paths.Count -gt 0) {
        throw "-ChangedSinceLastDeploy is a preview-only mode and must not be combined with -Paths."
    }

    if (-not $ChangedSinceLastDeploy -and $Paths.Count -eq 0) {
        throw "No -Paths specified. Refusing to deploy without explicit YAML paths."
    }

    $script:NormalizedSourceRoot = Get-NormalizedRootPath -Path $SourceRoot
    $repoTopLevel = (Invoke-Git -Arguments @("rev-parse", "--show-toplevel") | Select-Object -First 1).Trim()
    if ((Get-NormalizedRootPath -Path $repoTopLevel) -ne $script:NormalizedSourceRoot) {
        throw "SourceRoot must point at the repository root. Expected $repoTopLevel but got $SourceRoot"
    }

    $branch = (Invoke-Git -Arguments @("rev-parse", "--abbrev-ref", "HEAD") | Select-Object -First 1).Trim()
    $commit = (Invoke-Git -Arguments @("rev-parse", "HEAD") | Select-Object -First 1).Trim()
    $dirtyStatus = @(Invoke-Git -Arguments @("status", "--short"))
    $dirtyWorktree = $dirtyStatus.Count -gt 0

    if (-not [string]::IsNullOrWhiteSpace($RequireBranch) -and $branch -ne $RequireBranch) {
        throw "Current branch '$branch' does not match required branch '$RequireBranch'."
    }

    if ($ChangedSinceLastDeploy) {
        Show-ChangedSinceLastDeployPreview -CurrentCommit $commit -DirtyWorktree $dirtyWorktree
        return
    }

    if ($dirtyWorktree -and -not $AllowDirtyWorktree) {
        throw "Worktree is dirty. Commit or stash changes first, or rerun with -AllowDirtyWorktree."
    }

    foreach ($relativePath in $Paths) {
        Assert-YamlOnlyPath -RelativePath $relativePath
    }

    Write-Log "Deploy guard start"
    Write-Log "Environment: $Environment"
    Write-Log "Branch: $branch"
    Write-Log "Commit: $commit"
    Write-Log "Dirty worktree: $dirtyWorktree"
    Write-Log "YAML path count: $($Paths.Count)"

    $deployScriptPath = Join-Path $SourceRoot "deploy_ha_samba_healthcheck.ps1"
    Assert-PathExists -Path $deployScriptPath -Label "Deploy script"
    Assert-PathExists -Path $HaConfigRoot -Label "Home Assistant config root"

    $deployParameters = @{
        SourceRoot      = $SourceRoot
        HaConfigRoot    = $HaConfigRoot
        Paths           = $Paths
        Backup          = $Backup
        WhatIf          = $WhatIf
        DeleteRemoved   = $DeleteRemoved
        BackupRoot      = $BackupRoot
        LogFile         = $LogFile
        HealthCheck     = $HealthCheck
        HaUrl           = $HaUrl
        HaToken         = $HaToken
        CheckEntities   = $CheckEntities
        StrictModeDeploy = $StrictModeDeploy
        DiffOnly        = $DiffOnly
        PostReload      = $PostReload
        ReloadServices  = $ReloadServices
    }

    & $deployScriptPath @deployParameters
    if ($LASTEXITCODE -ne 0) {
        throw "Deploy script failed with exit code $LASTEXITCODE."
    }

    if (-not $DiffOnly -and -not $WhatIf) {
        Write-DeployState -Branch $branch -Commit $commit -DirtyWorktree $dirtyWorktree -DeployPaths $Paths
        Write-Log "Deploy state updated for environment: $Environment"
    }
    else {
        Write-Log "Skip deploy state update in WhatIf/DiffOnly mode"
    }
}
catch {
    Write-Error $_
    exit 1
}
