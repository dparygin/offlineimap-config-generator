# generate_configs.ps1

param (
    [string]$InputFile = ".\accounts.txt",
    [string]$OutputDir = ".\configs"
)

# Создаем папку для конфигов, если ее нет
if (-not (Test-Path -Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

# Читаем исходный файл строго в UTF-8, чтобы избежать кракозябр
$lines = Get-Content -Path $InputFile -Encoding UTF8 -ErrorAction Stop

foreach ($line in $lines) {
    # Пропускаем пустые строки
    if ([string]::IsNullOrWhiteSpace($line)) { continue }

    # Разделяем строку. 
    # \s+ означает, что вокруг дефиса/тире ОБЯЗАТЕЛЬНО должны быть пробелы.
    # Цифра 2 в конце гарантирует, что строка разобьется максимум на две части.
    $parts = $line -split '\s+[-–—]\s+', 2
    
    if ($parts.Count -lt 2) {
        Write-Warning "Пропущена строка из-за неверного формата: $line"
        continue
    }

    $email = $parts[0].Trim()
    $password = $parts[1].Trim()

    # Формируем имя аккаунта: берем часть до @, меняем точки на _, переводим в верхний регистр
    $accountPrefix = $email.Split('@')[0]
    $accountName = $accountPrefix.Replace('.', '_').ToUpper()

    # Шаблон конфигурационного файла
    $configContent = @"
[general]
accounts = $accountName
ui = TTYUI 

[Account $accountName]
localrepository = Local_$accountName
remoterepository = Remote_$accountName

[Repository Local_$accountName]
type = Maildir
localfolders = /data/Mailbackup/offlineIMAP/$accountName/

[Repository Remote_$accountName]
type = IMAP
remotehost = imap.yandex.ru
ssl = yes
sslcacertfile = /etc/ssl/certs/ca-certificates.crt
remoteport = 993
remoteuser = $email
remotepass = $password
maxconnections = 1
readonly = True
"@

    # Сохраняем в файл
    $fileName = "$accountName.conf"
    $filePath = Join-Path -Path $OutputDir -ChildPath $fileName
    
    # Используем UTF8 для корректной работы в Linux
    $configContent | Set-Content -Path $filePath -Encoding UTF8
    
    Write-Host "Создан конфиг: $filePath" -ForegroundColor Green
}

Write-Host "Генерация завершена." -ForegroundColor Cyan