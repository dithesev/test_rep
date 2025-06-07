@echo off
setlocal enabledelayedexpansion

set "hidden_mode=0"
if "%~1"=="hidden" (
    set "hidden_mode=1"
    shift /1
)

if !hidden_mode! equ 0 (
    if not "%~1"=="" (
        set "file=%~1"
        set "batpath=%~f0"
        set "vbsfile=%temp%\%~n0_temp%random%.vbs"
        
        echo Set WshShell = CreateObject("WScript.Shell") > "%vbsfile%"
        echo WshShell.Run "cmd /c """"%batpath%"" hidden ""%file%""""", 0, False >> "%vbsfile%"
        cscript //nologo "%vbsfile%"
        del "%vbsfile%"
        exit /b
    )
)

:main
if "%~1"=="" (
    echo Ошибка: Файл не передан. Используйте "Открыть с помощью".
    if !hidden_mode! equ 0 pause
    exit /b
)

set "filepath=%~1"
set "response_file=%temp%\response_%random%.tmp"

if not exist "%filepath%" (
    echo Файл не найден: %filepath%
    if !hidden_mode! equ 0 pause
    exit /b
)

set "ps_command=Get-Content -Path '%filepath%' -Encoding UTF8 -Raw | %% { [System.Uri]::EscapeDataString($_) }"
for /f "delims=" %%a in ('powershell -Command "%ps_command%"') do set "encoded=%%a"

set "url=https://text.pollinations.ai/%encoded%"

powershell -Command "$response = Invoke-WebRequest -Uri '%url%' -UseBasicParsing; $response.Content | Out-File '%response_file%' -Encoding UTF8"

if exist "%response_file%" (
    echo. >> "%filepath%"
    echo Ответ сервера [%date% %time%]: >> "%filepath%"
    type "%response_file%" >> "%filepath%"
    del "%response_file%"
)

exit /b
