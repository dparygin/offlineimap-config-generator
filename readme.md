```markdown
# Генератор конфигураций OfflineIMAP (generate_configs.ps1)

Этот скрипт автоматизирует создание конфигурационных файлов для OfflineIMAP на основе текстового списка учетных записей.

## 📋 Описание
Скрипт читает входной файл со списком email-адресов и паролей, извлекает логин (часть до `@`), преобразует его в требуемый формат (верхний регистр, замена точек на подчеркивания) и генерирует отдельный `.conf` файл для каждой учетной записи.

## ⚙️ Требования
- **ОС:** Windows с установленным PowerShell.
- **Кодировка:** Файл скрипта (`generate_configs.ps1`) должен быть сохранен в кодировке **UTF-8 с BOM** (со спецификацией), а файл с паролями (`accounts.txt`) — в **UTF-8**.

## 📂 Структура файлов
```text
Рабочая_директория/
├── generate_configs.ps1  # Исполняемый скрипт
├── accounts.txt          # Файл-источник с аккаунтами
└── configs/              # (Создается автоматически) Готовые .conf файлы

```

## 📝 Формат входных данных (`accounts.txt`)

Каждая строка должна содержать email и пароль, разделенные дефисом или тире **с пробелами по бокам**:

```text
test.user@example.com - test_pass_123
a.ivanov@example.com - password123

```

*(Пустые строки скрипт автоматически игнорирует).*

## 📄 Пример результата

Для строки `test.user@example.com - test_pass_123` будет создан файл `configs/TEST_USER.conf` со следующим содержимым:

```ini
[general]
accounts = TEST_USER
ui = TTYUI 

[Account TEST_USER]
localrepository = Local_TEST_USER
remoterepository = Remote_TEST_USER

[Repository Local_TEST_USER]
type = Maildir
localfolders = /data/Mailbackup/offlineIMAP/TEST_USER/

[Repository Remote_TEST_USER]
type = IMAP
remotehost = imap.yandex.ru
ssl = yes
sslcacertfile = /etc/ssl/certs/ca-certificates.crt
remoteport = 993
remoteuser = test.user@example.com
remotepass = test_pass_123
maxconnections = 1
readonly = True

```

## 🚀 Как использовать

1. Создайте файл `accounts.txt` рядом со скриптом и добавьте в него данные.
2. Откройте PowerShell и перейдите в папку со скриптом.
3. Запустите генерацию командой:
```powershell
.\generate_configs.ps1

```



*(Если выполнение заблокировано системной политикой, запустите скрипт в обход ограничений: `powershell -ExecutionPolicy Bypass -File .\generate_configs.ps1`)*

## 🛡 Особенности и защита от ошибок

* **Умное разделение строк:** Скрипт разделяет email и пароль *только* если вокруг тире/дефиса есть пробелы. Это защищает адреса, содержащие дефис в домене (например, `example.com`), от случайного обрезания.
* **Поддержка разной типографики:** Корректно распознаются стандартный дефис (`-`), среднее (`–`) и длинное (`—`) тире.
* **Linux-ready:** Готовые конфигурационные файлы принудительно сохраняются в кодировке UTF-8, что исключает проблемы при их последующем использовании на Linux-серверах.
* **Защита от сбоя кодировок:** Исходный список `accounts.txt` читается строго в UTF-8.

```
