if (-not (Get-AppxPackage -Name MSTeams))
{
	Write-Warning -Message Teams is not installed
	return
}

Get-Process -Name ms-teams -ErrorAction Ignore | Stop-Process -Force

try
{
	$config = Get-Content -Path $env:LOCALAPPDATA\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams\app_settings.json -Force | ConvertFrom-Json
}
catch [System.Exception]
{
	Write-Verbose "JSON is not valid!" -Verbose

	Invoke-Item -Path $env:LOCALAPPDATA\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams

	break
}

# Theme like in Windows
if ($config.theme)
{
	$config.theme = 3
}
else
{
	$config | Add-Member -Name theme -MemberType NoteProperty -Value 3 -Force
}

# Auto-start application
New-ItemProperty -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\MSTeams_8wekyb3d8bbwe\TeamsTfwStartupTask" -Name State -PropertyType DWord -Value 0 -Force

ConvertTo-Json -InputObject $config -Depth 4 | Set-Content -Path $env:LOCALAPPDATA\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams\app_settings.json -Force
