# Download Firefox Setup.exe

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($Host.Version.Major -eq 5)
{
	# Progress bar can significantly impact cmdlet performance
	# https://github.com/PowerShell/PowerShell/issues/2138
	$Script:ProgressPreference = "SilentlyContinue"
}

# Mozilla shortens some locale codes to 2 or 3 letters, so we cannot use (Get-WinSystemLocale).Name for every language
$Languages = @(
	"en-US", "en-GB", "en-CA", "es-ES",
	"es-AR", "es-CL", "es-MX", "sv-SE",
	"pt-BR", "pt-PT", "de", "fr", "it",
	"ja", "nl", "zh-TW", "ach",
	"af", "sq", "ar", "an",
	"hy-AM", "ast", "az", "eu",
	"be", "bs", "br", "bg",
	"my", "ca", "hr", "cs",
	"da", "eo", "et", "fi",
	"fy-NL", "ff", "gd", "gl",
	"ka", "el", "gn", "gu-IN",
	"he", "hi-IN", "hu", "is",
	"id", "ia", "ga-IE", "kab",
	"kn", "cak", "kk", "km",
	"ko", "lv", "lij", "lt",
	"dsb", "mk", "ms", "mr",
	"ne-NP", "nb-NO", "nn-NO", "oc",
	"fa", "pl", "pa-IN", "ro",
	"rm", "ru", "sr", "si",
	"sk", "sl", "son", "ta",
	"te", "th", "tr", "uk",
	"hsb", "ur", "uz", "vi",
	"cy", "xh"
)
if ((Get-WinSystemLocale).Name -in $Languages)
{
	$Language = (Get-WinSystemLocale).Name
}
else
{
	$Language = (Get-WinSystemLocale).Parent.Name
}

$Parameters = @{
	Uri             = "https://product-details.mozilla.org/1.0/firefox_versions.json"
	UseBasicParsing = $true
	Verbose         = $true
}
$LatestStableVersion = (Invoke-RestMethod @Parameters).LATEST_FIREFOX_VERSION

$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$Parameters = @{
	Uri             = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/$LatestStableVersion/win32/$Language/Firefox%20Setup%20$LatestStableVersion.exe"
	# Uri           = "https://download.mozilla.org/?product=firefox-latest-ssl&os=win&lang=$Language"
	# Uri           = "https://ftp.mozilla.org/pub/firefox/releases/$LatestStableVersion/win64-EME-free/$Language/Firefox%20Setup%20$LatestStableVersion.exe"
	OutFile         = "$DownloadsFolder\Firefox Setup $LatestStableVersion.exe"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-WebRequest @Parameters

# Extracting Firefox.exe to the "Firefox Setup xx" folder
# https://firefox-source-docs.mozilla.org/browser/installer/windows/installer/FullConfig.html
# Don't paste quotes after /ExtractDir even if a path contains spaces
Start-Process -FilePath "$DownloadsFolder\Firefox Setup $LatestStableVersion.exe" -ArgumentList "/ExtractDir=$DownloadsFolder\Firefox Setup $LatestStableVersion" -Wait

# https://firefox-source-docs.mozilla.org/browser/installer/windows/installer/FullConfig.html
$Setupini = @"
[Install]
DesktopShortcut=false
StartMenuShortcuts=true
MaintenanceService=true
PreventRebootRequired=false
OptionalExtensions=true
RegisterDefaultAgent=false
TaskbarShortcut=true
"@
Set-Content -Path "$DownloadsFolder\Firefox Setup $LatestStableVersion\setup.ini" -Value $Setupini -Encoding Default -Force

# Create a batch file
$Setupcmd = @"
`"%~dp0setup.exe`" /INI=`"%~dp0setup.ini`"
"@
Set-Content -Path "$DownloadsFolder\Firefox Setup $LatestStableVersion\setup.cmd" -Value $Setupcmd -Encoding Default -Force

Remove-Item -Path "$DownloadsFolder\Firefox Setup $LatestStableVersion.exe" -Force
