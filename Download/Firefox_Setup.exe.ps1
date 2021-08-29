# Downloading Firefox Setup.exe
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Mozilla shortens some locale codes to 2 or 3 letters, so we cannot use (Get-WinSystemLocale).Name for every language
$Languages = @(
	"ach", "af", "an", "ar", "ast",
	"az", "be", "bg", "bn", "br",
	"bs", "ca", "cak", "cs", "cy",
	"da", "de", "dsb", "el", "en-CA",
	"en-GB", "en-US", "eo", "es-AR", "es-CL",
	"es-ES", "es-MX", "et", "eu", "fa",
	"ff", "fi", "fr", "fy-NL", "ga-IE",
	"gd", "gl", "gn", "gu-IN", "he",
	"hi-IN", "hr", "hsb", "hu", "hy-AM",
	"ia", "id", "is", "it", "ja",
	"ka", "kab", "kk", "km", "kn",
	"ko", "lij", "lt", "lv", "mk",
	"mr", "ms", "my", "nb-NO", "ne-NP",
	"nl", "nn-NO", "oc", "pa-IN", "pl",
	"pt-BR", "pt-PT", "rm", "ro", "ru",
	"si", "sk", "sl", "son", "sq",
	"sr", "sv-SE", "ta", "te", "th",
	"tr", "uk", "ur", "uz", "vi",
	"xh", "zh-CN", "zh-TW"
)
if ((Get-WinSystemLocale).Name -in $Languages)
{
	$Language = (Get-WinSystemLocale).Name
}
else
{
	$Language = (Get-WinSystemLocale).Parent.Name
}

$LatestStableVersion = (Invoke-RestMethod -Uri "https://product-details.mozilla.org/1.0/firefox_versions.json" -UseBasicParsing).LATEST_FIREFOX_VERSION
$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$Parameters = @{
	Uri             = "https://ftp.mozilla.org/pub/firefox/releases/$LatestStableVersion/win64-EME-free/$Language/Firefox%20Setup%20$LatestStableVersion.exe"
	OutFile         = "$DownloadsFolder\Firefox Setup $LatestStableVersion.exe"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-WebRequest @Parameters

# Extracting Firefox.exe to the "Firefox Setup xx" folder
# https://firefox-source-docs.mozilla.org/browser/installer/windows/installer/FullConfig.html
# Don't paste quotes after /ExtractDir even if a path contains spaces
Start-Process -FilePath "$DownloadsFolder\Firefox Setup $LatestStableVersion.exe" -ArgumentList "/ExtractDir=$DownloadsFolder\Firefox Setup $LatestStableVersion" -Wait

# It isn’t possible to create taskbar pins on Windows 10 and later
$Setupini = @"
[Install]
DesktopShortcut=false
StartMenuShortcut=true
MaintenanceService=true
PreventRebootRequired=false
OptionalExtensions=true
RegisterDefaultAgent=false
"@
Set-Content -Path "$DownloadsFolder\Firefox Setup $LatestStableVersion\setup.ini" -Value $Setupini -Encoding Default -Force

# Create a batch file
$Setupcmd = @"
`"%~dp0setup.exe`" /INI=`"%~dp0setup.ini`"
"@
Set-Content -Path "$DownloadsFolder\Firefox Setup $LatestStableVersion\setup.cmd" -Value $Setupcmd -Encoding Default -Force

Remove-Item -Path "$DownloadsFolder\Firefox Setup $LatestStableVersion.exe" -Force
