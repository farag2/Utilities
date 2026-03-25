$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")
if (-not $IsAdmin)
{
	Start-Process powershell.exe -Verb Runas -ArgumentList "-ExecutionPolicy Bypass -NoProfile -NoLogo -WindowStyle Hidden -File `"$PSCommandPath`""
	exit
}

Start-Process -FilePath "$PSScriptRoot\..\TeamViewer.exe" -Wait

Start-Sleep -Seconds 3
TAKEOWN /F "$PSScriptRoot\..\rolloutfile.tv13"
ICACLS "$PSScriptRoot\..\rolloutfile.tv13" --% /grant:r %USERNAME%:F
Remove-Item -Path "$PSScriptRoot\..\rolloutfile.tv13", $env:LOCALAPPDATA\TeamViewer, $env:APPDATA\TeamViewer -Recurse -Force
Remove-Item -Path HKCU:\Software\TeamViewer -Recurse -Force
exit
