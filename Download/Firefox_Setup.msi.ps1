# Downloading Firefox Setup xx.msi
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($Host.Version.Major -eq 5)
{
	# Progress bar can significantly impact cmdlet performance
	# https://github.com/PowerShell/PowerShell/issues/2138
	$Script:ProgressPreference = "SilentlyContinue"
}

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

$Parameters = @{
	Uri             = "https://product-details.mozilla.org/1.0/firefox_versions.json"
	UseBasicParsing = $true
	Verbose         = $true
}
$LatestStableVersion = (Invoke-RestMethod @Parameters).LATEST_FIREFOX_VERSION

$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$Parameters = @{
	Uri             = "https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=$Language"
	OutFile         = "$DownloadsFolder\Firefox Setup $LatestStableVersion.msi"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-WebRequest @Parameters

# https://support.mozilla.org/kb/deploy-firefox-msi-installers
$Arguments = @(
	"DESKTOP_SHORTCUT=false",
	"START_MENU_SHORTCUT=true",
	"INSTALL_MAINTENANCE_SERVICE=true",
	"PREVENT_REBOOT_REQUIRED=false",
	"OPTIONAL_EXTENSIONS=true"
)
Start-Process -FilePath "$env:SystemRoot\System32\msiexec.exe" -ArgumentList "/i `"$DownloadsFolder\Firefox Setup $LatestStableVersion.msi`" $Arguments" -Wait

Remove-Item -Path "$DownloadsFolder\Firefox Setup $LatestStableVersion.msi" -Force
