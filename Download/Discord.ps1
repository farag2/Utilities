Get-Process -Name Discord -ErrorAction Ignore | Stop-Process -Force

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($Host.Version.Major -eq 5)
{
	# Progress bar can significantly impact cmdlet performance
	# https://github.com/PowerShell/PowerShell/issues/2138
	$Script:ProgressPreference = "SilentlyContinue"
}

# https://github.com/BetterDiscord/BetterDiscord
$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$Parameters = @{
	Uri             = "https://github.com/BetterDiscord/Installer/releases/latest/download/BetterDiscord-Windows.exe"
	OutFile         = "$DownloadsFolder\BetterDiscord-Windows.exe"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-Webrequest @Parameters

Start-Process -FilePath "$DownloadsFolder\BetterDiscord-Windows.exe" -Wait
Remove-Item -Path "$DownloadsFolder\BetterDiscord-Windows.exe" -Force

# https://github.com/DiscordStyles/Fluent
$Parameters = @{
	Uri             = "https://raw.githubusercontent.com/DiscordStyles/Fluent/deploy/Fluent.theme.css"
	OutFile         = "$env:APPDATA\BetterDiscord\themes\Fluent.theme.css"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-RestMethod @Parameters

$Plugins = @(
	# https://github.com/mwittrien/BetterDiscordAddons/blob/master/Library/0BDFDB.plugin.js
	# Needed for ReadAllNotificationsButton
	"https://raw.githubusercontent.com/mwittrien/BetterDiscordAddons/master/Library/0BDFDB.plugin.js",

	# https://github.com/mwittrien/BetterDiscordAddons/blob/master/Plugins/ReadAllNotificationsButton/ReadAllNotificationsButton.plugin.js
	"https://raw.githubusercontent.com/mwittrien/BetterDiscordAddons/master/Plugins/ReadAllNotificationsButton/ReadAllNotificationsButton.plugin.js",

	# https://github.com/oSumAtrIX/BetterDiscordPlugins/blob/master/NitroEmoteAndScreenShareBypass.plugin.js
	"https://raw.githubusercontent.com/oSumAtrIX/BetterDiscordPlugins/master/NitroEmoteAndScreenShareBypass.plugin.js"
)
foreach ($Plugin in $Plugins)
{
	$Parameters = @{
		Uri             = $Plugin
		OutFile         = "$env:APPDATA\BetterDiscord\plugins\$(Split-Path -Path $Plugin -Leaf)"
		UseBasicParsing = $true
		Verbose         = $true
	}
	Invoke-Webrequest @Parameters
}
