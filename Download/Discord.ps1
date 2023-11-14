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

# https://github.com/TakosThings/Fluent-Discord
$Parameters = @{
	Uri             = "https://api.github.com/repos/TakosThings/Fluent-Discord/releases/latest"
	UseBasicParsing = $true
	Verbose         = $true
}
$FluentDiscordTag = (Invoke-RestMethod @Parameters).tag_name

$Plugins = @(
	# https://github.com/mwittrien/BetterDiscordAddons/blob/master/Library/0BDFDB.plugin.js
	# Needed for ReadAllNotificationsButton
	"https://raw.githubusercontent.com/mwittrien/BetterDiscordAddons/master/Library/0BDFDB.plugin.js",

	# https://github.com/mwittrien/BetterDiscordAddons/blob/master/Plugins/ReadAllNotificationsButton/ReadAllNotificationsButton.plugin.js
	"https://raw.githubusercontent.com/mwittrien/BetterDiscordAddons/master/Plugins/ReadAllNotificationsButton/ReadAllNotificationsButton.plugin.js",

	# https://github.com/TakosThings/Fluent-Discord
	"https://github.com/TakosThings/Fluent-Discord/releases/download/$FluentDiscordTag/Fluent-Discord.theme.css",

	# https://github.com/oSumAtrIX/BetterDiscordPlugins/blob/master/NitroEmoteAndScreenShareBypass.plugin.js
	"https://raw.githubusercontent.com/oSumAtrIX/BetterDiscordPlugins/master/NitroEmoteAndScreenShareBypass.plugin.js"
)
foreach ($Plugin in $Plugins)
{
	if ($(Split-Path -Path $Plugin -Leaf) -eq "Fluent-Discord.theme.css")
	{
		$Parameters = @{
			Uri             = $Plugin
			OutFile         = "$env:APPDATA\BetterDiscord\themes\$(Split-Path -Path $Plugin -Leaf)"
			UseBasicParsing = $true
			Verbose         = $true
		}
		Invoke-Webrequest @Parameters
	}

	$Parameters = @{
		Uri             = $Plugin
		OutFile         = "$env:APPDATA\BetterDiscord\plugins\$(Split-Path -Path $Plugin -Leaf)"
		UseBasicParsing = $true
		Verbose         = $true
	}
	Invoke-Webrequest @Parameters
}
