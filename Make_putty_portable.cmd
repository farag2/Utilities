:: https://the.earth.li/~sgtatham/putty/0.58/htmldoc/Chapter4.html#config-file

@ECHO OFF
REG ADD HKCU\Software\SimonTatham\PuTTY\Sessions\VDSina /v HostName /t REG_SZ /d "" /f
REG ADD HKCU\Software\SimonTatham\PuTTY\SshHostKeys /v "" /t REG_SZ /d "" /f

start /wait %~dp0putty.exe

reg delete HKEY_CURRENT_USER\Software\SimonTatham /f
DEL %LOCALAPPDATA%\PUTTY.RND /f
