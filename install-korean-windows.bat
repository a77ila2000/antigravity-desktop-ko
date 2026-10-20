@echo off
setlocal
title Antigravity Korean Localization Installer

set "NODE_CMD=node"
where node >nul 2>nul
if %errorlevel%==0 goto NODE_READY

if exist "C:\Program Files\nodejs\node.exe" (
    set "NODE_CMD=C:\Program Files\nodejs\node.exe"
    goto NODE_READY
)
if exist "C:\Program Files (x86)\nodejs\node.exe" (
    set "NODE_CMD=C:\Program Files (x86)\nodejs\node.exe"
    goto NODE_READY
)
if exist "%LOCALAPPDATA%\Programs\node\node.exe" (
    set "NODE_CMD=%LOCALAPPDATA%\Programs\node\node.exe"
    goto NODE_READY
)

echo.
echo [ERROR] Node.js was not found.
echo Install the latest Node.js LTS release from https://nodejs.org/ and run this file again.
echo.
pause
exit /b 1

:NODE_READY
echo.
echo ==========================================
echo   Antigravity Korean Localization
echo ==========================================
echo.
echo Choose how to display the product name:
echo   [1] Keep the English name "Antigravity" (recommended)
echo   [2] Hide the product name
echo.
set "CHOICE_VAL=1"
set /p "CHOICE_VAL=Enter 1 or 2 (default: 1): "
set "BRAND_ARG=--brand-title english"
if "%CHOICE_VAL%"=="2" set "BRAND_ARG=--brand-title hidden"

echo.
echo [1/2] Installing Korean localization...
"%NODE_CMD%" "%~dp0localization_engine.js" %BRAND_ARG% %*
if %errorlevel% neq 0 goto FAIL

echo.
echo [2/2] Installation completed.
echo Restart Antigravity if it is not already open.
echo This window will close in 5 seconds.
timeout /t 5 /nobreak >nul
exit /b 0

:FAIL
echo.
echo [ERROR] Installation failed. Review the message above.
echo.
pause
exit /b 1
