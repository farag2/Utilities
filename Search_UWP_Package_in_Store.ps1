#Requires -Version 7.1

<#
	.SYNOPSIS
	Search Microsoft Store from PowerShell 

	.PARAMETER Query

	.EXAMPLE
	Search-MSStore -Query "terminal"

	.NOTES
	Originally coded by antidisestablishmentarianism
	https://dev.to/antidisestablishmentarianism/search-microsoft-store-from-powershell-2bjj
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

	$Base = "https://storeedgefd.dsx.mp.microsoft.com/v8.0/search?"

	$Parameters = [PSCustomObject]@{
		market = (Get-UICulture).Parent.Name
		locale = $PSCulture
		catalogLocales = $PSCulture
		query = $Query
		mediaType = "apps"
		category = "all"
		moId = "Public"
		oemId = "LENOVO"
		scmId = "Lenovo3_Idea"
		deviceFamily = "windows.desktop"
		appVersion = "12006.1001.0.0"
		availableOn = "windows.desktop"
		maturityRating = "all"
		cardsEnabled = "true"
		pzn = "0"
		pageSize = "25"
		skipItems = "0"
	}

	[string]$Parameters = (-join ($Parameters.psobject.Properties.Name | ForEach-Object -Process {$_ + "=" + $Parameters.$_ + "&"})).TrimEnd("&")

	$URL = @{
		Name = "URL"
		Expression = {"https://www.microsoft.com/store/productId/" + $_.ProductId}
	}
	((Invoke-WebRequest -UseBasicParsing -Uri ($Base + $Parameters)).Content | ConvertFrom-Json).Payload.Cards | Select-Object -Property Title, Price, ProductId, $URL
}

###
# Another version without [PSCustomObject]
###

#Requires -Version 7.1

<#
	.SYNOPSIS
	Search Microsoft Store from PowerShell 

	.PARAMETER Query

	.EXAMPLE
	Search-MSStore -Query "terminal"

	.NOTES
	Originally coded by antidisestablishmentarianism
	https://dev.to/antidisestablishmentarianism/search-microsoft-store-from-powershell-2bjj
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

	$Base = "https://storeedgefd.dsx.mp.microsoft.com/v8.0/search?"

	$Parameters = @{
		market = (Get-UICulture).Parent.Name
		locale = $PSCulture
		catalogLocales = $PSCulture
		query = $Query
		mediaType = "apps"
		category = "all"
		moId = "Public"
		oemId = "LENOVO"
		scmId = "Lenovo3_Idea"
		deviceFamily = "windows.desktop"
		appVersion = "12006.1001.0.0"
		availableOn = "windows.desktop"
		maturityRating = "all"
		cardsEnabled = "true"
		pzn = "0"
		pageSize = "25"
		skipItems = "0"
	}

	[string]$Parameters = (-join ($Parameters.Keys | ForEach-Object -Process {$_ + "=" + $Parameters.$_ + "&"})).TrimEnd("&")

	$URL = @{
		Name = "URL"
		Expression = {"https://www.microsoft.com/store/productId/" + $_.ProductId}
	}
	((Invoke-WebRequest -UseBasicParsing -Uri ($Base + $Parameters)).Content | ConvertFrom-Json -AsHashtable).Payload.Cards | Select-Object -Property Title, Price, ProductId, $URL
}
