:: Based on http://forum.ru-board.com/topic.cgi?forum=5&topic=39544&start=981&limit=1&m=1#1
:: Uninstall unnecessary Office < 2019 (2007, 2010, 2013, 2016) updates freeing up disk space
:: Just run every month
@echo off

set RegKey=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\
set OfficeKey=*000000F01FEC
set Count=0

if /i "%1"=="yes" (
set Count=%2
goto :Yes
)

FOR /f "tokens=10 delims=\" %%i IN ('reg query %RegKey% /f %OfficeKey% /k') DO call :ProduList %%i

if %Count% == 0 (
goto :eof	
)

:Yes
set cc=0
FOR /f "tokens=10 delims=\" %%i IN ('reg query %RegKey% /f %OfficeKey% /k') DO call :ProduUpdateUninstall %%i
goto :eof

:ProduList
set ProduRegKey=%RegKey%%1\
for /F "tokens=2*" %%i in ('reg query %ProduRegKey%InstallProperties /v DisplayName') do set ProduName=%%j
echo. %ProduName%
FOR /f "tokens=12 delims=\" %%i IN ('reg query %ProduRegKey%Patches /f * /k') DO call :UpdateList %%i
goto :eof

:UpdateList
set ProduUpdaRegKey=%ProduRegKey%Patches\%1
for /F "tokens=2*" %%i in ('reg query %ProduUpdaRegKey% /v State') do set ProduUpdaState=%%j
if %ProduUpdaState% == 0x1 goto :eof
for /F "tokens=2*" %%i in ('reg query %ProduUpdaRegKey% /v Uninstallable') do set ProduUpdaUninstallable=%%j
if not %ProduUpdaUninstallable% == 0x1 goto :eof
for /F "tokens=2*" %%i in ('reg query %ProduUpdaRegKey% /v DisplayName') do set ProduUpdaName=%%j
echo %ProduUpdaName%
set /A Count=%Count% + 1
goto :eof

:ProduUpdateUninstall
call :convert %1
set ProduGuid=%guid%
set ProduRegKey=%RegKey%%1\
for /F "tokens=2*" %%i in ('reg query %ProduRegKey%InstallProperties /v DisplayName') do set ProduName=%%j
echo. %ProduName%
FOR /f "tokens=12 delims=\" %%i IN ('reg query %ProduRegKey%Patches /f * /k') DO call :UpdateUninstall %%i
goto :eof

:UpdateUninstall
set ProduUpdaRegKey=%ProduRegKey%Patches\%1
for /F "tokens=2*" %%i in ('reg query %ProduUpdaRegKey% /v State') do set ProduUpdaState=%%j
if %ProduUpdaState% == 0x1 goto :eof
for /F "tokens=2*" %%i in ('reg query %ProduUpdaRegKey% /v Uninstallable') do set ProduUpdaUninstallable=%%j
if not %ProduUpdaUninstallable% == 0x1 goto :eof
for /F "tokens=2*" %%i in ('reg query %ProduUpdaRegKey% /v DisplayName') do set ProduUpdaName=%%j
call :convert %1
set ProduUpdaGuid=%guid%
set /A cc=%cc%+1
echo.
echo Удаляется %cc% из %Count% - %ProduUpdaName%
start "" /wait msiexec.exe /package {%ProduGuid%} /uninstall {%ProduUpdaGuid%} /qn
goto :eof

:convert
set t=%1
set guid=%t:~7,1%%t:~6,1%%t:~5,1%%t:~4,1%%t:~3,1%%t:~2,1%%t:~1,1%%t:~0,1%-%t:~11,1%%t:~10,1%%t:~9,1%%t:~8,1%-%t:~15,1%%t:~14,1%%t:~13,1%%t:~12,1%-%t:~17,1%%t:~16,1%%t:~19,1%%t:~18,1%
set guid=%guid%-%t:~21,1%%t:~20,1%%t:~23,1%%t:~22,1%%t:~25,1%%t:~24,1%%t:~27,1%%t:~26,1%%t:~29,1%%t:~28,1%%t:~31,1%%t:~30,1%
goto :eof
