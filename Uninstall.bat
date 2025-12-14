@echo off
title Uninstalling Simple Web Shutdown...

:: --- CONFIGURATION ---
:: Must match the directory in Install.bat
set "INSTALL_DIR=C:\SimpleWebShutdown"
:: ---------------------

net session >nul 2>&1
if %errorLevel% == 0 (
    goto :start
) else (
    echo Requesting admin privileges...
    powershell -Command "Start-Process '%~0' -Verb RunAs"
    exit
)

:start
cls
color 0c
echo ===============================================
echo      UNINSTALLING SIMPLE WEB SHUTDOWN...
echo      Created by @b4ho4_
echo ===============================================
echo.

echo [1/3] Removing background task...
schtasks /delete /tn "SimpleWebShutdown" /f >nul 2>&1

echo [2/3] Removing firewall rules...
powershell -Command "Remove-NetFirewallRule -DisplayName 'Simple Web Shutdown' -ErrorAction SilentlyContinue"

echo [3/3] Deleting files...
if exist "%INSTALL_DIR%" (
    rmdir /s /q "%INSTALL_DIR%" >nul 2>&1
    echo Deleted: %INSTALL_DIR%
) else (
    echo Directory not found or already deleted.
)

echo.
echo ===============================================
echo      UNINSTALLATION COMPLETE.
echo ===============================================
echo.
pause
