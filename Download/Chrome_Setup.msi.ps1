# Downloading the latest Chrome
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# https://chromeenterprise.google/browser/download
$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$Parameters = @{
	Uri     = "https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi"
	OutFile = "$DownloadsFolder\googlechromestandaloneenterprise64.msi"
	Verbose = [switch]::Present
}
Invoke-WebRequest @Parameters

Start-Process -FilePath "$DownloadsFolder\googlechromestandaloneenterprise64.msi" -Wait
