# Split SophiApp translations into separate files
Remove-TypeData System.Array -ErrorAction Ignore
$Parameters = @{
	Uri             = "https://raw.githubusercontent.com/Sophia-Community/SophiApp/master/SophiApp/SophiApp/Resources/UIData.json"
	UseBasicParsing = $true
}

$Tags = @("EN", "RU", "DE", "UA", "IT", "TR")
foreach ($Tag in $Tags)
{
	$Terminal = Invoke-RestMethod @Parameters
	$Terminal | ForEach-Object {	
		$_.Header = $_.Header | Select-Object -Property * -ExcludeProperty @($Tags | Where-Object -FilterScript {$_ -ne $Tag})
		$_.Description = $_.Description | Select-Object -Property * -ExcludeProperty @($Tags | Where-Object -FilterScript {$_ -ne $Tag})

		if ($_.ChildElements)
		{
			$_.ChildElements | ForEach-Object {
				$_.ChildHeader = $_.ChildHeader | Select-Object -Property * -ExcludeProperty @($Tags | Where-Object -FilterScript {$_ -ne $Tag})
				$_.ChildDescription = $_.ChildDescription | Select-Object -Property * -ExcludeProperty @($Tags | Where-Object -FilterScript {$_ -ne $Tag})
			}
		}

		$_
	}

	$FilteredJSON = "D:\UIData_$Tag.json"
    # Fix escaped single quotes
	ConvertTo-Json -InputObject $Terminal -Depth 4 | ForEach-Object -Process {$_.Replace("\u0027", "'")} | Set-Content -Path $FilteredJSON -Encoding UTF8 -Force

	# Re-save in the UTF-8 without BOM encoding due to JSON must not has the BOM: https://datatracker.ietf.org/doc/html/rfc8259#section-8.1
	Set-Content -Value (New-Object -TypeName System.Text.UTF8Encoding -ArgumentList $false).GetBytes($(Get-Content -Path $FilteredJSON -Raw)) -Encoding Byte -Path $FilteredJSON -Force
}
