@echo off
chcp 65001 >nul

REG QUERY "HKU\S-1-5-19\Environment" >nul

if '%errorlevel%' NEQ '0' (
	goto UACPrompt
)
else (
	goto gotAdmin
)

:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
exit /B

:gotAdmin
if exist "%temp%\getadmin.vbs" (
	del "%temp%\getadmin.vbs"
)
pushd "%CD%"
CD /D "%~dp0"

powershell.exe -ExecutionPolicy RemoteSigned -NoProfile -NoLogo -WindowStyle Hidden -File ".\Scripts\TeamViewer.ps1"