# Downloading Firefox Setup.exe
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$LatestStableVersion = (Invoke-WebRequest -Uri "https://product-details.mozilla.org/1.0/firefox_versions.json" | ConvertFrom-Json).LATEST_FIREFOX_VERSION
$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$Language = (Get-WinSystemLocale).Parent.Name
$Parameters = @{
	Uri = "https://ftp.mozilla.org/pub/firefox/releases/$($LatestStableVersion)/win64-EME-free/$($Language)/Firefox%20Setup%20$($LatestStableVersion).exe"
	OutFile = "$DownloadsFolder\Firefox Setup $($LatestStableVersion).exe"
	Verbose = [switch]::Present
}
Invoke-WebRequest @Parameters

# Extracting Firefox.exe to the "Firefox Setup xx" folder
# https://firefox-source-docs.mozilla.org/browser/installer/windows/installer/FullConfig.html
# Don't paste quotes after /ExtractDir even if a path contains spaces
Start-Process -FilePath "$DownloadsFolder\Firefox Setup $($LatestStableVersion).exe" -ArgumentList "/ExtractDir=$DownloadsFolder\Firefox Setup $($LatestStableVersion)" -Wait

$Setupini = @"
[Install]
TaskbarShortcut=false
DesktopShortcut=false
StartMenuShortcuts=true
MaintenanceService=true
PreventRebootRequired=false
OptionalExtensions=true
RegisterDefaultAgent=false
"@
Set-Content -Path "$DownloadsFolder\Firefox Setup $($LatestStableVersion)\setup.ini" -Value $Setupini -Encoding Default -Force

# 
$Setupini = @'
"%~dp0setup.exe" /INI=$($DownloadsFolder\Firefox Setup $($LatestStableVersion)\setup.ini)
'@
Set-Content -Path "$DownloadsFolder\Firefox Setup $($LatestStableVersion)\setup.cmd" -Value $Setupini -Encoding Default -Force
