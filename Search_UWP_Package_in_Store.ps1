<#
	.SYNOPSIS
	Search in Microsoft Store from PowerShell 

	.PARAMETER Query

	.EXAMPLE
	Search-MSStore -Query "terminal"

	.NOTES
	https://github.com/ThomasPe/MS-Store-API
#>
function Search-MSStore
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]
		$Query
	)

	$Keys = [PSCustomObject]@{
		appVersion   = "22203.1401.0.0"
		market       = "US"
		locale       = "en-US"
		deviceFamily = "windows.desktop"
		query        = "calculator"
	}

	[string]$Keys = (-join ($Keys.psobject.Properties.Name | ForEach-Object -Process {$_ + "=" + $Keys.$_ + "&"})).TrimEnd("&")

	$Parameters = @{
		Uri             = "https://storeedgefd.dsx.mp.microsoft.com/v9.0/pages/searchResults?$($Keys)"
		UseBasicParsing = $true
		Verbose         = $true
	}
	Invoke-RestMethod @Parameters
}
Search-MSStore -Query "terminal"
