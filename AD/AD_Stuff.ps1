# Get the current user OU
$DistinguishedName = @{
	Name       = "OU"
	Expression = {($_.DistinguishedName.Split(",") | Select-Object -Index 1).Split("=") | Select-Object -Index 1}
}
(Get-ADUser -Identity $env:USERNAME -Properties * | Select-Object -Property $DistinguishedName).OU
$CurrentUser = (Get-Process -IncludeUserName | Where-Object -FilterScript {$_.ProcessName -eq "explorer"}).UserName.Split("\") | Select-Object -Index 1
((Get-ADUser -Identity $CurrentUser).DistinguishedName.Split(",") | Select-Object -Index 1).Split("=") | Select-Object -Index 1

# Get user's groups
(Get-ADUser -Identity userID -Properties MemberOf).MemberOf

# Copy groups from another user
(Get-ADUser -SearchBase "OU=XX, OU=XX, OU=XX, OU=XX, OU=XX, DC=XX, DC=XX, DC=XX" -Filter * -Properties MemberOf | Where-Object -FilterScript {
	$_.SamAccountName -eq "userID1"
}).MemberOf | ForEach-Object -Process {Add-ADGroupMember -Identity userID2 -Members $_}

(Get-ADUser -Identity userID1 -Properties MemberOf).MemberOf | Add-ADGroupMember -Members userID2

# Copy only missing groups from another user
(Get-ADUser -Identity userID1 -Properties MemberOf).MemberOf | Where-Object -FilterScript {
	(Get-ADUser -Identity PrimaryuserID -Properties MemberOf).MemberOf -notcontains $_
} | Add-ADGroupMember -Identity userID1 -Members $_

# Find user in the specific OU who is the following groups
Get-ADUser -SearchBase "OU=XX, OU=XX, OU=XX, OU=XX, OU=XX, DC=XX, DC=XX, DC=XX" -Properties MemberOf -Filter * | Where-Object -FilterScript {($_.MemberOf -match "groupname1") -and ($_.MemberOf -match "groupname2")}

# Create a table with username and email and export into .csv
Get-ADUser -SearchBase "OU=XX, OU=XX, OU=XX, OU=XX, OU=XX, DC=XX, DC=XX, DC=XX" -Properties MemberOf -Filter * | Where-Object -FilterScript {
	$_.Enabled -eq $true
} | Select-Object -Property SamAccountName, UserPrincipalName | Export-Csv -Path "C:\1.csv" -NoTypeInformation -Delimiter ';' -Append

# Find users who are in the specific room
(Get-ADUser -SearchBase "OU=XX, OU=XX, OU=XX, OU=XX, OU=XX, DC=XX, DC=XX, DC=XX" -Filter * -Properties l | Where-Object -FilterScript {$_.l -match "Moscow"}).SamAccountName

# Find users by position
(Get-ADUser -SearchBase "OU=XX, OU=XX, OU=XX, OU=XX, OU=XX, DC=XX, DC=XX, DC=XX" -Filter * -Properties * | Where-Object -FilterScript {$_.Title -like "*volgograd*"}).SamAccountName

# Change the physicalDeliveryOfficeName property
Get-ADUser -SearchBase "OU=XX, OU=XX, OU=XX, OU=XX, OU=XX, DC=XX, DC=XX, DC=XX" -Filter * -Properties physicalDeliveryOfficeName | Where-Object -FilterScript {($_.Enabled) -and ($_.physicalDeliveryOfficeName -ne "XX")} | ForEach-Object -Process {
	[PSCustomObject] @{
		Name	 = $_.Name
		userID   = (Get-ADUser -Identity $_).SamAccountName
	}

	Write-Verbose -Message "Changing $_" -Verbose
	Get-ADUser -Identity $_.SamAccountName | ForEach-Object -Process {
		Set-ADUser -Identity $_ -Replace @{physicalDeliveryOfficeName = "XXX"}
	}
}

# Install ExchangeOnlineManagement
Install-Module -Name ExchangeOnlineManagement -Force
Connect-ExchangeOnline
Get-DistributionGroupMember -Identity "*dentity*"
(Get-UnifiedGroupLinks -Identity "group" -LinkType Members).WindowsLiveID
