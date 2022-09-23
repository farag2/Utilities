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

# https://github.com/mwittrien/BetterDiscordAddons/blob/master/Library/0BDFDB.plugin.js
# Needed for ReadAllNotificationsButton
$Parameters = @{
	Uri             = "https://raw.githubusercontent.com/mwittrien/BetterDiscordAddons/master/Library/0BDFDB.plugin.js"
	OutFile         = "$env:APPDATA\BetterDiscord\plugins\0BDFDB.plugin.js"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-Webrequest @Parameters

# https://github.com/rauenzi/BDPluginLibrary/blob/master/release/0PluginLibrary.plugin.js
# Needed for HideDisabledEmojis
$Parameters = @{
	Uri             = "https://raw.githubusercontent.com/rauenzi/BDPluginLibrary/master/release/0PluginLibrary.plugin.js"
	OutFile         = "$env:APPDATA\BetterDiscord\plugins\0PluginLibrary.plugin.js"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-Webrequest @Parameters

# https://github.com/mwittrien/BetterDiscordAddons/blob/master/Plugins/ReadAllNotificationsButton/ReadAllNotificationsButton.plugin.js
$Parameters = @{
	Uri             = "https://raw.githubusercontent.com/mwittrien/BetterDiscordAddons/master/Plugins/ReadAllNotificationsButton/ReadAllNotificationsButton.plugin.js"
	OutFile         = "$env:APPDATA\BetterDiscord\plugins\ReadAllNotificationsButton.plugin.js"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-Webrequest @Parameters

#https://github.com/rauenzi/BetterDiscordAddons/blob/master/Plugins/DoNotTrack/DoNotTrack.plugin.js
$Parameters = @{
	Uri             = "https://raw.githubusercontent.com/rauenzi/BetterDiscordAddons/master/Plugins/DoNotTrack/DoNotTrack.plugin.js"
	OutFile         = "$env:APPDATA\BetterDiscord\plugins\DoNotTrack.plugin.jss"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-Webrequest @Parameters

# https://github.com/rauenzi/BetterDiscordAddons/blob/master/Plugins/HideDisabledEmojis/HideDisabledEmojis.plugin.js
$Parameters = @{
	Uri             = "https://raw.githubusercontent.com/rauenzi/BetterDiscordAddons/master/Plugins/HideDisabledEmojis/HideDisabledEmojis.plugin.js"
	OutFile         = "$env:APPDATA\BetterDiscord\plugins\HideDisabledEmojis.plugin.js"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-Webrequest @Parameters

# https://github.com/TakosThings/Fluent-Discord
$Parameters = @{
	Uri             = "https://api.github.com/repos/TakosThings/Fluent-Discord/releases/latest"
	UseBasicParsing = $true
	Verbose         = $true
}
$Tag = (Invoke-RestMethod @Parameters).tag_name
$Parameters = @{
	Uri             = "https://github.com/TakosThings/Fluent-Discord/releases/download/$Tag/Fluent-Discord.theme.css"
	OutFile         = "$env:APPDATA\BetterDiscord\themes\Fluent-Discord.theme.css"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-Webrequest @Parameters

# https://github.com/oSumAtrIX/BetterDiscordPlugins/blob/master/NitroEmoteAndScreenShareBypass.plugin.js
$Parameters = @{
	Uri             = "https://raw.githubusercontent.com/oSumAtrIX/BetterDiscordPlugins/master/NitroEmoteAndScreenShareBypass.plugin.js"
	OutFile         = "$env:APPDATA\BetterDiscord\plugins\NitroEmoteAndScreenShareBypass.plugin.js"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-Webrequest @Parameters
