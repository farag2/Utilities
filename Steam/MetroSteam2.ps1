[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"

# Main archive
$Parameters = @{
	Uri = "https://github.com/minischetti/metro-for-steam/archive/v4.4.zip"
	OutFile = "$DownloadsFolder\metro-for-steam.zip"
	Verbose = [switch]::Present
}
Invoke-WebRequest @Parameters

# Patch
$Parameters = @{
	Uri = "https://github.com/redsigma/UPMetroSkin/archive/master.zip"
	OutFile = "$DownloadsFolder\UPMetroSkin.zip"
	Verbose = [switch]::Present
}
Invoke-WebRequest @Parameters

<#
	.SYNOPSIS
	Expand the specific folder from ZIP archive. Folder structure will be created recursively

	.Parameter Source
	The source ZIP archive

	.Parameter Destination
	Where to expand folder

	.Parameter File
	Assign the folder to expand to

	.Example
	ExtractZIPFolder -Source "D:\Folder\File.zip" -Destination "D:\Folder" -File "Folder1/Folder2"
#>
function ExtractZIPFolder
{
	[CmdletBinding()]
	param
	(
		[string]
		$Source,

		[string]
		$Destination,

		[string]
		$Folder
	)

	Add-Type -Assembly System.IO.Compression.FileSystem

	$ZIP = [IO.Compression.ZipFile]::OpenRead("D:\Downloads\metro-for-steam.zip")
	$ZIP.Entries | Where-Object -FilterScript {$_.FullName -like "$($Folder)/*.*"} | ForEach-Object -Process {
		$File   = Join-Path -Path $Destination -ChildPath $_.FullName
		$Parent = Split-Path -Path $File -Parent

		if (-not (Test-Path -Path $Parent))
		{
			New-Item -Path $Parent -Type Directory -Force
		}

		[IO.Compression.ZipFileExtensions]::ExtractToFile($_, $File, $true)
	}

	$ZIP.Dispose()
}

$Parameters = @{
	Source      = "$DownloadsFolder\metro-for-steam.zip"
	Destination = "$DownloadsFolder"
	Folder      = "metro-for-steam-4.4"
}
ExtractZIPFolder @Parameters

$Parameters = @{
	Source      = "$DownloadsFolder\UPMetroSkin.zip"
	Destination = "$DownloadsFolder"
	Folder      = "UPMetroSkin-master\Unofficial 4.x Patch\Main Files [Install First]"
}
ExtractZIPFolder @Parameters

Remove-Item -Path "$DownloadsFolder\metro-for-steam.zip", "$DownloadsFolder\UPMetroSkin.zip" -Force
Remove-Item -LiteralPath "$DownloadsFolder\metro-for-steam-4.4\.gitattributes", "$DownloadsFolder\metro-for-steam-4.4\.gitignore" -Force

Rename-Item -Path "$DownloadsFolder\metro-for-steam-4.4" -NewName "Metro"

# Custom menu
$Parameters = @{
	Uri = "https://github.com/farag2/Utilities/blob/master/Steam/steam.menu"
	OutFile = "$DownloadsFolder\Metro\resource\menus\steam.menu"
	Verbose = [switch]::Present
}
Invoke-WebRequest @Parameters

if (Test-Path -Path "${env:ProgramFiles(x86)}\Steam")
{
	if (-not (Test-Path -Path "${env:ProgramFiles(x86)}\Steam\Skins"))
	{
		New-Item -Path "${env:ProgramFiles(x86)}\Steam\Skins" -ItemType Directory -Force
	}

	if (Test-Path -Path "${env:ProgramFiles(x86)}\Steam\Skins\Metro")
	{
		Remove-Item -Path "${env:ProgramFiles(x86)}\Steam\Skins\Metro" -Recurse -Force
	}

	Move-Item -Path "$DownloadsFolder\Metro" -Destination "${env:ProgramFiles(x86)}\Steam\Skins\Metro" -Force
}
