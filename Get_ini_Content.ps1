<#
    	.Synopsis
        Gets the content of an INI file

	.Example
	$FileContent = Get-IniContent "C:\myinifile.ini"
	Saves the content of the c:\myinifile.ini in a hashtable called $FileContent

	$FileContent = Get-IniContent -Path "c:\settings.ini"
	$FileContent["Section"]["Key"]
	Returns the key "Key" of the section "Section" from the C:\settings.ini file

	.Link
	https://github.com/lipkau/PsIni
#>
function Get-IniContent
{
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
