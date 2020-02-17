ie4uinit.exe -show
taskkill /IM explorer.exe /F 
If exist del /A /F /Q "%localappdata%\IconCache.db"
If exist del /A /F /Q "%localappdata%\Microsoft\Windows\Explorer\iconcache*"
start explorer.exe
pause
