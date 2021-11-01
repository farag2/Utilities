<#
	.SYNOPSIS
	Expand the specific file from ZIP archive. Folder structure will be created recursively

	.Parameter Source
	The source ZIP archive

	.Parameter Destination
	Where to expand file

	.Parameter File
	Assign the file to expand

	.Example
	ExtractZIPFile -Source "D:\Folder\File.zip" -Destination "D:\Folder" -File "Folder1/Folder2/File.txt"

	.NOTES
	Pay attention to slash in the folders path of archive: "/" Instead of Windows "\"
#>
function ExtractZIPFile
{
	[CmdletBinding()]
	param
	(
		[string]
		$Source,

		[string]
		$Destination,

		[string]
		$File
	)

	Add-Type -Assembly System.IO.Compression.FileSystem

	$ZIP = [IO.Compression.ZipFile]::OpenRead($Source)
	$Entries = $ZIP.Entries | Where-Object -FilterScript {$_.FullName -eq $File}

	$Destination = "$Destination\$(Split-Path -Path $File -Parent)"

	if (-not (Test-Path -Path $Destination))
	{
		New-Item -Path $Destination -ItemType Directory -Force
	}

	$Entries | ForEach-Object -Process {[IO.Compression.ZipFileExtensions]::ExtractToFile($_, "$($Destination)\$($_.Name)", $true)}

	$ZIP.Dispose()
}

$Parameters = @{
	Source      = "D:\Folder\File.zip"
	Destination = "D:\Folder"
	File        = "Folder1/Folder2/File.txt"
}
ExtractZIPFile @Parameters
