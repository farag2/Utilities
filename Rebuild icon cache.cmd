:: Rebuild icon cache
@echo off
ie4uinit.exe -show
TASKKILL /IM explorer.exe /F
TIMEOUT /T 2 /NOBREAK >nul
DEL /A /F /Q "%LOCALAPPDATA%\IconCache.db"
DEL /A /F /Q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\iconcache_*"
TIMEOUT /T 2 /NOBREAK >nul
start explorer.exe
pause
