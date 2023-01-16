Stop-Process -Name steam -Force -ErrorAction Ignore

# Enable "Fluent for Steam" skin
if (Test-Path -Path "${env:ProgramFiles(x86)}\Steam\skins\Fluent-for-Steam*")
{
	$Theme = (Get-ChildItem -Path "${env:ProgramFiles(x86)}\Steam\skins\Fluent-for-Steam*").Name
	New-ItemProperty -Path HKCU:\Software\Valve\Steam -Name SkinV5 -PropertyType String -Value $Theme -Force
}

foreach ($folder in @(Get-ChildItem -Path "${env:ProgramFiles(x86)}\Steam\userdata" -Force -Directory))
{
	if (Test-Path -Path $folder.FullName)
	{
		(Get-Content -Path "$($folder.PSPath)\config\localconfig.vdf" -Encoding UTF8) | ForEach-Object -Process {
			$_.replace(
				# Do not notify me about additions or changes to my games, new releases, and upcoming releases
				"`"NotifyAvailableGames`"		`"1`"", "`"NotifyAvailableGames`"		`"0`"").replace(
				# Display Steam URL address bar when available
				"`"NavUrlBar`"		`"0`"", "`"NavUrlBar`"		`"1`""
			)
		} | Set-Content -Path "$($folder.PSPath)\config\localconfig.vdf" -Encoding UTF8 -Force

		# Select which Steam window appears when the program starts: Library
		(Get-Content -Path "$($folder.PSPath)\7\remote\sharedconfig.vdf" -Encoding UTF8) | ForEach-Object -Process {
			$_.replace("`"SteamDefaultDialog`"		`"#app_store`"", "`"SteamDefaultDialog`"		`"#app_games`"")
		} | Set-Content -Path "$($folder.PSPath)\7\remote\sharedconfig.vdf" -Encoding UTF8 -Force
	}
	else
	{
		Write-Verbose -Message "No userdata folder" -Verbose
	}
}

# Remove Steam from autostart
Remove-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Run -Name Steam -Force -ErrorAction Ignore
