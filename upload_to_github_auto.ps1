# Auto script to upload project to GitHub - no user input required
$ErrorActionPreference = 'Continue'

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

if (-not $foundGit) {
    $allGit = Get-ChildItem -Path $env:USERPROFILE, C:\, D:\, Z:\ -Recurse -Filter "git.exe" -ErrorAction SilentlyContinue -Depth 5 | Where-Object { $_.DirectoryName -like "*bin*" } | Select-Object -First 1
    if ($allGit) {
        $foundGit = $allGit.FullName
        Write-Host "Found Git: $foundGit" -ForegroundColor Green
    }
}

if (-not $foundGit) {
    Write-Host "Error: Git not found!" -ForegroundColor Red
    exit 1
}

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
    
    Write-Host "`n=== Git version ===" -ForegroundColor Cyan
    & $foundGit --version
    
    Write-Host "`n=== Initializing Git ===" -ForegroundColor Cyan
    if (-not (Test-Path ".git")) {
        & $foundGit init
    }
    
    Write-Host "`n=== Configuring Git (if needed) ===" -ForegroundColor Cyan
    $currentUser = & $foundGit config --global user.name 2>$null
    $currentEmail = & $foundGit config --global user.email 2>$null
    
    if (-not $currentUser) {
        Write-Host "Setting default user name..." -ForegroundColor Yellow
        & $foundGit config --global user.name "fryfarrrell"
    } else {
        Write-Host "User name already set: $currentUser" -ForegroundColor Green
    }
    
    if (-not $currentEmail) {
        Write-Host "Setting default email..." -ForegroundColor Yellow
        & $foundGit config --global user.email "fryfarrrell@users.noreply.github.com"
    } else {
        Write-Host "Email already set: $currentEmail" -ForegroundColor Green
    }
    
    Write-Host "`n=== Adding files ===" -ForegroundColor Cyan
    & $foundGit add .
    
    Write-Host "`n=== Status ===" -ForegroundColor Cyan
    & $foundGit status --short
    
    Write-Host "`n=== Creating commit ===" -ForegroundColor Cyan
    $commitMessage = "Initial commit: Kasidie City Whisper iOS app"
    & $foundGit commit -m $commitMessage
    
    Write-Host "`n=== Setting up remote ===" -ForegroundColor Cyan
    $remoteUrl = "https://github.com/fryfarrrell/testrep.git"
    
    $existingRemote = & $foundGit remote get-url origin 2>$null
    if ($existingRemote) {
        Write-Host "Updating remote..." -ForegroundColor Yellow
        & $foundGit remote set-url origin $remoteUrl
    } else {
        Write-Host "Adding remote..." -ForegroundColor Yellow
        & $foundGit remote add origin $remoteUrl
    }
    
    Write-Host "`n=== Renaming branch to main ===" -ForegroundColor Cyan
    & $foundGit branch -M main 2>$null
    
    Write-Host "`n=== Ready to push! ===" -ForegroundColor Green
    Write-Host "Remote URL: $remoteUrl" -ForegroundColor Green
    Write-Host "`nTo push, run manually:" -ForegroundColor Yellow
    Write-Host "  git push -u origin main" -ForegroundColor White
    Write-Host "`nOr use Personal Access Token:" -ForegroundColor Yellow
    Write-Host "  1. Get token: https://github.com/settings/tokens" -ForegroundColor White
    Write-Host "  2. Generate new token (classic) with 'repo' scope" -ForegroundColor White
    Write-Host "  3. Use token as password when pushing" -ForegroundColor White
    
} catch {
    Write-Host "`nError: $_" -ForegroundColor Red
} finally {
    Pop-Location
}

Write-Host "`nDone! Repository is ready for push." -ForegroundColor Green
