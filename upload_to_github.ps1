# Скрипт для загрузки проекта в GitHub репозиторий
# Использование: запустите этот скрипт после установки Git

$ErrorActionPreference = 'Stop'

# Найти путь к проекту
Write-Host "Поиск проекта..." -ForegroundColor Cyan
$projectPath = (Get-ChildItem -Path Z:\ -Recurse -Filter "codemagic.yaml" -ErrorAction SilentlyContinue | Select-Object -First 1).DirectoryName

if (-not $projectPath) {
    Write-Host "Ошибка: Проект не найден!" -ForegroundColor Red
    exit 1
}

Write-Host "Найден проект: $projectPath" -ForegroundColor Green

# Перейти в директорию проекта
Push-Location -LiteralPath $projectPath

try {
    Write-Host "`n=== Инициализация Git ===" -ForegroundColor Cyan
    
    # Проверка, инициализирован ли git
    if (-not (Test-Path ".git")) {
        Write-Host "Инициализация нового Git репозитория..." -ForegroundColor Yellow
        git init
    } else {
        Write-Host "Git репозиторий уже инициализирован" -ForegroundColor Green
    }
    
    Write-Host "`n=== Добавление файлов ===" -ForegroundColor Cyan
    git add .
    
    Write-Host "`n=== Проверка статуса ===" -ForegroundColor Cyan
    git status
    
    Write-Host "`n=== Создание коммита ===" -ForegroundColor Cyan
    $commitMessage = "Initial commit: Kasidie City Whisper iOS app"
    git commit -m $commitMessage
    
    Write-Host "`n=== Настройка remote репозитория ===" -ForegroundColor Cyan
    $remoteUrl = "https://github.com/fryfarrrell/testrep.git"
    
    # Проверка существующего remote
    $existingRemote = git remote get-url origin 2>$null
    if ($existingRemote) {
        Write-Host "Remote уже настроен: $existingRemote" -ForegroundColor Yellow
        Write-Host "Обновление remote..." -ForegroundColor Yellow
        git remote set-url origin $remoteUrl
    } else {
        Write-Host "Добавление remote: $remoteUrl" -ForegroundColor Yellow
        git remote add origin $remoteUrl
    }
    
    Write-Host "`n=== Переименование ветки в main ===" -ForegroundColor Cyan
    git branch -M main
    
    Write-Host "`n=== Загрузка в GitHub ===" -ForegroundColor Cyan
    Write-Host "Внимание: Вам может потребоваться ввести логин и пароль GitHub" -ForegroundColor Yellow
    Write-Host "Или использовать Personal Access Token вместо пароля" -ForegroundColor Yellow
    Write-Host ""
    
    git push -u origin main
    
    Write-Host "`n=== Успешно! ===" -ForegroundColor Green
    Write-Host "Код загружен в GitHub: $remoteUrl" -ForegroundColor Green
    Write-Host "Теперь можно подключить репозиторий к Codemagic!" -ForegroundColor Green
    
} catch {
    Write-Host "`nОшибка: $_" -ForegroundColor Red
    Write-Host "Убедитесь, что:" -ForegroundColor Yellow
    Write-Host "1. Git установлен и доступен в PATH" -ForegroundColor Yellow
    Write-Host "2. Вы авторизованы в GitHub (git config --global user.name и user.email)" -ForegroundColor Yellow
    Write-Host "3. У вас есть права на запись в репозиторий" -ForegroundColor Yellow
} finally {
    Pop-Location
}

Write-Host "`nНажмите любую клавишу для выхода..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
