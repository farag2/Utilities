CD /D "%~dp0"

REG QUERY "HKU\S-1-5-19\Environment" >nul
IF %ERRORLEVEL% NEQ 0 powershell.exe -WindowStyle Hidden -NoProfile -NoLogo -Command "Start-Process -Verb RunAS -WindowStyle Hidden -FilePath '%0'" & EXIT

powershell.exe -ExecutionPolicy Bypass -NoProfile -NoLogo -WindowStyle Hidden -File ".\Scripts\TeamViewer.ps1"