[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"

# Main archive
$Parameters = @{
	Uri            = "https://github.com/minischetti/metro-for-steam/archive/v4.4.zip"
	OutFile         = "$DownloadsFolder\metro-for-steam.zip"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-WebRequest @Parameters

# Patch
$Parameters = @{
	Uri             = "https://github.com/redsigma/UPMetroSkin/archive/master.zip"
	OutFile         = "$DownloadsFolder\UPMetroSkin.zip"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-WebRequest @Parameters

<#
	.SYNOPSIS
	Expand the specific folder from ZIP archive. Folder structure will be created recursively

	.Parameter Source
	The source ZIP archive

	.Parameter Destination
	Where to expand folder

	.Parameter Folder
	Assign the folder to expand to

	.Parameter Exclude
	Exclude files from being expanded

	.Example
	ExtractZIPFolder -Source "D:\Folder\File.zip" -Destination "D:\Folder" -Folder "Folder1/Folder2" -Exclude @(".gitignore", ".gitattributes")

	.NOTES
	Pay attention to slash in the folders path of archive: "/" Instead of Windows "\"
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
		$Folder,

		[string[]]
		$Exclude
	)

	Add-Type -Assembly System.IO.Compression.FileSystem

	$ZIP = [IO.Compression.ZipFile]::OpenRead($Source)

	$ZIP.Entries | Where-Object -FilterScript {($_.FullName -like "$($Folder)/*.*") -and ($Exclude -notcontains $_.Name)} | ForEach-Object -Process {
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
	Exclude     = @(".gitignore", ".gitattributes")
}
ExtractZIPFolder @Parameters

<#
	Expanding the archive using IO.Compression.ZipFileExtensions due to it's much faster
	IO.Compression.ZipFileExtensions cannot work with paths that contain excape chars like "[",
	and the same time we have to use $_.FullName -like (-match won't work too, even with escaped \[Install First\]), so the only way out is to place asterix

	So we cannot just expand (thanks the developer for [] in the path) the archive and overwrite all files with new ones from the patch
#>
$Parameters = @{
	Source      = "$DownloadsFolder\UPMetroSkin.zip"
	Destination = "$DownloadsFolder"
	Folder      = "UPMetroSkin-master/Unofficial 4.x Patch/Main Files*" #UPMetroSkin-master/Unofficial 4.x Patch/Main Files [Install First]
}
ExtractZIPFolder @Parameters

<#
	.SYNOPSIS
	Copying files and folders from one folder to another saving folders' structure

	.Parameter Source
	Source folder to copy content from

	.Parameter Destination
	Destination folder to copy content to

	.Parameter Include
	Include files

	.Parameter Exclude
	Exclude files

	.Parameter Delete
	Remove all copied items in the source folder recursively

	.Parameter DeleteEmpty
	Remove empty folders in the source folder recursively

	.Parameter DeleteAll
	Remove the source folder

	.Example
	Move-Recursively -Source "D:\FOLDER1" -Destination "d:\Folder2" -Include '*.pdf', '*.txt' -Exclude '*_out.*' -Delete

	.Link
	https://forum.ru-board.com/topic.cgi?forum=62&topic=30859&start=3600#4
#>
function Move-Recursively
{
	[CmdletBinding()]
	param
	(
		[string]
		$Source,

		[string]
		$Destination,

		[string[]]
		$Include = "*.*",

		[string[]]
		$Exclude = "",

		[switch]
		$Delete,

		[switch]
		$DeleteEmpty,

		[switch]
		$DeleteAll
	)

	# Copying files saving folders' structure
	# -Include & -Exclude work with -LiteralPath only in PowerShell 7
	Get-ChildItem -LiteralPath $Source -Include $Include -Exclude $Exclude -Recurse -Force | Copy-Item -Destination {
		$Folder = Split-Path -Path $_.FullName.Replace($Source, $Destination)

		if (-not (Test-Path -LiteralPath $Folder))
		{
			New-Item -Path $Folder -ItemType Directory -Force
		}
		else
		{
			$Folder
		}
	} -Force

	# Removing all copied items
	if ($Delete)
	{
		Get-ChildItem -LiteralPath $Source -Include $Include -Exclude $Exclude -Recurse -File -Force | Remove-Item -Recurse -Force
	}

	# Removing empty folders
	if ($DeleteEmpty)
	{
		Get-ChildItem -LiteralPath $Source -Recurse -Directory -Force | Sort-Object {$_.FullName.Length} -Descending | ForEach-Object -Process {
			if ($null -eq (Get-ChildItem -LiteralPath $_.FullName -Recurse -Force))
			{
				Remove-Item -LiteralPath $_.FullName -Force
			}
		}
	}

	# Remove the source folder
	if ($DeleteAll)
	{
		Remove-Item -LiteralPath $Source -Recurse -Force
	}
}
$Parameters = @{
	Source      = "$DownloadsFolder\UPMetroSkin-master\Unofficial 4.x Patch\Main Files [Install First]"
	Destination = "$DownloadsFolder\metro-for-steam-4.4"
	DeleteAll   = $true
}
Move-Recursively @Parameters

Remove-Item -Path "$DownloadsFolder\metro-for-steam.zip", "$DownloadsFolder\UPMetroSkin.zip", "$DownloadsFolder\UPMetroSkin-master" -Recurse -Force

Rename-Item -Path "$DownloadsFolder\metro-for-steam-4.4" -NewName "Metro" -Force

# Custom menu
$Parameters = @{
	Uri             = "https://raw.githubusercontent.com/farag2/Utilities/master/Steam/steam.menu"
	OutFile         = "$DownloadsFolder\Metro\resource\menus\steam.menu"
	UseBasicParsing = $true
	Verbose         = $true
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

	Get-Process -Name steam | Stop-Process -Force -ErrorAction Ignore
	Remove-Item -Path "${env:ProgramFiles(x86)}\Steam\Skins\Metro" -Recurse -Force -ErrorAction Ignore
	Copy-Item -Path "$DownloadsFolder\Metro\resource\menus\steam.menu" -Destination "$DownloadsFolder\Metro\resource\menus\steam_original.menu" -Force
	Move-Item -Path "$DownloadsFolder\Metro" -Destination "${env:ProgramFiles(x86)}\Steam\Skins\Metro" -Force
	Invoke-Item -Path "${env:ProgramFiles(x86)}\Steam\Skins\Metro\resource\menus"
}
