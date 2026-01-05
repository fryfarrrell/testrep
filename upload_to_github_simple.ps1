# Simple script to upload project to GitHub using portable Git
$ErrorActionPreference = 'Stop'

Write-Host "=== Finding portable Git ===" -ForegroundColor Cyan

# Find git.exe
$gitPaths = @(
    "$env:USERPROFILE\Downloads\PortableGit\bin\git.exe",
    "$env:USERPROFILE\Desktop\PortableGit\bin\git.exe",
    "C:\PortableGit\bin\git.exe",
    "D:\PortableGit\bin\git.exe",
    "Z:\PortableGit\bin\git.exe"
)

$foundGit = $null
foreach ($path in $gitPaths) {
    if (Test-Path $path) {
        $foundGit = $path
        Write-Host "Found Git: $foundGit" -ForegroundColor Green
        break
    }
}

# Search for git.exe
if (-not $foundGit) {
    $allGit = Get-ChildItem -Path $env:USERPROFILE, C:\, D:\, Z:\ -Recurse -Filter "git.exe" -ErrorAction SilentlyContinue -Depth 5 | Where-Object { $_.DirectoryName -like "*bin*" } | Select-Object -First 1
    if ($allGit) {
        $foundGit = $allGit.FullName
        Write-Host "Found Git: $foundGit" -ForegroundColor Green
    }
}

if (-not $foundGit) {
    Write-Host "`nGit not found automatically!" -ForegroundColor Red
    Write-Host "Please specify path to git.exe manually:" -ForegroundColor Yellow
    $manualPath = Read-Host "Enter path to git.exe"
    if (Test-Path $manualPath) {
        $foundGit = $manualPath
    } else {
        Write-Host "Error: File not found!" -ForegroundColor Red
        exit 1
    }
}

# Add Git to PATH
$gitDir = Split-Path $foundGit -Parent
$env:Path = "$gitDir;$env:Path"

Write-Host "`n=== Finding project ===" -ForegroundColor Cyan
$projectPath = (Get-ChildItem -Path Z:\ -Recurse -Filter "codemagic.yaml" -ErrorAction SilentlyContinue | Select-Object -First 1).DirectoryName

if (-not $projectPath) {
    Write-Host "Error: Project not found!" -ForegroundColor Red
    exit 1
}

Write-Host "Found project: $projectPath" -ForegroundColor Green

try {
    Push-Location -LiteralPath $projectPath
    $currentDir = Get-Location
    Write-Host "Current directory: $currentDir" -ForegroundColor Green
    
    Write-Host "`n=== Checking Git version ===" -ForegroundColor Cyan
    & $foundGit --version
    
    Write-Host "`n=== Initializing Git ===" -ForegroundColor Cyan
    if (-not (Test-Path ".git")) {
        Write-Host "Initializing new Git repository..." -ForegroundColor Yellow
        & $foundGit init
    } else {
        Write-Host "Git repository already initialized" -ForegroundColor Green
    }
    
    Write-Host "`n=== Configuring Git ===" -ForegroundColor Cyan
    $currentUser = & $foundGit config --global user.name 2>$null
    $currentEmail = & $foundGit config --global user.email 2>$null
    
    if (-not $currentUser) {
        Write-Host "Setting Git user name..." -ForegroundColor Yellow
        $userName = Read-Host "Enter your name (for Git)"
        & $foundGit config --global user.name $userName
    }
    
    if (-not $currentEmail) {
        Write-Host "Setting Git email..." -ForegroundColor Yellow
        $userEmail = Read-Host "Enter your email (for Git)"
        & $foundGit config --global user.email $userEmail
    }
    
    Write-Host "`n=== Adding files ===" -ForegroundColor Cyan
    & $foundGit add .
    
    Write-Host "`n=== Checking status ===" -ForegroundColor Cyan
    & $foundGit status
    
    Write-Host "`n=== Creating commit ===" -ForegroundColor Cyan
    $commitMessage = "Initial commit: Kasidie City Whisper iOS app"
    & $foundGit commit -m $commitMessage
    
    Write-Host "`n=== Setting up remote repository ===" -ForegroundColor Cyan
    $remoteUrl = "https://github.com/fryfarrrell/testrep.git"
    
    $existingRemote = & $foundGit remote get-url origin 2>$null
    if ($existingRemote) {
        Write-Host "Remote already set: $existingRemote" -ForegroundColor Yellow
        Write-Host "Updating remote..." -ForegroundColor Yellow
        & $foundGit remote set-url origin $remoteUrl
    } else {
        Write-Host "Adding remote: $remoteUrl" -ForegroundColor Yellow
        & $foundGit remote add origin $remoteUrl
    }
    
    Write-Host "`n=== Renaming branch to main ===" -ForegroundColor Cyan
    & $foundGit branch -M main
    
    Write-Host "`n=== Pushing to GitHub ===" -ForegroundColor Cyan
    Write-Host "Note: You will need to enter GitHub username and password/token" -ForegroundColor Yellow
    Write-Host "Get token: https://github.com/settings/tokens" -ForegroundColor Yellow
    Write-Host ""
    
    & $foundGit push -u origin main
    
    Write-Host "`n=== Success! ===" -ForegroundColor Green
    Write-Host "Code uploaded to GitHub: $remoteUrl" -ForegroundColor Green
    Write-Host "Now you can connect repository to Codemagic!" -ForegroundColor Green
    
} catch {
    Write-Host "`nError: $_" -ForegroundColor Red
    Write-Host "Make sure:" -ForegroundColor Yellow
    Write-Host "1. Git is found and working" -ForegroundColor Yellow
    Write-Host "2. You are authorized in GitHub" -ForegroundColor Yellow
    Write-Host "3. You have write access to repository" -ForegroundColor Yellow
} finally {
    Pop-Location
}

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
