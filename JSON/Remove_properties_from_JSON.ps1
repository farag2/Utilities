# Remove "RU", "EN", "DE" properties from JSON
Remove-TypeData System.Array -ErrorAction Ignore
$Parameters = @{
	Uri             = "https://raw.githubusercontent.com/Sophia-Community/SophiApp/master/SophiApp/SophiApp/Resources/UIData.json"
	UseBasicParsing = $true
}

$Terminal = Invoke-RestMethod @Parameters
$Terminal | ForEach-Object {	
	$_.Header = $_.Header | Select-Object -Property * -ExcludeProperty RU, EN, DE
	$_.Description = $_.Description | Select-Object -Property * -ExcludeProperty RU, EN, DE
	
	if ($_.ChildElements)
	{
		$_.ChildElements | ForEach-Object {
			$_.ChildHeader = $_.ChildHeader | Select-Object -Property * -ExcludeProperty RU, EN, DE
			$_.ChildDescription = $_.ChildDescription | Select-Object -Property * -ExcludeProperty RU, EN, DE
		
		}
	}
	
	$_
}

$FilteredJson = "D:\Downloads\SophiApp\SophiApp\SophiApp\Resources\UIData_UA.json"
ConvertTo-Json -InputObject $Terminal -Depth 4 | Set-Content -Path $FilteredJson -Encoding UTF8 -Force
# Re-save in the UTF-8 without BOM encoding due to JSON must not has the BOM: https://datatracker.ietf.org/doc/html/rfc8259#section-8.1
Set-Content -Value (New-Object -TypeName System.Text.UTF8Encoding -ArgumentList $false).GetBytes($(Get-Content -Path $FilteredJson -Raw)) -Encoding Byte -Path $FilteredJson -Force
