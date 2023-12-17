<#
	.SYNOPSIS
	Get file attribute

	.Parameter Path

	.Example
	Get-attribute -Path C:\demo\*.txt

	.LINK
	https://ss64.com/ps/syntax-attrib.html
#>
function Get-attribute
{
	[CmdletBinding()]
	param
	(
		[string]
		$Path
	)

	$ARCHIVE_ATTRIB = [System.IO.FileAttributes]::Archive
	$READONLY_ATTRIB = [System.IO.FileAttributes]::ReadOnly
	$HIDDEN_ATTRIB = [System.IO.FileAttributes]::Hidden
	$SYSTEM_ATTRIB = [System.IO.FileAttributes]::System

	$Files = Get-Item -Path $Path -Force

	if ($Files.Count -gt 1)
	{
		$Files = Get-ChildItem -Path $Path -Recurse -Force
	}

	foreach ($File in $Files)
	{
		$Attributes = ""

		if (((Get-ItemProperty -Path $File.FullName).Attributes -band $ARCHIVE_ATTRIB) -eq $ARCHIVE_ATTRIB)
		{
			$Attributes = "| Archive"
		}

		if (((Get-ItemProperty -Path $File.FullName).Attributes -band $READONLY_ATTRIB) -eq 1)
		{
			$Attributes = "$Attributes | Read-only"
		}

		if (((Get-ItemProperty -Path $File.FullName).Attributes -band $HIDDEN_ATTRIB) -eq 2)
		{
			$Attributes = "$Attributes | Hidden"
		}

		if (((Get-ItemProperty -Path $File.FullName).Attributes -band $SYSTEM_ATTRIB) -eq 4)
		{
			$Attributes = "$Attributes | System"
		}

		if ($Attributes -eq "")
		{
			$Attributes = "| Normal"
		}

		"$File $Attributes"
	}
}
