@echo off
setlocal
title Restore Original Antigravity Files

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
echo   Restore Original Antigravity Files
echo ==========================================
echo.
echo [1/2] Restoring the official app.asar backup...
"%NODE_CMD%" "%~dp0localization_engine.js" --huifu %*
if %errorlevel% neq 0 goto FAIL

echo.
echo [2/2] Restore completed.
echo Restart Antigravity if it is not already open.
echo This window will close in 5 seconds.
timeout /t 5 /nobreak >nul
exit /b 0

:FAIL
echo.
echo [ERROR] Restore failed. Review the message above.
echo.
pause
exit /b 1
