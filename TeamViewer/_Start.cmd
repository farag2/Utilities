@ECHO OFF
CHCP 65001 >nul

CD /D "%~dp0"

REG QUERY "HKU\S-1-5-19\Environment" >nul
CLS

IF "%ERRORLEVEL%" NEQ "0" (
	powershell.exe -NoProfile -NoLogo -Command "Start-Process -FilePath '%0' -Verb RunAS"
	cls
	exit
)
powershell.exe -ExecutionPolicy RemoteSigned -NoProfile -NoLogo -WindowStyle Hidden -File ".\Scripts\TeamViewer.ps1"