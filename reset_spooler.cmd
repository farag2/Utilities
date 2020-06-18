NET STOP spooler
DEL /F /S /Q %SYSTEMROOT%\System32\spool\PRINTERS\*
NET START spooler
pause
