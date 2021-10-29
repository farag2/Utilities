Get-Process -Name Teams -ErrorAction Ignore | Stop-Process -Force

try
{
	$config = Get-Content -Path $env:APPDATA\Microsoft\Teams\desktop-config.json -Force | ConvertFrom-Json
}
catch [System.Exception]
{
	Write-Verbose "JSON is not valid!" -Verbose

	Invoke-Item -Path $env:APPDATA\Microsoft\Teams

	break
}

# Enable dark theme
if ($config.theme)
{
	$config.theme = "darkV2"
}
else
{
	$config | Add-Member -Name theme -MemberType NoteProperty -Value "darkV2" -Force
}

# Auto-start application
if ($config.appPreferenceSettings.openAtLogin)
{
	$config.appPreferenceSettings.openAtLogin = $false
}
else
{
	$config.appPreferenceSettings | Add-Member -Name openAtLogin -MemberType NoteProperty -Value $false -Force
}

ConvertTo-Json -InputObject $config -Depth 4 | Set-Content -Path $env:APPDATA\Microsoft\Teams\desktop-config.json -Force
