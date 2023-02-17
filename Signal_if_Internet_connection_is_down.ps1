# Signal if Internet connection is down (or vice-versa if needed)
while ($true)
{
	try
	{
		$Parameters = @{
			Uri              = "https://www.google.com"
			Method           = "Head"
			DisableKeepAlive = $true
			UseBasicParsing  = $true
		}
		if ((Invoke-WebRequest @Parameters).StatusDescription)
		{
			Write-Warning -Message "Internet connection is up" -Verbose
		}
	}
	catch [System.Net.WebException]
	{
    # Play beep
		[console]::beep(500,300)
	}
}
