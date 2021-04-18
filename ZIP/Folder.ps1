<#
	.SYNOPSIS
	Expand the specific folder from ZIP archive. Folder structure will be created recursively

	.Parameter Source
	The source ZIP archive

	.Parameter Destination
	Where to expand folder

	.Parameter File
	Assign the folder to expand

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

	$ZIP = [IO.Compression.ZipFile]::OpenRead($Source).Entries
	$ZIP | Where-Object -FilterScript {$_.FullName -like "$($Folder)/*.*"} | ForEach-Object -Process {
		$File   = Join-Path -Path $Destination -ChildPath $_.FullName
		$Parent = Split-Path -Path $File -Parent

		if (-not (Test-Path -Path $Parent))
		{
			New-Item -Path $parent -Type Directory -Force
		}

		[IO.Compression.ZipFileExtensions]::ExtractToFile($_, $File, $true)
	}
}

$Parameters = @{
	Source      = "D:\Folder\File.zip"
	Destination = "D:\Folder"
	Folder      = "Folder1/Folder2"
}
ExtractZIPFolder @Parameters
