# https://ss64.com/ps/syntax-attrib.html

<#
	.EXAMPLE
	Remove the Archive, ReadOnly and Hidden attributes on all files in the C:\logs\ folder:
	./Remove-Attribute -Path "C:\logs\*.*" -Archive -ReadOnly -Hidden
#>
function Remove-attribute
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
		$Hidden = $false,

		[switch]
		$System = $false
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
		if ($Archive.IsPresent -and ((Get-ItemProperty -Path $File.FullName).Attributes -band $ARCHIVE_ATTRIB))
		{
			Set-ItemProperty -Path $File.Fullname -Name Attributes -Value ((Get-ItemProperty $File.FullName).Attributes -bxor $ARCHIVE_ATTRIB)
		}

		if ($ReadOnly.IsPresent -and ((Get-ItemProperty -Path $File.FullName).Attributes -band $READONLY_ATTRIB))
		{
			Set-ItemProperty -Path $File.Fullname -Name Attributes -Value ((Get-ItemProperty $File.FullName).Attributes -bxor $READONLY_ATTRIB)
		}

		if ($Hidden.IsPresent -and ((Get-ItemProperty -Path $File.FullName).Attributes -band $HIDDEN_ATTRIB))
		{
			Set-ItemProperty -Path $File.Fullname -Name Attributes -Value ((Get-ItemProperty $File.FullName).Attributes -bxor $HIDDEN_ATTRIB)
		}
	}
}