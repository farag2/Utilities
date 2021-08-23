:: Clear and reset thumbnail cache
@echo off
TASKKILL /IM explorer.exe /F
TIMEOUT /T 2 /NOBREAK >nul
DEL /F /S /Q /A "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*"
TIMEOUT /T 2 /NOBREAK >nul
START explorer.exe
pause
