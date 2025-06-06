@echo off
setlocal enabledelayedexpansion

:: Проверка переданного файла
if "%~1"=="" (
    echo Ошибка: Файл не передан. Используйте "Открыть с помощью".
    pause
    exit /b
)

set "filepath=%~1"
set "response_file=%temp%\response_%random%.tmp"

:: Проверка существования файла
if not exist "%filepath%" (
    echo Файл не найден: %filepath%
    pause
    exit /b
)

:: Кодирование содержимого файла с помощью PowerShell
set "ps_command=Get-Content -Path '%filepath%' -Encoding UTF8 -Raw | %% { [System.Uri]::EscapeDataString($_) }"
for /f "delims=" %%a in ('powershell -Command "%ps_command%"') do set "encoded=%%a"

:: Формирование URL
set "url=https://text.pollinations.ai/%encoded%"

:: Отправка запроса и получение ответа
powershell -Command "$response = Invoke-WebRequest -Uri '%url%' -UseBasicParsing; $response.Content | Out-File '%response_file%' -Encoding UTF8"

:: Добавление ответа в конец исходного файла
if exist "%response_file%" (
    echo. >> "%filepath%"
    echo Ответ сервера [%date% %time%]: >> "%filepath%"
    type "%response_file%" >> "%filepath%"
    del "%response_file%"
)

exit /b
