# Downloading Firefox.msi
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Arch = "win64"
$Lang = "ru"
$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$Parameters = @{
	Uri = "https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=$Arch&lang=$Lang"
	OutFile = "$DownloadsFolder\Firefox.msi"
	Verbose = [switch]::Present
}
Invoke-WebRequest @Parameters

# Extracting AFirefox.msi to the "Downloads folder\Firefox" folder
$ExtractPath = "$DownloadsFolder\Firefox"
Start-Process -FilePath "$DownloadsFolder\Firefox.msi" -ArgumentList "EXTRACT_DIR=$ExtractPath" -Wait

# Removing unnecessary files
Remove-Item -Path "$DownloadsFolder\Firefox.msi", "$DownloadsFolder\Firefox\postSigningData" -Force
