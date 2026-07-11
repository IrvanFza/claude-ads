#Requires -Version 5.1
<#
.SYNOPSIS
    Claude Ads Installer for Windows (multi-host).
.DESCRIPTION
    Installs the Claude Ads skill, sub-skills, agents, and reference files
    for Claude Code (default) or any of the supported experimental host CLIs.

    Targets:
      claude     Claude Code (verified)
      codex      OpenAI Codex CLI (experimental)
      cursor     Cursor IDE (experimental)
      windsurf   Windsurf IDE (experimental)
      gemini     Gemini CLI (experimental)
      goose      Goose CLI (experimental)
.PARAMETER Target
    Which host CLI to install for. Default: claude.
.PARAMETER SkillDir
    Override the target's default skill install root.
.PARAMETER AgentDir
    Override the target's default agent install root.
.EXAMPLE
    .\install.ps1
.EXAMPLE
    .\install.ps1 -Target codex
.EXAMPLE
    .\install.ps1 -SkillDir C:\Custom\Skills
.NOTES
    Prefer a host-native plugin install or a signed release archive after
    verifying its SHA-256 checksum. Never pipe remote content to PowerShell.
#>

param(
    [ValidateSet('claude','codex','cursor','windsurf','gemini','goose')]
    [string]$Target = 'claude',
    [string]$SkillDir = '',
    [string]$AgentDir = '',
    [ValidateSet('auto','local','git')]
    [string]$Source = 'auto',
    [string]$RepoDir = '',
    [switch]$NoDeps
)

$ErrorActionPreference = "Stop"

function Get-ClaudeAdsUserHome {
    if (-not [string]::IsNullOrWhiteSpace($env:USERPROFILE)) { return $env:USERPROFILE }
    if (-not [string]::IsNullOrWhiteSpace($HOME)) { return $HOME }
    $ProfileHome = [Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile)
    if (-not [string]::IsNullOrWhiteSpace($ProfileHome)) { return $ProfileHome }
    throw "Cannot determine the current user's home directory."
}

function Resolve-TargetPaths {
    param([string]$T)
    $UserHome = Get-ClaudeAdsUserHome
    switch ($T) {
        'claude' {
            return @{
                SkillBase = Join-Path $UserHome ".claude\skills"
                AgentDir  = Join-Path $UserHome ".claude\agents"
                AllowPip  = $true
                Label     = "Claude Code"
            }
        }
        'codex' {
            return @{
                SkillBase = Join-Path $UserHome ".codex\skills"
                AgentDir  = Join-Path $UserHome ".codex\agents"
                AllowPip  = $true
                Label     = "OpenAI Codex CLI"
            }
        }
        'cursor' {
            return @{
                SkillBase = Join-Path $UserHome ".cursor\extensions\claude-ads\skills"
                AgentDir  = Join-Path $UserHome ".cursor\extensions\claude-ads\agents"
                AllowPip  = $false
                Label     = "Cursor IDE"
            }
        }
        'windsurf' {
            return @{
                SkillBase = Join-Path $UserHome ".windsurf\skills"
                AgentDir  = Join-Path $UserHome ".windsurf\agents"
                AllowPip  = $false
                Label     = "Windsurf IDE"
            }
        }
        'gemini' {
            return @{
                SkillBase = Join-Path $UserHome ".gemini\extensions\claude-ads\skills"
                AgentDir  = Join-Path $UserHome ".gemini\extensions\claude-ads\agents"
                AllowPip  = $false
                Label     = "Gemini CLI"
            }
        }
        'goose' {
            return @{
                SkillBase = Join-Path $UserHome ".config\goose\skills"
                AgentDir  = Join-Path $UserHome ".config\goose\agents"
                AllowPip  = $false
                Label     = "Goose CLI"
            }
        }
        default {
            throw "Unknown target: $T"
        }
    }
}

function Test-InstallPath {
    param([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) { return $false }
    if ($Path -match '[\;\&\|\$\(\)\<\>\`]') { return $false }
    if ($Path -match '\.\.') { return $false }
    if ($Path -match '^[-]') { return $false }
    if ($Path -match '^(\\\\|//)') { return $false }   # UNC paths
    return $true
}

function Main {
    $paths = Resolve-TargetPaths -T $Target
    $SkillBase = $paths.SkillBase
    $AgentDirResolved = $paths.AgentDir
    $AllowPip = $paths.AllowPip
    $HostLabel = $paths.Label

    if ($SkillDir) {
        if (-not (Test-InstallPath -Path $SkillDir)) {
            Write-Host "X Invalid -SkillDir: contains forbidden characters or traversal" -ForegroundColor Red
            exit 1
        }
        $SkillBase = $SkillDir
    }
    if ($AgentDir) {
        if (-not (Test-InstallPath -Path $AgentDir)) {
            Write-Host "X Invalid -AgentDir: contains forbidden characters or traversal" -ForegroundColor Red
            exit 1
        }
        $AgentDirResolved = $AgentDir
    }

    $SkillDirResolved = Join-Path $SkillBase "ads"
    $ManifestPath = Join-Path $SkillBase ".claude-ads-$Target.manifest.json"
    $RepoUrl = "https://github.com/AI-Marketing-Hub/claude-ads"
    $OwnedFiles = [System.Collections.Generic.List[string]]::new()
    $OwnedDirs = [System.Collections.Generic.List[string]]::new()
    $RecursiveDirs = [System.Collections.Generic.List[string]]::new()

    Write-Host "=================================="
    Write-Host "   Claude Ads - Installer"
    Write-Host "   Target: $HostLabel"
    Write-Host "=================================="
    Write-Host ""

    # Prefer the current release/checkout when this script ships with the
    # distribution. Standalone installers use the operator's authenticated Git.
    $SourceDir = $null
    if ($RepoDir) { $Source = 'local' }
    if ($Source -eq 'auto') {
        if ((Test-Path (Join-Path $PSScriptRoot "ads\SKILL.md")) -and (Test-Path (Join-Path $PSScriptRoot "skills"))) {
            $Source = 'local'
            $SourceDir = $PSScriptRoot
        } else {
            $Source = 'git'
        }
    }
    if ($Source -eq 'local') {
        $SourceDir = if ($RepoDir) { $RepoDir } else { $PSScriptRoot }
        if (-not (Test-InstallPath -Path $SourceDir)) { throw "Invalid local repository path" }
        $SourceDir = (Resolve-Path $SourceDir).Path
        if (-not (Test-Path (Join-Path $SourceDir "ads\SKILL.md"))) {
            throw "Local source is not a Claude Ads distribution: $SourceDir"
        }
    } elseif (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "X Git is required for -Source git." -ForegroundColor Red
        exit 1
    }
    $ManagedPython = $null
    $PythonTarget = $null
    if ($AllowPip -and -not $NoDeps) {
        $ManagedPython = Get-Command python -ErrorAction SilentlyContinue
        if (-not $ManagedPython) {
            throw "python not found. Re-run with -NoDeps to install without Python helpers."
        }
        $PythonTarget = & $ManagedPython.Source -c "import platform,sys; print('|'.join((sys.implementation.name, f'{sys.version_info.major}.{sys.version_info.minor}', platform.system().lower(), platform.machine().lower())))"
        if ($PythonTarget -notin @("cpython|3.11|windows|amd64", "cpython|3.12|windows|amd64")) {
            throw "No verified dependency lock target for $PythonTarget. Re-run with -NoDeps; moving-range fallback is disabled."
        }
        $DependencyTargetId = if ($PythonTarget -eq "cpython|3.11|windows|amd64") { "runtime-windows-cp311" } else { "runtime-windows-cp312" }
    }
    Write-Host "OK Distribution source: $Source" -ForegroundColor Green

    # Create directories
    New-Item -ItemType Directory -Path (Join-Path $SkillDirResolved "references") -Force | Out-Null
    New-Item -ItemType Directory -Path $AgentDirResolved -Force | Out-Null

    # Clone to temp directory
    $TempDir = $null

    try {
        if ($Source -eq 'git') {
            $TempDir = Join-Path $env:TEMP "claude-ads-install-$(Get-Random)"
            Write-Host "Downloading Claude Ads with authenticated Git..."
            $ErrorActionPreference = "Continue"
            git clone --depth 1 $RepoUrl "$TempDir\claude-ads" 2>&1 | Out-Null
            $ErrorActionPreference = "Stop"
            if ($LASTEXITCODE -ne 0) { throw "Git clone failed" }
            $SourceDir = "$TempDir\claude-ads"
        }

        # Copy main skill + references
        Write-Host "Installing skill files..."
        Copy-Item "$SourceDir\ads\SKILL.md" -Destination "$SkillDirResolved\SKILL.md" -Force
        [void]$OwnedFiles.Add((Join-Path $SkillDirResolved "SKILL.md"))
        Get-ChildItem "$SourceDir\ads\references\*.md" -File | ForEach-Object {
            $Destination = Join-Path "$SkillDirResolved\references" $_.Name
            Copy-Item $_.FullName -Destination $Destination -Force
            [void]$OwnedFiles.Add($Destination)
        }
        [void]$OwnedDirs.Add((Join-Path $SkillDirResolved "references"))
        $InterfaceSource = Join-Path $SourceDir "ads\agents"
        if (Test-Path $InterfaceSource) {
            $InterfaceDir = Join-Path $SkillDirResolved "agents"
            New-Item -ItemType Directory -Path $InterfaceDir -Force | Out-Null
            Get-ChildItem "$InterfaceSource\*.yaml" -File | ForEach-Object {
                $Destination = Join-Path $InterfaceDir $_.Name
                Copy-Item $_.FullName -Destination $Destination -Force
                [void]$OwnedFiles.Add($Destination)
            }
            [void]$OwnedDirs.Add($InterfaceDir)
        }

        # Copy sub-skills
        Write-Host "Installing sub-skills..."
        Get-ChildItem "$SourceDir\skills" -Directory | ForEach-Object {
            $TargetDir = Join-Path $SkillBase $_.Name
            New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
            Copy-Item (Join-Path $_.FullName "SKILL.md") -Destination "$TargetDir\SKILL.md" -Force
            [void]$OwnedFiles.Add((Join-Path $TargetDir "SKILL.md"))

            # Copy assets (industry templates) if they exist
            $AssetsDir = Join-Path $_.FullName "assets"
            if (Test-Path $AssetsDir) {
                $TargetAssets = Join-Path $TargetDir "assets"
                New-Item -ItemType Directory -Path $TargetAssets -Force | Out-Null
                Get-ChildItem "$AssetsDir\*.md" -File | ForEach-Object {
                    $Destination = Join-Path $TargetAssets $_.Name
                    Copy-Item $_.FullName -Destination $Destination -Force
                    [void]$OwnedFiles.Add($Destination)
                }
                [void]$OwnedDirs.Add($TargetAssets)
            }
            [void]$OwnedDirs.Add($TargetDir)
        }

        # Copy agents
        Write-Host "Installing subagents..."
        Get-ChildItem "$SourceDir\agents\*.md" -File | ForEach-Object {
            $Destination = Join-Path $AgentDirResolved $_.Name
            Copy-Item $_.FullName -Destination $Destination -Force
            [void]$OwnedFiles.Add($Destination)
        }

        # Copy scripts (optional Python tools)
        $ScriptsSource = "$SourceDir\scripts"
        if (Test-Path $ScriptsSource) {
            Write-Host "Installing Python scripts..."
            $ScriptsDir = Join-Path $SkillDirResolved "scripts"
            New-Item -ItemType Directory -Path $ScriptsDir -Force | Out-Null
            Get-ChildItem "$ScriptsSource\*.py" -File | ForEach-Object {
                $Destination = Join-Path $ScriptsDir $_.Name
                Copy-Item $_.FullName -Destination $Destination -Force
                [void]$OwnedFiles.Add($Destination)
            }
            Copy-Item "$SourceDir\requirements.txt" -Destination "$SkillDirResolved\requirements.txt" -Force
            [void]$OwnedFiles.Add((Join-Path $SkillDirResolved "requirements.txt"))
            Copy-Item "$SourceDir\requirements.lock" -Destination "$SkillDirResolved\requirements.lock" -Force
            [void]$OwnedFiles.Add((Join-Path $SkillDirResolved "requirements.lock"))
            $CoreSource = Join-Path $SourceDir "claude_ads_core"
            $CoreDir = Join-Path $ScriptsDir "claude_ads_core"
            Get-ChildItem $CoreSource -File -Recurse | Where-Object {
                $_.Extension -in @(".py", ".json") -and $_.FullName -notmatch "[\\/]__pycache__[\\/]"
            } | ForEach-Object {
                $Relative = [System.IO.Path]::GetRelativePath($CoreSource, $_.FullName)
                $Destination = Join-Path $CoreDir $Relative
                New-Item -ItemType Directory -Path (Split-Path $Destination -Parent) -Force | Out-Null
                Copy-Item $_.FullName -Destination $Destination -Force
                [void]$OwnedFiles.Add($Destination)
            }
            Get-ChildItem $CoreSource -Directory -Recurse | Where-Object {
                $_.FullName -notmatch "[\\/]__pycache__(?:[\\/]|$)"
            } | ForEach-Object {
                $Relative = [System.IO.Path]::GetRelativePath($CoreSource, $_.FullName)
                [void]$OwnedDirs.Add((Join-Path $CoreDir $Relative))
            }
            [void]$OwnedDirs.Add($CoreDir)
            [void]$OwnedDirs.Add($ScriptsDir)
        }

        # Commit ownership before dependency installation so a later pip
        # failure is always recoverable with uninstall.
        $VenvDir = Join-Path $SkillDirResolved ".venv"
        if ($AllowPip -and -not $NoDeps) {
            [void]$RecursiveDirs.Add($VenvDir)
            [void]$OwnedFiles.Add((Join-Path $SkillDirResolved "managed-runtime-receipt.json"))
        }
        [void]$OwnedDirs.Add($SkillDirResolved)
        $Manifest = @{
            version = 1
            target = $Target
            files = @($OwnedFiles)
            directories = @($OwnedDirs)
            recursive_directories = @($RecursiveDirs)
        }
        $Manifest | ConvertTo-Json -Depth 4 | Set-Content -Path $ManifestPath -Encoding UTF8
        Write-Host "OK Ownership manifest: $ManifestPath" -ForegroundColor Green

        Write-Host ""
        if ($AllowPip -and -not $NoDeps) {
            $ReceiptPath = Join-Path $SkillDirResolved "managed-runtime-receipt.json"
            Remove-Item $ReceiptPath -Force -ErrorAction SilentlyContinue
            Write-Host "Installing exact hashed Python dependencies into a managed virtual environment..."
            $ErrorActionPreference = "Continue"
            if ($ManagedPython) {
                & $ManagedPython.Source -m venv $VenvDir
                if ($LASTEXITCODE -eq 0) {
                    & "$VenvDir\Scripts\python.exe" -m pip install -q --ignore-installed --report "$VenvDir\install-report.json" --require-hashes --only-binary=:all: -r "$SkillDirResolved\requirements.lock"
                }
                if ($LASTEXITCODE -eq 0) {
                    $SitePackages = & "$VenvDir\Scripts\python.exe" -c "import sysconfig; print(sysconfig.get_paths()['purelib'])"
                    $ScriptsDir | Set-Content -Path (Join-Path $SitePackages "claude-ads-core.pth") -Encoding UTF8
                    & "$VenvDir\Scripts\python.exe" -m pip check
                }
                if ($LASTEXITCODE -eq 0) {
                    & "$VenvDir\Scripts\python.exe" "$ScriptsDir\write_install_receipt.py" --inventory "$SourceDir\control-plane\manifests\dependency-inventory.json" --lock "$SkillDirResolved\requirements.lock" --evidence "$SourceDir\control-plane\dependency-evidence\$DependencyTargetId.json" --pip-report "$VenvDir\install-report.json" --target-id $DependencyTargetId --output "$SkillDirResolved\managed-runtime-receipt.json"
                }
            }
            if ($ManagedPython -and $LASTEXITCODE -eq 0) {
                Write-Host "  OK Exact locked Python dependencies installed in $VenvDir" -ForegroundColor Green
            } else {
                Remove-Item $VenvDir -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item $ReceiptPath -Force -ErrorAction SilentlyContinue
                throw "Exact hashed dependency installation failed; no moving-range fallback was attempted."
            }
            $ErrorActionPreference = "Stop"
        } elseif ($NoDeps) {
            Write-Host "i  Skipping Python dependencies (-NoDeps)." -ForegroundColor Yellow
        } else {
            Write-Host "i  Skipping Python dependencies - $HostLabel host runtime may not execute Python skills directly." -ForegroundColor Yellow
            Write-Host "   Python helpers require the packaged exact-hash lock on a supported CPython wheel target."
        }

        Write-Host ""
        Write-Host "i  Image generation requires an explicitly configured eligible provider/model"
        Write-Host "   with capability evidence; Claude Ads does not probe or recommend a default."

        Write-Host ""
        Write-Host "Claude Ads installed successfully for $HostLabel!" -ForegroundColor Green
        Write-Host ""
        Write-Host "  Installed to:"
        Write-Host "    Skills: $SkillBase"
        Write-Host "    Agents: $AgentDirResolved"
        Write-Host ""
        Write-Host "  Bundled:"
        $SubSkillCount = @(Get-ChildItem "$SourceDir\skills" -Directory | Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") }).Count
        $AgentCount = @(Get-ChildItem "$SourceDir\agents\*.md" -File).Count
        $ReferenceCount = @(Get-ChildItem "$SourceDir\ads\references\*.md" -File).Count
        Write-Host "    - 1 main skill (ads orchestrator)"
        Write-Host "    - $SubSkillCount sub-skills (platform + lifecycle + functional + creative)"
        Write-Host "    - $AgentCount agents"
        Write-Host "    - $ReferenceCount reference files"
        Write-Host "    - 12 industry templates"
        Write-Host ""
        Write-Host "Usage:"
        Write-Host "  1. Start your host CLI"
        Write-Host "  2. Run commands:       /ads audit"
        Write-Host "                         /ads plan saas"
        Write-Host "                         /ads google"
        Write-Host ""
        Write-Host "To uninstall: .\uninstall.ps1 -Target $Target"
    }
    finally {
        # Cleanup temp directory
        if ($TempDir -and (Test-Path $TempDir)) {
            Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

Main
