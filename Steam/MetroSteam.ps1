[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"

# Main archive
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

# Patch
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

# Function to move files in their corresponding folders
$Source = "$DownloadsFolder\Metro\UPMetroSkin-master\Unofficial 4.x Patch\Main Files [Install First]"
$Destination = "$DownloadsFolder\Metro\metro-for-steam-4.4"

function Move-Recursively ($a,$b)
{
	begin
	{
		$split = (Get-Item -LiteralPath $a).Name
	}
	process
	{
		$arr = $_.DirectoryName -split "($splt)"
		$c = -join $arr[2..$arr.Length]
		$fdst = $b + $c

		if (-not (Test-Path -LiteralPath $fdst))
		{
			New-Item -Path "$fdst" -ItemType Directory -Force
		}
		Move-Item -LiteralPath $_.FullName -Destination $fdst -Force
	}
}

$Source = Get-Item -LiteralPath $Source
$Destination = Get-Item -LiteralPath $Destination

# Moving files saving structure
Get-ChildItem -LiteralPath $Source.FullName -Recurse -File -Force | Move-Recursively $Source.FullName $Destination.FullName

# Removing unnecessary files and folders
Remove-Item -Path "$DownloadsFolder\metro-for-steam.zip", "$DownloadsFolder\UPMetroSkin.zip" -Force
Remove-Item -LiteralPath "$DownloadsFolder\Metro\metro-for-steam-4.4\.gitattributes", "$DownloadsFolder\Metro\metro-for-steam-4.4\.gitignore" -Force
Remove-Item -LiteralPath "$DownloadsFolder\Metro\UPMetroSkin-master" -Recurse -Force

Get-ChildItem -LiteralPath "$DownloadsFolder\Metro\metro-for-steam-4.4" -Recurse -Force | Move-Item -Destination "$DownloadsFolder\Metro" -Force
Remove-Item -LiteralPath "$DownloadsFolder\Metro\metro-for-steam-4.4" -Force

# Custom menu
$Parameters = @{
	Uri = "https://github.com/farag2/Utilities/blob/master/Steam/steam.menu"
	OutFile = "$DownloadsFolder\Metro\resource\menus\steam.menu"
	Verbose = [switch]::Present
}
Invoke-WebRequest @Parameters

if (Test-Path -Path ${env:ProgramFiles(x86)}\Steam)
{
	Move-Item -Path "$DownloadsFolder\Metro" -Destination "${env:ProgramFiles(x86)}\Steam\Skins" -Force
}
else
{
	Write-Warning -Message "No Steam installed"
}
