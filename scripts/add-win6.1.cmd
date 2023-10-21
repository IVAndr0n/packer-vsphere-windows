:: ------------------------------------------------------------------------------
:: Name:           add-win6.1.cmd
:: Description:    Updates are required for installing VMware Tools on Windows 7
::                 and Server 2008R2, and for Windows Update client.
:: Code revision:  Andrey Eremchuk, https://github.com/IVAndr0n/
:: ------------------------------------------------------------------------------

@echo off
title Installing required updates for VMware Tools and Windows Update client

setlocal enabledelayedexpansion
set "source=f:"
if defined ProgramW6432 (set "OSbitver=x64") else (set "OSbitver=x86")
ver | findstr /i "6\.1" >nul && (
    call :installVMTools "Installing VMTools 11.0.6 [!OSbitver!] with SHA-1 code signing support" "Info: Learn more https://kb.vmware.com/s/article/78708"
    call :installUpdate "kb3138612" /norestart "Info: Windows Update client update for Windows 7/Server 2008R2 [March 2016]"
    call :installUpdate "kb4490628" /norestart "Info: Servicing Stack Update [March 2019]"
    call :scheduleUpdate "kb4555449" "Update kb4555449 scheduled after kb4474419-v3 installation and reboot"
    call :installUpdate "kb4474419-v3" /forcerestart "Info: Adding SHA-2 code signing support for VMTools and Windows Update client"
)
endlocal
exit /b

:installVMTools
if "%OSbitver%"=="x64" (
    set "file=%source%\VMware-tools-11.0.6-15940789-x86_64.exe"
) else (
    set "file=%source%\VMware-tools-11.0.6-15940789-i386.exe"
)
if exist "%file%" (
    echo %~1
    echo %~2
    "%file%" /s /v "/qb REBOOT=R"
    echo.
    echo Basic Windows settings to run a Packer build [for error 0xc0000142]
    set "key=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
    if exist "a:\initialize.ps1" reg add "!key!" /v "Basic settings" /t reg_sz /d "cmd /c title \"Basic settings\" && powershell -ExecutionPolicy Bypass -File a:\initialize.ps1" /f >nul
)
exit /b

:scheduleUpdate
echo.
echo %~2
set "number=%~1"
set "file=%source%\windows6.1-%number%-%OSbitver%.msu"
set "key=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
if exist "%file%" reg add "%key%" /v "Install Update" /t reg_sz /d "cmd /c title \"Installing update %number%\" && wusa \"%file%\" /quiet /norestart" /f >nul
exit /b

:installUpdate
echo.
set "number=%~1"
set "file=%source%\windows6.1-%number%-%OSbitver%.msu"
if exist "%file%" (
    echo Installing update %number% [%OSbitver%]
    echo %~3
    start /wait wusa "%file%" /quiet %~2
)
exit /b