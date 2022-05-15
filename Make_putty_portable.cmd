:: https://the.earth.li/~sgtatham/putty/0.58/htmldoc/Chapter4.html#config-file

@ECHO OFF
regedit /s %~dp0putty.reg
start /wait %~dp0putty.exe
reg delete HKEY_CURRENT_USER\Software\SimonTatham /f
