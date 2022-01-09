$URL = ((Invoke-RestMethod -Uri "https://api.github.com/repos/coelckers/gzdoom/releases/latest").assets | Where-Object -FilterScript {$_.browser_download_url -like "*Windows-64bit.zip"}).browser_download_url

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

$Parameters = @{
	Uri     = "https://raw.githubusercontent.com/farag2/Utilities/master/Download/GZDoom/gzdoom.ini"
	OutFile = "$DownloadsFolder\GZDoom\gzdoom.ini"
	Verbose = $true
}
Invoke-WebRequest @Parameters

Get-Item -Path "$DownloadsFolder\GZDoom\gzdoom.ini" -Force | Rename-Item -NewName "gzdoom-$env:USERNAME.ini" -Force

$Parameters = @{
	Uri     = "https://raw.githubusercontent.com/farag2/Utilities/master/Download/GZDoom/_pb.cmd"
	OutFile = "$DownloadsFolder\GZDoom\_pb.cmd"
	Verbose = $true
}
Invoke-WebRequest @Parameters

$Parameters = @{
	Uri     = "https://raw.githubusercontent.com/farag2/Utilities/master/Download/GZDoom/_bd.cmd"
	OutFile = "$DownloadsFolder\GZDoom\_bd.cmd"
	Verbose = $true
}
Invoke-WebRequest @Parameters

$URLs = @(
	"https://github.com/coelckers/gzdoom/releases/",
	"https://www.moddb.com/downloads/start/95667",
	"http://iddqd.ru/levels?find=Doom%202:%20Hell%20on%20Earth"
)
foreach ($URL in $URLs)
{
	Start-Process -FilePath $URL
}
