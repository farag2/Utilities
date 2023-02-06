# Download 7Zip

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Get the latest 7-Zip download URL
$Parameters = @{
	Uri             = "https://sourceforge.net/projects/sevenzip/best_release.json"
	UseBasicParsing = $true
	Verbose         = $true
}
$bestRelease = (Invoke-RestMethod @Parameters).platform_releases.windows.filename.replace("exe", "msi")

# Download the latest 7-Zip x64
$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$Parameters = @{
	Uri             = "https://nchc.dl.sourceforge.net/project/sevenzip$($bestRelease)"
	OutFile         = "$DownloadsFolder\7-Zip.msi"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-WebRequest @Parameters

Start-Process -FilePath "$DownloadsFolder\7-Zip.msi" -ArgumentList "/quiet" -Wait

if (-not (Test-Path -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\7-Zip File Manager.lnk"))
{
	Copy-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\7-Zip\7-Zip File Manager.lnk" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force
	Remove-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\7-Zip" -Recurse -Force
}

if (-not (Test-Path -Path HKCU:\SOFTWARE\7-Zip\Options))
{
	New-Item -Path HKCU:\SOFTWARE\7-Zip\Options -Force
}
New-ItemProperty -Path HKCU:\SOFTWARE\7-Zip\Options -Name ContextMenu -PropertyType DWord -Value 4192 -Force
New-ItemProperty -Path HKCU:\SOFTWARE\7-Zip\Options -Name MenuIcons -PropertyType DWord -Value 1 -Force

Start-Process -FilePath "$env:ProgramFiles\7-Zip\7zFM.exe" -Wait
