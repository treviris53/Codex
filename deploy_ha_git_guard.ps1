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

    if ($Paths.Count -eq 0) {
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
