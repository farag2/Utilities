# Compare 2 JSONs and merge them into one
Remove-TypeData System.Array -ErrorAction Ignore

$Parameters = @{
	Uri             = "https://raw.githubusercontent.com/Sophia-Community/SophiApp/master/SophiApp/SophiApp/Resources/UIData.json"
	UseBasicParsing = $true
}
$Full = Invoke-RestMethod @Parameters

$Parameters = @{
	Uri             = "https://raw.githubusercontent.com/Sophia-Community/SophiApp/9c300d4d9ac84a3211f40aa74f2fe6dcb6f5345e/SophiApp/SophiApp/Localizations/UIData_TR.json"
	UseBasicParsing = $true
}
$Translation = Invoke-RestMethod @Parameters

# In this case we add Turkish translation
$ID = "TR"

$Full | ForEach-Object -Process {
	$UiData = $_
	$Data = $Translation | Where-Object -FilterScript {$_.Id -eq $UiData.Id}

	$UiData.Header | Add-Member -Name $ID -MemberType NoteProperty -Value $Data.Header.$ID -Force
	$UiData.Description | Add-Member -Name $ID -MemberType NoteProperty -Value $Data.Description.$ID -Force
	
	if ($UiData.ChildElements)
	{
		$UiData.ChildElements | ForEach-Object -Process {
			$UiChild = $_
			$Child = $Data.ChildElements | Where-Object -FilterScript {$_.Id -eq $UiChild.Id}

			$UiChild.ChildHeader | Add-Member -Name $ID -MemberType NoteProperty -Value $Child.ChildHeader.$ID -Force
			$UiChild.ChildDescription | Add-Member -Name $ID -MemberType NoteProperty -Value $Child.ChildDescription.$ID -Force
		}
	}
}

ConvertTo-Json -InputObject $Full -Depth 4 | Set-Content -Path "D:\3.json" -Encoding UTF8 -Force

# Re-save in the UTF-8 without BOM encoding due to JSON must not has the BOM: https://datatracker.ietf.org/doc/html/rfc8259#section-8.1
Set-Content -Value (New-Object -TypeName System.Text.UTF8Encoding -ArgumentList $false).GetBytes($(Get-Content -Path "D:\3.json" -Raw)) -Encoding Byte -Path "D:\3.json" -Force
