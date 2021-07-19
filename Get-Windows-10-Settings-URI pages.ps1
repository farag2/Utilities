# Hidden URIs
# https://docs.microsoft.com/en-us/windows/uwp/launch-resume/launch-settings-app
[xml]$xml = Get-Content -Path "$env:SystemRoot\ImmersiveControlPanel\Settings\AllSystemSettings_{253E530E-387D-4BC2-959D-E6F86122E5F2}.xml"

$String = "Defender"
$Items = $xml.PCSettings.SearchableContent | Where-Object -FilterScript {$_.FileName -match $String} | Where-Object -FilterScript {$_.ApplicationInformation.DeepLink}

foreach ($Item in $Items)
{
	[PSCustomObject]@{
		FileName = $Item.FileName
		DeepLink = $Item.ApplicationInformation.DeepLink
	}
}
# windowsdefender://CoreIsolation
