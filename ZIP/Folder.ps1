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
	Exclude files from expanding

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
		$Folder,

		[string[]]
		$Exclude
	)

	Add-Type -Assembly System.IO.Compression.FileSystem

	$ZIP = [IO.Compression.ZipFile]::OpenRead($Source)
	$ZIP.Entries | Where-Object -FilterScript {($_.FullName -like "$($Folder)/*.*")  -and ($Exclude -notcontains $_.Name)} | ForEach-Object -Process {
		$File   = Join-Path -Path $Destination -ChildPath $_.FullName
		$Parent = Split-Path -Path $File -Parent

		if (-not (Test-Path -Path $Parent))
		{
			New-Item -Path $parent -Type Directory -Force
		}

		[IO.Compression.ZipFileExtensions]::ExtractToFile($_, $File, $true)
	}

	$ZIP.Dispose()
}

$Parameters = @{
	Source      = "D:\Folder\File.zip"
	Destination = "D:\Folder"
	Folder      = "Folder1/Folder2"
	Exclude     = @("file1.ext", "file2.ext")
}
ExtractZIPFolder @Parameters
