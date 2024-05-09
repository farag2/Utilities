[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($Host.Version.Major -eq 5)
{
	# Progress bar can significantly impact cmdlet performance
	# https://github.com/PowerShell/PowerShell/issues/2138
	$Script:ProgressPreference = "SilentlyContinue"
}

# https://github.com/ZDoom/gzdoom
$Parameters = @{
	Uri             = "https://api.github.com/repos/coelckers/gzdoom/releases/latest"
	UseBasicParsing = $true
	Verbose         = $true
}
$URL = ((Invoke-RestMethod @Parameters).assets | Where-Object -FilterScript {$_.name -match "windows.zip"}).browser_download_url

$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$Parameters = @{
	Uri             = $URL
	OutFile         = "$DownloadsFolder\GZDoom.zip"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-WebRequest @Parameters

$Parameters = @{
	Path            = "$DownloadsFolder\GZDoom.zip"
	DestinationPath = "$DownloadsFolder\GZDoom"
	Force           = $true
	Verbose         = $true
}
Expand-Archive @Parameters

# https://github.com/farag2/Utilities/tree/master/Download/GZDoom
$Parameters = @{
	Uri             = "https://raw.githubusercontent.com/farag2/Utilities/master/Download/GZDoom/gzdoom.ini"
	OutFile         = "$DownloadsFolder\GZDoom\gzdoom.ini"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-WebRequest @Parameters

Get-Item -Path "$DownloadsFolder\GZDoom\gzdoom.ini" -Force | Rename-Item -NewName "gzdoom-$env:USERNAME.ini" -Force

# https://github.com/farag2/Utilities/tree/master/Download/GZDoom
$Parameters = @{
	Uri             = "https://raw.githubusercontent.com/farag2/Utilities/master/Download/GZDoom/_pb.cmd"
	OutFile         = "$DownloadsFolder\GZDoom\_pb.cmd"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-WebRequest @Parameters

# https://github.com/farag2/Utilities/tree/master/Download/GZDoom
$Parameters = @{
	Uri             = "https://raw.githubusercontent.com/farag2/Utilities/master/Download/GZDoom/_bd.cmd"
	OutFile         = "$DownloadsFolder\GZDoom\_bd.cmd"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-WebRequest @Parameters

# https://www.moddb.com/mods/brutal-doom/downloads/brutal-doom-v21-beta
# Expand archive manualy
$Parameters = @{
	Uri             = "https://www.moddb.com/downloads/start/95667"
	UseBasicParsing = $false # Disabled
	Verbose         = $true
}
$Request = Invoke-Webrequest @Parameters
$URL = $Request.ParsedHtml.getElementsByTagName("a") | ForEach-Object -Process {$_.pathname} | Where-Object -FilterScript {$_ -match "mirror"}
$Parameters = @{
	Uri             = "https://www.moddb.com/$URL"
	OutFile         = "$DownloadsFolder\db.zip"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-Webrequest @Parameters

# https://github.com/farag2/Utilities/tree/master/Download/GZDoom
$Parameters = @{
	Uri             = "https://github.com/farag2/Utilities/raw/master/Download/GZDoom/doom2.wad"
	OutFile         = "$DownloadsFolder\GZDoom\doom2.wad"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-Webrequest @Parameters

$Parameters = @(
	"$DownloadsFolder\GZDoom.zip",
	"$DownloadsFolder\GZDoom\fm_banks",
	"$DownloadsFolder\GZDoom\licenses.zip"
)
Remove-Item -Path $Parameters -Recurse -Force
