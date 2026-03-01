[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($Host.Version.Major -eq 5)
{
	# Progress bar can significantly impact cmdlet performance
	# https://github.com/PowerShell/PowerShell/issues/2138
	$Script:ProgressPreference = "SilentlyContinue"
}

Write-Information -MessageData "" -InformationAction Continue
Write-Verbose -Message "Downloading Better Discord" -Verbose
Write-Information -MessageData "" -InformationAction Continue

try
{
	# https://github.com/BetterDiscord/BetterDiscord
	$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
	$Parameters = @{
		Uri             = "https://github.com/BetterDiscord/Installer/releases/latest/download/BetterDiscord-Windows.exe"
		OutFile         = "$DownloadsFolder\BetterDiscord-Windows.exe"
		UseBasicParsing = $true
		Verbose         = $true
	}
	Invoke-Webrequest @Parameters
}
catch [System.Net.WebException]
{
	Write-Information -MessageData "" -InformationAction Continue
	Write-Verbose -Message "Connection could not be established with https://github.com" -Verbose

	pause
	exit
}

Get-Process -Name Discord -ErrorAction Ignore | Stop-Process -Force


Start-Process -FilePath "$DownloadsFolder\BetterDiscord-Windows.exe" -Wait
Remove-Item -Path "$DownloadsFolder\BetterDiscord-Windows.exe" -Force

Write-Information -MessageData "" -InformationAction Continue
Write-Verbose -Message "Downloading Fluent Discord Theme" -Verbose
Write-Information -MessageData "" -InformationAction Continue

try
{
	# https://github.com/TakosThings/Fluent-Discord
	$Parameters = @{
		Uri             = "https://takosthings.github.io/Fluent-Discord/Fluent-Discord.theme.css"
		OutFile         = "$env:APPDATA\BetterDiscord\themes\Fluent-Discord.theme.css"
		UseBasicParsing = $true
		Verbose         = $true
	}
	Invoke-RestMethod @Parameters
}
catch [System.Net.WebException]
{
	Write-Information -MessageData "" -InformationAction Continue
	Write-Verbose -Message "Connection could not be established with https://github.com" -Verbose

	pause
	exit
}

Write-Information -MessageData "" -InformationAction Continue
Write-Verbose -Message "Downloading YABDP4Nitro Plugin" -Verbose
Write-Information -MessageData "" -InformationAction Continue

# https://github.com/riolubruh/YABDP4Nitro/blob/main/YABDP4Nitro.plugin.js
try
{
	$Parameters = @{
		Uri             = "https://raw.githubusercontent.com/riolubruh/YABDP4Nitro/main/YABDP4Nitro.plugin.js"
		OutFile         = "$env:APPDATA\BetterDiscord\plugins\YABDP4Nitro.plugin.js"
		UseBasicParsing = $true
		Verbose         = $true
	}
	Invoke-Webrequest @Parameters
}
catch [System.Net.WebException]
{
	Write-Information -MessageData "" -InformationAction Continue
	Write-Verbose -Message "Connection could not be established with https://github.com" -Verbose

	pause
	exit
}

& $env:LOCALAPPDATA\Discord\Update.exe --processStart Discord.exe
