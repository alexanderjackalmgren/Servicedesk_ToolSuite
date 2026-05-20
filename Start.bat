@echo off

:: 1. Check for Administrator privileges using a dummy command
net session >nul 2>&1

:: 2. If the command fails, we are NOT admin. Trigger UAC and relaunch.
if %errorLevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~dpnx0' -Verb RunAs"
    exit /b
)

:: 3. If we reach this line, we have Admin rights. Launch the suite!
SET SCRIPT_NAME=NetworkSuite.ps1
start "" powershell.exe -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File "%~dp0%SCRIPT_NAME%"