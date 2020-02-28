net stop spooler
DEL /F /S /Q %SYSTEMROOT%\System32\spool\PRINTERS\*
net start spooler
pause