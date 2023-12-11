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
