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
	Uri             = "https://takosthings.github.io/Fluent-Discord/Fluent-Discord.theme.css"
	OutFile         = "$env:APPDATA\BetterDiscord\themes\Fluent-Discord.theme.css"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-RestMethod @Parameters

$Plugins = @(
	# https://github.com/riolubruh/YABDP4Nitro/blob/main/YABDP4Nitro.plugin.js
	"https://raw.githubusercontent.com/riolubruh/YABDP4Nitro/main/YABDP4Nitro.plugin.js"
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

& $env:LOCALAPPDATA\Discord\Update.exe --processStart Discord.exe
