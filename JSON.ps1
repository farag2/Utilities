# JSON
# List
$JSON = @{}
$basket = @(
	"apples",
	"pears"
)
$JSON | Add-Member -MemberType NoteProperty -Name Data -Value $basket -Force
$JSON | ConvertTo-Json

# Array
$JSON = @{}
$array = @{}
$person = @{
	"Name" = "Matt"
	"Colour" = "Black"
}
$array.Add("Person",$person)
#$array | Add-Member -MemberType NoteProperty -Name Person -Value $person -Force
$JSON | Add-Member -MemberType NoteProperty -Name Data -Value $array -Force
$JSON | ConvertTo-Json -Depth 4

# Combining a list with an array
$JSON = @{}
$basket = @{
	"Basket" = "apples","pears","oranges","strawberries"
}
$JSON | Add-Member -MemberType NoteProperty -Name Data -Value $basket -Force
$JSON | ConvertTo-Json

# A list contains an array
$JSON = @{}
$list = New-Object -TypeName System.Collections.ArrayList
$list.Add(@{
	"Name" = "John"
	"Surname" = "Smith"
	"OnSubscription" = $true
})
$list.Add(@{
	"Name2" = "John"
	"Surname2" = "Smith"
	"OnSubscription2" = $true
})
$customers = @{
	"Customers" = $list
}
$JSON | Add-Member -MemberType NoteProperty -Name Data -Value $customers -Force
$JSON | ConvertTo-Json -Depth 4

# Nested levels
$JSON = @{}
$Lelevs = @{
	Level2 = @{
		Level3 = @{
			Level4 = @{
				P1 = "T1"
			}
		}
	}
}
$JSON | Add-Member -MemberType NoteProperty -Name Level1 -Value $Lelevs
$JSON | ConvertTo-Json -Depth 4
#
$edge = Get-Content -Path "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Preferences" | ConvertFrom-Json
$alternate_urls = @(
	"{google:baseURL}#q={searchTerms}",
	"{google:baseURL}search#q={searchTerms}"
)
$Google = @{
	template_url_data = @{
		"alternate_urls" = $alternate_urls
		"contextual_search_url" = "{google:baseURL}_/contextualsearch?{google:contextualSearchVersion}{google:contextualSearchContextData}"
	}
}
$edge | Add-Member -MemberType NoteProperty -Name default_search_provider_data -Value $Google -Force
ConvertTo-Json -InputObject $edge | Set-Content -Path "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Preferences" -Force

# Add data to JSON. PowerShell 7 only
$JSON = @'
{
	"editor.fontFamily": "'Cascadia Code',Consolas,'Courier New'",
	"editor.tabCompletion": "on"
}
'@
$JHT = ConvertFrom-Json -InputObject $JSON -AsHashtable

$JHT += @{
	"terminal.integrated.shell.windows" = "C:\\Program Files\\PowerShell\\7-preview\\pwsh.exe"
}
$JHT | ConvertTo-Json | Set-Content -Path "$env:APPDATA\Code\User\settings.json"

# Add-Member without "Value" and "Count" elements in JSON
Remove-TypeData -TypeName System.Array

# Check the sequence of Ids
$Ids = (Get-Content -Path "D:\Downloads\1.js" -Encoding UTF8 -Raw | ConvertFrom-Json).Id
$UniqueIds = $Ids | Select-Object -Unique
(Compare-Object -ReferenceObject $UniqueIds -DifferenceObject $Ids).InputObject

# Add new "UA" property to JSON
Remove-TypeData System.Array -ErrorAction Ignore
$Terminal = Get-Content -Path "D:\Downloads\1.js" -Encoding UTF8 -Force | ConvertFrom-Json

$Terminal | ForEach-Object {
	$_.Header | Add-Member -MemberType NoteProperty -Name "UA" -Value "" -Force
}
$Terminal | ForEach-Object {
	$_.Description | Add-Member -MemberType NoteProperty -Name "UA" -Value "" -Force
}
<#
$Terminal | Where-Object -FilterScript {$_.ChildElements.ChildDescription} | ForEach-Object {
	$_.ChildElements.ChildDescription | Add-Member -MemberType NoteProperty -Name "UA" -Value "" -Force
}
#>

ConvertTo-Json -InputObject $Terminal -Depth 4 | Set-Content -Path "D:\Downloads\1.js" -Encoding UTF8 -Force
# Re-save in the UTF-8 without BOM encoding due to JSON must not has the BOM: https://datatracker.ietf.org/doc/html/rfc8259#section-8.1
Set-Content -Value (New-Object -TypeName System.Text.UTF8Encoding -ArgumentList $false).GetBytes($(Get-Content -Path "D:\Downloads\1.js" -Raw)) -Encoding Byte -Path "D:\Downloads\1.js" -Force

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

# Compare 2 JSONs and merge them into one
Remove-TypeData System.Array -ErrorAction Ignore
$Parameters = @{
	Uri             = "https://raw.githubusercontent.com/Sophia-Community/SophiApp/master/SophiApp/SophiApp/Resources/UIData.json"
	UseBasicParsing = $true
}
$Full = Invoke-RestMethod @Parameters

$Parameters = @{
	Uri             = "https://raw.githubusercontent.com/Sophia-Community/SophiApp/master/SophiApp/SophiApp/Resources/UIData_IT.json"
	UseBasicParsing = $true
}
$Italian = Invoke-RestMethod @Parameters

$Full | ForEach-Object -Process {
	$UiData = $_
	$ItData = $Italian | Where-Object -FilterScript {$_.Id -eq $UiData.Id}

	$UiData.Header | Add-Member -Name IT -MemberType NoteProperty -Value $ItData.Header.IT -Force
	$UiData.Description | Add-Member -Name IT -MemberType NoteProperty -Value $ItData.Description.IT -Force
	
	if ($UiData.ChildElements)
	{
		$UiData.ChildElements | ForEach-Object -Process {
			$UiChild = $_
			$ItChild = $ItData.ChildElements | Where-Object -FilterScript {$_.Id -eq $UiChild.Id}

			$UiChild.ChildHeader | Add-Member -Name IT -MemberType NoteProperty -Value $ItChild.ChildHeader.IT -Force
			$UiChild.ChildDescription | Add-Member -Name IT -MemberType NoteProperty -Value $ItChild.ChildDescription.IT -Force
		}
	}
}

ConvertTo-Json -InputObject $Full -Depth 4 | Set-Content -Path "D:\Desktop\3.json" -Encoding UTF8 -Force
# Re-save in the UTF-8 without BOM encoding due to JSON must not has the BOM: https://datatracker.ietf.org/doc/html/rfc8259#section-8.1
Set-Content -Value (New-Object -TypeName System.Text.UTF8Encoding -ArgumentList $false).GetBytes($(Get-Content -Path "D:\Desktop\3.json" -Raw)) -Encoding Byte -Path "D:\Desktop\3.json" -Force
