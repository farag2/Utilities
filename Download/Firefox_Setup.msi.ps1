# Downloading Firefox Setup xx.msi
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

# Extracting Firefox.msi to the "Firefox Setup xx" folder
# https://support.mozilla.org/kb/deploy-firefox-msi-installers
Start-Process -FilePath "$DownloadsFolder\Firefox Setup $LatestStableVersion.msi" -ArgumentList "EXTRACT_DIR=`"$DownloadsFolder\Firefox Setup $LatestStableVersion`"" -Wait

Remove-Item -Path "$DownloadsFolder\Firefox Setup $LatestStableVersion\postSigningData" -Force

$Arguments = @(
	"DESKTOP_SHORTCUT=false",
	"START_MENU_SHORTCUT=true",
	"INSTALL_MAINTENANCE_SERVICE=true",
	"PREVENT_REBOOT_REQUIRED=false",
	"OPTIONAL_EXTENSIONS=true",
	# Since 103
	"TASKBAR_SHORTCUT=true"	
)
Start-Process -FilePath "$DownloadsFolder\Firefox Setup $LatestStableVersion.msi" -ArgumentList $Arguments -Wait

Remove-Item -Path "$DownloadsFolder\Firefox Setup $LatestStableVersion.msi" -Force
