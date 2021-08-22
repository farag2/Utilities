<#
	.SYNOPSIS
	Install Chrome Extensions using the registry policy

	.PARAMETER ExtensionID
	String value of an extension ID taken from the Chrome Web Store URL for the extension

	.EXAMPLE Install uBlock Origin
	New-ChromeExtension -ExtensionID @("cjpalhdlnbpafiamejdnhcphjbkeiagm") -Hive HKLM -Verbose

	.NOTES
	if you remove the HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist key all extensions will be uninstalled

	.LINK
	https://chromeenterprise.google/policies/#ExtensionInstallForcelist
#>
function New-ChromeExtension
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[string[]]
		$ExtensionIDs,

		[Parameter(Mandatory = $true)]
		[ValidateSet("HKLM", "HKCU")]
		[string]
		$Hive
	)

	foreach ($ExtensionID in $ExtensionIDs)
	{
		switch ($Hive)
		{
			"HKLM"
			{
				if (-not (Test-Path -Path HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist))
				{
					New-Item -Path HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist -Force
					[int]$Count = 0
				}
				else
				{
					[int]$Count = (Get-Item -Path HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist).Count
				}
			}
			"HKCU"
			{
				if (-not (Test-Path -Path HKCU:\Software\Policies\Google\Chrome\ExtensionInstallForcelist))
				{
					New-Item -Path HKCU:\Software\Policies\Google\Chrome\ExtensionInstallForcelist -Force
					[int]$Count = 0
				}
				else
				{
					[int]$Count = (Get-Item -Path HKCU:\Software\Policies\Google\Chrome\ExtensionInstallForcelist).Count
				}
			}
		}

		$Name = $Count + 1

		switch ($Hive)
		{
			"HKLM"
			{
				New-ItemProperty -Path HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist -Name $Name -PropertyType String -Value "$ExtensionID;https://clients2.google.com/service/update2/crx" -Force
			}
			"HKCU"
			{
				New-ItemProperty -Path HKCU:\Software\Policies\Google\Chrome\ExtensionInstallForcelist -Name $Name -PropertyType String -Value "$ExtensionID;https://clients2.google.com/service/update2/crx" -Force
			}
		}
	}
}
New-ChromeExtension -ExtensionID @("cjpalhdlnbpafiamejdnhcphjbkeiagm") -Hive HKLM -Verbose
