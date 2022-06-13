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
