Start-Process -FilePath "$PSScriptRoot\..\AlterID.exe" -ArgumentList "-silent" -Wait

powershell.exe -NoProfile -NoLogo -Command Start-Process powershell -WindowStyle Hidden -ArgumentList "{
	Start-Sleep -Seconds 3
	TAKEOWN /F '$PSScriptRoot\..\rolloutfile.tv13'
	ICACLS '$PSScriptRoot\..\rolloutfile.tv13' --% /grant:r %USERNAME%:F
	Remove-Item -Path '$PSScriptRoot\..\rolloutfile.tv13' -Force
	Remove-Item -Path HKCU:\Software\TeamViewer -Recurse -Force -ErrorAction Ignore
	Remove-Item $env:LOCALAPPDATA\TeamViewer -Recurse -Force
	Remove-Item $env:APPDATA\TeamViewer -Recurse -Force
	exit
}" -Verb RunAs