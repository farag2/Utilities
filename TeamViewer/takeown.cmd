takeown /F %~dp0rolloutfile.tv13
icacls %~dp0rolloutfile.tv13 /grant:r %username%:F
DEL %~dp0rolloutfile.tv13 /F /Q

reg delete HKCU\Software\TeamViewer /F
RMDIR %LOCALAPPDATA%\TeamViewer /S /Q
RMDIR %APPDATA%\TeamViewer /S /Q