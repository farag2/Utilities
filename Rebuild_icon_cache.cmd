:: Rebuild icon cache
@echo off

TASKKILL /IM explorer.exe /F
TIMEOUT /T 3 /NOBREAK

DEL "%LOCALAPPDATA%\IconCache.db" /F /Q
DEL "%LOCALAPPDATA%\Microsoft\Windows\Explorer\iconcache_*" /F /Q

start explorer.exe

ie4uinit.exe -show

pause
