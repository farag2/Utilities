[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($Host.Version.Major -eq 5)
{
	# Progress bar can significantly impact cmdlet performance
	# https://github.com/PowerShell/PowerShell/issues/2138
	$Script:ProgressPreference = "SilentlyContinue"
}

# https://github.com/ZDoom/gzdoom
# Downloading GZDoom
$Parameters = @{
	Uri             = "https://api.github.com/repos/coelckers/gzdoom/releases/latest"
	UseBasicParsing = $true
	Verbose         = $true
}
$URL = ((Invoke-RestMethod @Parameters).assets | Where-Object -FilterScript {$_.browser_download_url -like "*Windows-64bit.zip"}).browser_download_url

$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$Parameters = @{
	Uri     = $URL
	OutFile = "$DownloadsFolder\GZDoom.zip"
	Verbose = $true
}
Invoke-WebRequest @Parameters

$Parameters = @{
	Path            = "$DownloadsFolder\GZDoom.zip"
	DestinationPath = "$DownloadsFolder\GZDoom"
	Force           = $true
	Verbose         = $true
}
Expand-Archive @Parameters

$Parameters = @(
	"$DownloadsFolder\GZDoom.zip",
	"$DownloadsFolder\GZDoom\fm_banks",
	"$DownloadsFolder\GZDoom\licenses.zip"
)
Remove-Item -Path $Parameters -Recurse -Force

# https://github.com/farag2/Utilities/tree/master/Download/GZDoom
$Parameters = @{
	Uri     = "https://raw.githubusercontent.com/farag2/Utilities/master/Download/GZDoom/gzdoom.ini"
	OutFile = "$DownloadsFolder\GZDoom\gzdoom.ini"
	Verbose = $true
}
Invoke-WebRequest @Parameters

Get-Item -Path "$DownloadsFolder\GZDoom\gzdoom.ini" -Force | Rename-Item -NewName "gzdoom-$env:USERNAME.ini" -Force

# https://github.com/farag2/Utilities/tree/master/Download/GZDoom
$Parameters = @{
	Uri     = "https://raw.githubusercontent.com/farag2/Utilities/master/Download/GZDoom/_pb.cmd"
	OutFile = "$DownloadsFolder\GZDoom\_pb.cmd"
	Verbose = $true
}
Invoke-WebRequest @Parameters

# https://github.com/farag2/Utilities/tree/master/Download/GZDoom
$Parameters = @{
	Uri     = "https://raw.githubusercontent.com/farag2/Utilities/master/Download/GZDoom/_bd.cmd"
	OutFile = "$DownloadsFolder\GZDoom\_bd.cmd"
	Verbose = $true
}
Invoke-WebRequest @Parameters

# https://www.moddb.com/mods/brutal-doom/downloads/brutal-doom-v21-beta
# Downloading Brutal Doom v21
# Skip Internet Explorer first run wizard to let script use Trident function to parse sites
if (-not (Test-Path -Path "HKLM:\Software\Policies\Microsoft\Internet Explorer\Main"))
{
	New-Item -Path "HKLM:\Software\Policies\Microsoft\Internet Explorer\Main" -ItemType Directory -Force
}
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Internet Explorer\Main" -Name DisableFirstRunCustomize -PropertyType String -Value 1 -Force

$Parameters = @{
	Uri             = "https://www.moddb.com/downloads/start/95667"
	UseBasicParsing = $false # Disabled
	Verbose         = $true
}
$Request = Invoke-Webrequest @Parameters
$URL = $Request.ParsedHtml.getElementsByTagName("a") | ForEach-Object -Process {$_.pathname} | Where-Object -FilterScript {$_ -match "mirror"}
$Parameters = @{
	Uri             = "https://www.moddb.com/$URL"
	OutFile         = "$DownloadsFolder\db.rar"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-Webrequest @Parameters

# 
$Parameters = @{
	Uri             = "http://iddqd.ru/download?idclick=doom/levels/doom2_wad.7z&title=Doom%202:%20Hell%20on%20Earth&where=levels"
	OutFile         = "$DownloadsFolder\doom2.7z"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-Webrequest @Parameters
