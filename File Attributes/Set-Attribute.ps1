# https://ss64.com/ps/syntax-attrib.html

<#
	.EXAMPLE
	Add the ReadOnly and Hidden attributes on the file 'C:\logs\monday.csv'
	./Set-Attribute.ps1 -Path "C:\logs\monday.csv" -ReadOnly -Hidden

	Add the Archive attributes on all the .TXT files in the C:\logs\ folder:
	./Set-Attribute1 -Path "C:\logs\*.txt" -Archive
#>
function Set-attribute
{
	[CmdletBinding()]
	param
	(
		[string]
		$Path,

		[switch]
		$Archive = $false,

		[switch]
		$ReadOnly = $false,

		[switch]
		$Hidden = $false
	)

	$ARCHIVE_ATTRIB = [System.IO.FileAttributes]::Archive
	$READONLY_ATTRIB = [System.IO.FileAttributes]::ReadOnly
	$HIDDEN_ATTRIB = [System.IO.FileAttributes]::Hidden

	$Files = Get-Item -Path $Path -Force
	if ($Files.Count -gt 1)
	{
		$Files = Get-ChildItem -Path $Path -Recurse -Force
	}
	foreach ($File in $Files)
	{
		if ($Archive.IsPresent)
		{
			Set-ItemProperty -Path $File.Fullname -Name Attributes -Value ((Get-ItemProperty $File.FullName).Attributes -bor $ARCHIVE_ATTRIB)
		}

		if ($ReadOnly.IsPresent)
		{
			Set-ItemProperty -Path $File.Fullname -Name Attributes -Value ((Get-ItemProperty $File.FullName).Attributes -bor $READONLY_ATTRIB)
		}

		if ($Hidden.IsPresent)
		{
			Set-ItemProperty -Path $File.Fullname -Name Attributes -Value ((Get-ItemProperty $File.FullName).Attributes -bor $HIDDEN_ATTRIB)
		}
	}
}
