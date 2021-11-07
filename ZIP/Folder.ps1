<#
	.SYNOPSIS
	Expand the specific folder from ZIP archive. Folder structure will be created recursively

	.Parameter Source
	The source ZIP archive

	.Parameter Destination
	Where to expand folder

	.Parameter Folder
	Assign the folder to expand to

	.Parameter ExcludedFiles
	Exclude files from expanding

	.Parameter ExcludedFolders
	Exclude folders from expanding

	.Example
	ExtractZIPFolder -Source "D:\Folder\File.zip" -Destination "D:\Folder" -Folder "Folder1/Folder2" -ExcludedFiles @("file1.ext", "file2.ext") -ExcludedFolders "Folder"

	.NOTES
	Pay attention to slash in the folders path of archive: "/" instead of Windows "\"
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
		$ExcludedFiles,

		[string[]]
		$ExcludedFolders
	)

	Add-Type -Assembly System.IO.Compression.FileSystem

	$ZIP = [IO.Compression.ZipFile]::OpenRead($Source)
	$ZIP.Entries | Where-Object -FilterScript {($_.FullName -like "$($Folder)/*.*") -and ($ExcludedFiles -notcontains $_.Name) -and ($_.FullName -notmatch $ExcludedFolders)} | ForEach-Object -Process {
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
