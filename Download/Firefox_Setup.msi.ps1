# Downloading Firefox Setup xx.msi
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$LatestStableVersion = (Invoke-WebRequest -Uri "https://product-details.mozilla.org/1.0/firefox_versions.json" | ConvertFrom-Json).LATEST_FIREFOX_VERSION
$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$Language = (Get-WinSystemLocale).Parent.Name # ru
$Parameters = @{
	Uri = "https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=$Language"
	OutFile = "$DownloadsFolder\Firefox Setup $($LatestStableVersion).msi"
	Verbose = [switch]::Present
}
Invoke-WebRequest @Parameters

# Extracting Firefox.msi to the "Firefox Setup xx" folder
# https://support.mozilla.org/kb/deploy-firefox-msi-installers
Start-Process -FilePath "$DownloadsFolder\Firefox Setup $($LatestStableVersion).msi" -ArgumentList "EXTRACT_DIR=`"$DownloadsFolder\Firefox Setup $($LatestStableVersion)`"" -Wait

Remove-Item -Path "$DownloadsFolder\Firefox Setup $($LatestStableVersion)\postSigningData" -Force

# It isn’t possible to create taskbar pins on Windows 10 and later
$Arguments = @(
    "DESKTOP_SHORTCUT=false",
    "START_MENU_SHORTCUT=true",
    "INSTALL_MAINTENANCE_SERVICE=true",
    "PREVENT_REBOOT_REQUIRED=false",
    "OPTIONAL_EXTENSIONS=true"
)

Start-Process -FilePath "$DownloadsFolder\Firefox Setup $LatestStableVersion.msi" -ArgumentList $Arguments -Wait
