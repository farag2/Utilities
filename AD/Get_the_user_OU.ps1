$DistinguishedName = @{
	Name       = "OU"
	Expression = {($_.DistinguishedName.Split(",") | Select-Object -Index 1).Split("=") | Select-Object -Index 1}
}
(Get-ADUser $env:USERNAME | Select-Object -Property $DistinguishedName).OU

$CurrentUser = (Get-Process -IncludeUserName | Where-Object -FilterScript {$_.ProcessName -eq "explorer"}).UserName.Split("\") | Select-Object -Index 1
((Get-ADUser -Identity $CurrentUser).DistinguishedName.Split(",") | Select-Object -Index 1).Split("=") | Select-Object -Index 1
