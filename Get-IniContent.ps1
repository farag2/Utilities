function Get-IniContent
{
	<#
	.Example
		$FileContent = Get-IniContent "C:\myinifile.ini"
		Saves the content of the c:\myinifile.ini in a hashtable called $FileContent

		$inifilepath | $FileContent = Get-IniContent
		Gets the content of the ini file passed through the pipe into a hashtable called $FileContent

		C:\PS>$FileContent = Get-IniContent "c:\settings.ini"
		C:\PS>$FileContent["Section"]["Key"]
		Returns the key "Key" of the section "Section" from the C:\settings.ini file

	.Link
		https://gallery.technet.microsoft.com/scriptcenter/ea40c1ef-c856-434b-b8fb-ebd7a76e8d91
	#>

	[CmdletBinding()]
	param
	(
		[ValidateNotNullOrEmpty()]
		[Parameter(
			ValueFromPipeline = $true,
			Mandatory = $true
		)]
		[string]
		$Path
	)

	$ini = @{}
	switch -Regex -File $Path
	{
		# Section
		"^\[(.+)\]$"
		{
			$section = $matches[1]
			$ini[$section] = @{}
			$CommentCount = 0
		}

		# Comment
		"^(;.*)$"
		{
			if (-not ($section))
			{
				$section = "No-Section"
				$ini[$section] = @{}
			}
			$value = $matches[1]
			$CommentCount = $CommentCount + 1
			$name = "Comment" + $CommentCount
			$ini[$section][$name] = $value
		}

		# Key
		"(.+?)\s*=\s*(.*)"
		{
			if (-not ($section))
			{
				$section = "No-Section"
				$ini[$section] = @{}
			}
			$name, $value = $matches[1..2]
			$ini[$section][$name] = $value
		}
	}
	return $ini
}
