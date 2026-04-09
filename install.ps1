# Dev Environment One-Click Setup Script
# For OpenClaw setup-dev-env skill
# Auto-elevates to Administrator, auto-downloads installers from GitHub if missing

param(
    [string]$LogPath = "$env:TEMP\setup-dev-env.log"
)

# Auto-elevate to Administrator if not already running as admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit 0
}

# Get script directory (installers may be in the same folder)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# GitHub Release URL for downloading offline installers
$releaseBase = "https://github.com/lattury/setup-dev-env/releases/download/v1.0.0"

"[$(Get-Date)] Dev environment setup started" | Out-File $LogPath -Append
Write-Host "=== Dev Environment Setup ===" -ForegroundColor Cyan

# Helper: download file if not found locally
function Get-Installer {
    param(
        [string]$FileName,
        [string]$LocalDir
    )
    $localPath = Join-Path $LocalDir $FileName
    if (Test-Path $localPath) {
        Write-Host "  Found local: $FileName" -ForegroundColor Green
        return $localPath
    }
    # Download from GitHub Release
    $url = "$releaseBase/$FileName"
    Write-Host "  Local file not found, downloading from GitHub: $url" -ForegroundColor Yellow
    "[$(Get-Date)] Downloading $FileName from GitHub" | Out-File $LogPath -Append
    try {
        Invoke-WebRequest -Uri $url -OutFile $localPath -UseBasicParsing
        Write-Host "  Download complete: $localPath" -ForegroundColor Green
        "[$(Get-Date)] Downloaded $FileName" | Out-File $LogPath -Append
        return $localPath
    } catch {
        Write-Host "[ERROR] Failed to download $FileName : $_" -ForegroundColor Red
        "[$(Get-Date)] ERROR: download failed for $FileName" | Out-File $LogPath -Append
        return $null
    }
}

# ========== Step 1: Check and install Node.js ==========
Write-Host "`n--- Step 1: Checking Node.js ---" -ForegroundColor Cyan

$nodeInstalled = $null -ne (Get-Command node -ErrorAction SilentlyContinue)
if ($nodeInstalled) {
    $nodeVer = & node -v
    Write-Host "Node.js already installed: $nodeVer" -ForegroundColor Green
    "[$(Get-Date)] Node.js already installed: $nodeVer" | Out-File $LogPath -Append
} else {
    Write-Host "Node.js not found, installing silently..." -ForegroundColor Yellow

    $nodeInstaller = Get-Installer -FileName "node-v24.14.0-x64.msi" -LocalDir $scriptDir
    if (-not $nodeInstaller) {
        Write-Host "[ERROR] Cannot proceed without Node.js installer" -ForegroundColor Red
        exit 1
    }

    try {
        Start-Process msiexec.exe -ArgumentList "/i","`"$nodeInstaller`"","/qn","/norestart" -Wait -NoNewWindow
        "[$(Get-Date)] Node.js installer completed" | Out-File $LogPath -Append
    } catch {
        Write-Host "[ERROR] Node.js installation failed: $_" -ForegroundColor Red
        "[$(Get-Date)] ERROR: Node.js install failed: $_" | Out-File $LogPath -Append
        exit 1
    }

    # Refresh PATH in current session
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")

    # Verify installation
    $nodeCheck = Get-Command node -ErrorAction SilentlyContinue
    if ($nodeCheck) {
        $nodeVer = & node -v
        Write-Host "Node.js installed successfully: $nodeVer" -ForegroundColor Green
        "[$(Get-Date)] Node.js installed: $nodeVer" | Out-File $LogPath -Append
    } else {
        Write-Host "[WARN] Node.js not found in PATH after install, may need terminal restart" -ForegroundColor Yellow
        "[$(Get-Date)] WARN: Node.js PATH not effective" | Out-File $LogPath -Append
    }
}

# ========== Step 2: Check and install Git ==========
Write-Host "`n--- Step 2: Checking Git ---" -ForegroundColor Cyan

$gitInstalled = $null -ne (Get-Command git -ErrorAction SilentlyContinue)
if ($gitInstalled) {
    $gitVer = & git --version
    Write-Host "Git already installed: $gitVer" -ForegroundColor Green
    "[$(Get-Date)] Git already installed: $gitVer" | Out-File $LogPath -Append
} else {
    Write-Host "Git not found, installing silently..." -ForegroundColor Yellow

    $gitInstaller = Get-Installer -FileName "Git-2.53.0.2-64-bit.exe" -LocalDir $scriptDir
    if (-not $gitInstaller) {
        Write-Host "[ERROR] Cannot proceed without Git installer" -ForegroundColor Red
        exit 1
    }

    try {
        Start-Process -FilePath $gitInstaller -ArgumentList "/VERYSILENT","/NORESTART","/NOCANCEL","/SP-","/CLOSEAPPLICATIONS","/RESTARTAPPLICATIONS" -Wait -NoNewWindow
        "[$(Get-Date)] Git installer completed" | Out-File $LogPath -Append
    } catch {
        Write-Host "[ERROR] Git installation failed: $_" -ForegroundColor Red
        "[$(Get-Date)] ERROR: Git install failed: $_" | Out-File $LogPath -Append
        exit 1
    }

    # Refresh PATH in current session
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")

    # Verify installation
    $gitCheck = Get-Command git -ErrorAction SilentlyContinue
    if ($gitCheck) {
        $gitVer = & git --version
        Write-Host "Git installed successfully: $gitVer" -ForegroundColor Green
        "[$(Get-Date)] Git installed: $gitVer" | Out-File $LogPath -Append
    } else {
        Write-Host "[WARN] Git not found in PATH after install, may need terminal restart" -ForegroundColor Yellow
        "[$(Get-Date)] WARN: Git PATH not effective" | Out-File $LogPath -Append
    }
}

# ========== Step 3: Install CodeBuddy Code CLI ==========
Write-Host "`n--- Step 3: Installing CodeBuddy Code CLI ---" -ForegroundColor Cyan

# Confirm Node.js is available (may have just been installed)
$env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")

$nodeCheck = Get-Command node -ErrorAction SilentlyContinue
if (-not $nodeCheck) {
    Write-Host "[ERROR] Node.js not available, cannot install CodeBuddy Code CLI" -ForegroundColor Red
    "[$(Get-Date)] ERROR: Node.js not available" | Out-File $LogPath -Append
    exit 1
}

$nodeVer = & node -v
Write-Host "Node.js version: $nodeVer" -ForegroundColor Green

# Check if already installed
$codebuddyInstalled = $null -ne (Get-Command codebuddy -ErrorAction SilentlyContinue)
if ($codebuddyInstalled) {
    $cbVer = & codebuddy --version 2>&1
    Write-Host "CodeBuddy Code CLI already installed: $cbVer" -ForegroundColor Green
    "[$(Get-Date)] CodeBuddy Code CLI already installed: $cbVer" | Out-File $LogPath -Append
} else {
    Write-Host "Installing CodeBuddy Code CLI..." -ForegroundColor Yellow
    try {
        & cmd /c "npm install -g @tencent-ai/codebuddy-code 2>&1" | ForEach-Object { Write-Host $_ }
        "[$(Get-Date)] npm install completed" | Out-File $LogPath -Append
    } catch {
        Write-Host "[ERROR] CodeBuddy Code CLI installation failed: $_" -ForegroundColor Red
        "[$(Get-Date)] ERROR: install failed: $_" | Out-File $LogPath -Append
        exit 1
    }

    # Refresh PATH
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")

    # Verify installation
    $cbCheck = Get-Command codebuddy -ErrorAction SilentlyContinue
    if ($cbCheck) {
        $cbVer = & codebuddy --version 2>&1
        Write-Host "CodeBuddy Code CLI installed successfully: $cbVer" -ForegroundColor Green
        "[$(Get-Date)] CodeBuddy Code CLI installed: $cbVer" | Out-File $LogPath -Append
    } else {
        Write-Host "[WARN] codebuddy command not found after install, may need terminal restart" -ForegroundColor Yellow
        "[$(Get-Date)] WARN: codebuddy PATH not effective" | Out-File $LogPath -Append
    }
}

# ========== Step 4: Launch CodeBuddy for first-time setup ==========
Write-Host "`n--- Step 4: Launching CodeBuddy for login ---" -ForegroundColor Cyan

# Refresh PATH one more time
$env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")

$cbCmd = Get-Command codebuddy -ErrorAction SilentlyContinue
if ($cbCmd) {
    Write-Host "Starting CodeBuddy with Web UI (auto-open browser for login)..." -ForegroundColor Green
    "[$(Get-Date)] Launching codebuddy --serve --open" | Out-File $LogPath -Append
    Start-Process codebuddy -ArgumentList "--serve","--open"
    Write-Host "CodeBuddy launched! A browser window will open for login." -ForegroundColor Green
    Write-Host "Select your preferred login method in the browser to complete setup." -ForegroundColor White
} else {
    Write-Host "[WARN] codebuddy command not found. Please restart terminal and run: codebuddy --serve --open" -ForegroundColor Yellow
    "[$(Get-Date)] WARN: codebuddy not found, skip launch" | Out-File $LogPath -Append
}

# ========== Done ==========
Write-Host "`n=== Setup Complete ===" -ForegroundColor Cyan
Write-Host "Log file: $LogPath" -ForegroundColor White
"[$(Get-Date)] Setup complete" | Out-File $LogPath -Append
