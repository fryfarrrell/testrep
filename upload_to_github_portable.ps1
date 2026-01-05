# Скрипт для загрузки проекта в GitHub с портативным Git
# Использование: запустите этот скрипт

$ErrorActionPreference = 'Stop'

Write-Host "=== Поиск портативного Git ===" -ForegroundColor Cyan

# Поиск git.exe в стандартных местах
$gitPaths = @(
    "$env:USERPROFILE\Downloads\PortableGit\bin\git.exe",
    "$env:USERPROFILE\Desktop\PortableGit\bin\git.exe",
    "C:\PortableGit\bin\git.exe",
    "D:\PortableGit\bin\git.exe",
    "Z:\PortableGit\bin\git.exe"
)

# Поиск git-bash.exe и получение пути к git.exe
$gitBash = Get-ChildItem -Path $env:USERPROFILE, C:\, D:\, Z:\ -Recurse -Filter "git-bash.exe" -ErrorAction SilentlyContinue -Depth 4 | Select-Object -First 1

if ($gitBash) {
    $gitExe = Join-Path $gitBash.DirectoryName "bin\git.exe"
    if (Test-Path $gitExe) {
        $gitPaths += $gitExe
    }
}

# Поиск git.exe напрямую
$foundGit = $null
foreach ($path in $gitPaths) {
    if (Test-Path $path) {
        $foundGit = $path
        Write-Host "Найден Git: $foundGit" -ForegroundColor Green
        break
    }
}

# Если не найден, попробуем найти вручную
if (-not $foundGit) {
    $allGit = Get-ChildItem -Path $env:USERPROFILE, C:\, D:\, Z:\ -Recurse -Filter "git.exe" -ErrorAction SilentlyContinue -Depth 5 | Where-Object { $_.DirectoryName -like "*bin*" } | Select-Object -First 1
    if ($allGit) {
        $foundGit = $allGit.FullName
        Write-Host "Найден Git: $foundGit" -ForegroundColor Green
    }
}

if (-not $foundGit) {
    Write-Host "`nGit не найден автоматически!" -ForegroundColor Red
    Write-Host "Пожалуйста, укажите путь к git.exe вручную:" -ForegroundColor Yellow
    Write-Host "Например: C:\PortableGit\bin\git.exe" -ForegroundColor Yellow
    $manualPath = Read-Host "Введите путь к git.exe"
    if (Test-Path $manualPath) {
        $foundGit = $manualPath
    } else {
        Write-Host "Ошибка: Файл не найден!" -ForegroundColor Red
        exit 1
    }
}

# Добавляем путь к Git в PATH для этой сессии
$gitDir = Split-Path $foundGit -Parent
$env:Path = "$gitDir;$env:Path"

Write-Host "`n=== Поиск проекта ===" -ForegroundColor Cyan
$projectPath = (Get-ChildItem -Path Z:\ -Recurse -Filter "codemagic.yaml" -ErrorAction SilentlyContinue | Select-Object -First 1).DirectoryName

if (-not $projectPath) {
    Write-Host "Ошибка: Проект не найден!" -ForegroundColor Red
    Write-Host "Убедитесь, что файл codemagic.yaml существует в проекте" -ForegroundColor Yellow
    exit 1
}

Write-Host "Найден проект: $projectPath" -ForegroundColor Green

# Переход в директорию проекта
try {
    Push-Location -LiteralPath $projectPath
    $currentDir = Get-Location
    Write-Host "Текущая директория: $currentDir" -ForegroundColor Green
    
    Write-Host "`n=== Проверка версии Git ===" -ForegroundColor Cyan
    & $foundGit --version
    
    Write-Host "`n=== Инициализация Git ===" -ForegroundColor Cyan
    
    # Проверка, инициализирован ли git
    if (-not (Test-Path ".git")) {
        Write-Host "Инициализация нового Git репозитория..." -ForegroundColor Yellow
        & $foundGit init
    } else {
        Write-Host "Git репозиторий уже инициализирован" -ForegroundColor Green
    }
    
    Write-Host "`n=== Настройка Git (если нужно) ===" -ForegroundColor Cyan
    $currentUser = & $foundGit config --global user.name 2>$null
    $currentEmail = & $foundGit config --global user.email 2>$null
    
    if (-not $currentUser) {
        Write-Host "Настройка имени пользователя Git..." -ForegroundColor Yellow
        $userName = Read-Host "Введите ваше имя (для Git)"
        & $foundGit config --global user.name $userName
    }
    
    if (-not $currentEmail) {
        Write-Host "Настройка email Git..." -ForegroundColor Yellow
        $userEmail = Read-Host "Введите ваш email (для Git)"
        & $foundGit config --global user.email $userEmail
    }
    
    Write-Host "`n=== Добавление файлов ===" -ForegroundColor Cyan
    & $foundGit add .
    
    Write-Host "`n=== Проверка статуса ===" -ForegroundColor Cyan
    & $foundGit status
    
    Write-Host "`n=== Создание коммита ===" -ForegroundColor Cyan
    $commitMessage = "Initial commit: Kasidie City Whisper iOS app"
    & $foundGit commit -m $commitMessage
    
    Write-Host "`n=== Настройка remote репозитория ===" -ForegroundColor Cyan
    $remoteUrl = "https://github.com/fryfarrrell/testrep.git"
    
    # Проверка существующего remote
    $existingRemote = & $foundGit remote get-url origin 2>$null
    if ($existingRemote) {
        Write-Host "Remote уже настроен: $existingRemote" -ForegroundColor Yellow
        Write-Host "Обновление remote..." -ForegroundColor Yellow
        & $foundGit remote set-url origin $remoteUrl
    } else {
        Write-Host "Добавление remote: $remoteUrl" -ForegroundColor Yellow
        & $foundGit remote add origin $remoteUrl
    }
    
    Write-Host "`n=== Переименование ветки в main ===" -ForegroundColor Cyan
    & $foundGit branch -M main
    
    Write-Host "`n=== Загрузка в GitHub ===" -ForegroundColor Cyan
    Write-Host "Внимание: Вам нужно будет ввести логин и пароль GitHub" -ForegroundColor Yellow
    Write-Host "Или использовать Personal Access Token вместо пароля" -ForegroundColor Yellow
    Write-Host "Получить токен: https://github.com/settings/tokens" -ForegroundColor Yellow
    Write-Host ""
    
    & $foundGit push -u origin main
    
    Write-Host "`n=== Успешно! ===" -ForegroundColor Green
    Write-Host "Код загружен в GitHub: $remoteUrl" -ForegroundColor Green
    Write-Host "Теперь можно подключить репозиторий к Codemagic!" -ForegroundColor Green
    
} catch {
    Write-Host "`nОшибка: $_" -ForegroundColor Red
    Write-Host "Убедитесь, что:" -ForegroundColor Yellow
    Write-Host "1. Git найден и работает" -ForegroundColor Yellow
    Write-Host "2. Вы авторизованы в GitHub" -ForegroundColor Yellow
    Write-Host "3. У вас есть права на запись в репозиторий" -ForegroundColor Yellow
} finally {
    Pop-Location
}

Write-Host "`nНажмите любую клавишу для выхода..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
