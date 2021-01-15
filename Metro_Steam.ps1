[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"

$Tag = ((Invoke-RestMethod -Uri "https://api.github.com/repos/minischetti/metro-for-steam/releases") | Where-Object -FilterScript {$_.prerelease -eq $false}).tag_name
$Parameters = @{
	Uri = "https://github.com/minischetti/metro-for-steam/archive/v4.4.zip"
	OutFile = "$DownloadsFolder\metro-for-steam.zip"
	Verbose = [switch]::Present
}
Invoke-WebRequest @Parameters

$Parameters = @{
	Path = "$DownloadsFolder\metro-for-steam.zip"
	DestinationPath = "$DownloadsFolder\Metro"
	Force = [switch]::Present
	Verbose = [switch]::Present
}
Expand-Archive @Parameters

$Parameters = @{
	Uri = "https://github.com/redsigma/UPMetroSkin/archive/master.zip"
	OutFile = "$DownloadsFolder\UPMetroSkin.zip"
	Verbose = [switch]::Present
}
Invoke-WebRequest @Parameters

$Parameters = @{
	Path = "$DownloadsFolder\UPMetroSkin.zip"
	DestinationPath = "$DownloadsFolder\Metro"
	Force = [switch]::Present
	Verbose = [switch]::Present
}
Expand-Archive @Parameters

Move-Item -LiteralPath "$DownloadsFolder\Metro\UPMetroSkin-master\Unofficial 4.x Patch\Main Files [Install First]" -Destination "$DownloadsFolder\Metro\metro-for-steam-4.4" -Force
Get-ChildItem -Path "$DownloadsFolder\Metro\metro-for-steam-4.4" -Recurse -Force | Move-Item -Destination "$DownloadsFolder\Metro" -Force
Remove-Item -Path "$DownloadsFolder\metro-for-steam.zip", "$DownloadsFolder\UPMetroSkin.zip" -Force
Get-ChildItem -Path "$DownloadsFolder\Metro\UPMetroSkin-master", "$DownloadsFolder\Metro\metro-for-steam-4.4" -Recurse -Force | Remove-Item -Recurse -Force

# Get-ChildItem -Path "$DownloadsFolder\Metro" -Recurse -Force | Move-Item -Destination "$env:ProgramFiles\Steam\Skins" -Force
