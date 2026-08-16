# uzdoom.exe -iwad ABYSAP.wad -file brutal22test6.pk3 EdayTest001.pk3 EdayMusic001.wad

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($Host.Version.Major -eq 5)
{
	# Progress bar can significantly impact cmdlet performance
	# https://github.com/PowerShell/PowerShell/issues/2138
	$Script:ProgressPreference = "SilentlyContinue"
}

# https://github.com/UZDoom/UZDoom
$Parameters = @{
	Uri             = "https://api.github.com/repos/UZDoom/UZDoom/releases/latest"
	UseBasicParsing = $true
	Verbose         = $true
}
$URL = ((Invoke-RestMethod @Parameters).assets | Where-Object -FilterScript {$_.name -match "windows"}).browser_download_url

$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$Parameters = @{
	Uri             = $URL
	OutFile         = "$DownloadsFolder\UZDoom.zip"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-WebRequest @Parameters

$Parameters = @{
	Path            = "$DownloadsFolder\UZDoom.zip"
	DestinationPath = "$DownloadsFolder\UZDoom"
	Force           = $true
	Verbose         = $true
}
Expand-Archive @Parameters

# https://www.moddb.com/mods/brutal-doom/downloads/brutal-doom-v22-beta-test
Start-Process -FilePath https://www.moddb.com/mods/brutal-doom/downloads/brutal-doom-v22-beta-test

# https://github.com/farag2/Utilities/tree/master/Download/GZDoom
$Parameters = @{
	Uri             = "https://github.com/farag2/Utilities/raw/master/Download/GZDoom/doom2.wad"
	OutFile         = "$DownloadsFolder\GZDoom\doom2.wad"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-Webrequest @Parameters
