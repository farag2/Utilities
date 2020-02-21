@echo off
taskkill /IM explorer.exe /F
timeout 2 /nobreak >nul
DEL /F /Q "%LOCALAPPDATA%\IconCache.db"
DEL /F /Q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\iconcache_*"
DEL /F /Q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*"
timeout 2 /nobreak >nul
start explorer.exe
ie4uinit.exe -show
pause
