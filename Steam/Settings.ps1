Stop-Process -Name steam -Force -ErrorAction Ignore

# Enable "Fluent for Steam" skin
New-ItemProperty -Path HKCU:\Software\Valve\Steam -Name SkinV5 -PropertyType String -Value "Fluent-for-Steam (Early Acess - Experimental)" -Force

# Do not notify me about additions or changes to my games, new releases, and upcoming releases
(Get-Content -Path "${env:ProgramFiles(x86)}\Steam\userdata\*\config\localconfig.vdf" -Encoding UTF8) | ForEach-Object -Process {
	$_ -replace "`"NotifyAvailableGames`"		`"1`"", "`"NotifyAvailableGames`"		`"0`""
} | Set-Content -Path "${env:ProgramFiles(x86)}\Steam\userdata\*\config\localconfig.vdf" -Encoding UTF8 -Force

# Remove Steam from autostart
Remove-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Run -Name Steam -Force -ErrorAction Ignore
