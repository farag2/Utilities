Start-Process -FilePath "$PSScriptRoot\..\AlterID.exe" -ArgumentList "-silent" -Wait

powershell.exe -NoProfile -NoLogo -Command Start-Process powershell -WindowStyle Hidden -ArgumentList "{
	Start-Sleep -Seconds 3

	TAKEOWN /F '$PSScriptRoot\..\rolloutfile.tv13'
	ICACLS '$PSScriptRoot\..\rolloutfile.tv13' --% /grant:r %USERNAME%:F

	$Lefovers = @(
		'$PSScriptRoot\..\rolloutfile.tv13',
		$env:LOCALAPPDATA\TeamViewer,
		$env:APPDATA\TeamViewer,
		HKCU:\Software\TeamViewer
	)
	Remove-Item -Path $Lefovers -Recurse -Force

	exit
}" -Verb RunAs
