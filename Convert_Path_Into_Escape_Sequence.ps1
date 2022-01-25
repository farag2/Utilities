<#
	.SYNOPSIS
	Convert the whole path into a PowerShell escape sequence

	.PARAMETER Path

	.EXAMPLE
	ConvertPathIntoEscapeSequence -Path "C:\Users\тест\Desktop"

	.LINK
	https://stackoverflow.com/questions/65748858

	.NOTES
	Current user
#>
function ConvertPathIntoEscapeSequence
{
	[CmdletBinding()]
	param
	(
		[string]
		$Path
	)

	function Get-EscapeSequence
	{
		[CmdletBinding()]
		param
		(
			[string]
			$InputObject
		)

		$String = @()

		for
		(
			$i = 0
			$i -lt $InputObject.Length
			++$i
		)
		{
			if ((0 -le [int][char]$InputObject[$i]) -and (0xFFFF -ge [int][char]$InputObject[$i]) -or ((0 -le [int][char]$InputObject[$i]) -and (0x10FFFF -ge [int][char]$InputObject[$i])))
			{
				[string]$String += "\u{0:X4}" -f [int][char]$InputObject[$i]
			}
		}
		$String
	}

	# Skip the drive letter
	$Path.Split("\") | Select-Object -Skip 1 | ForEach-Object -Process {
		if ($_ -notmatch "^[\a-zA-Z0-9\s]+$")
		{
			# Convert into an escape sequence
			$Path = [System.Environment]::ExpandEnvironmentVariables($Path) -replace $_, (Get-EscapeSequence -InputObject $_)
		}
	}

	$Path
}
