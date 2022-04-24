# Get user's groups
(Get-ADUser -Identity userID -Properties MemberOf).MemberOf

# Copy groups from another user
(Get-ADUser -SearchBase "OU=XX, OU=XX, OU=XX, OU=XX, OU=XX, DC=XX, DC=XX, DC=XX" -Filter * -Properties MemberOf | Where-Object -FilterScript {
	$_.SamAccountName -eq "stefanc"
}).MemberOf | ForEach-Object -Process {Add-ADGroupMember -Identity userID -Members $_}

(Get-ADUser -Identity userID -Properties MemberOf).MemberOf | Add-ADGroupMember -Members iliee

# Copy only missing groups from another user
(Get-ADUser -Identity userID -Properties MemberOf).MemberOf | Where-Object -FilterScript {
	(Get-ADUser -Identity userID -Properties MemberOf).MemberOf -notcontains $_
} | Add-ADGroupMember -Identity userID -Members $_

# Find user in the specific OU who is the following groups
Get-ADUser -SearchBase "OU=XX, OU=XX, OU=XX, OU=XX, OU=XX, DC=XX, DC=XX, DC=XX" -Properties MemberOf -Filter * | Where-Object -FilterScript {($_.MemberOf -match "Region_2_RW") -and ($_.MemberOf -match "Regions_RW")}

# Create a table with username and email and export into .csv
Get-ADUser -SearchBase "OU=XX, OU=XX, OU=XX, OU=XX, OU=XX, DC=XX, DC=XX, DC=XX" -Properties MemberOf -Filter * | Where-Object -FilterScript {
	$_.Enabled -eq $true
} | Select-Object -Property SamAccountName, UserPrincipalName | Export-Csv -Path "C:\1.csv" -NoTypeInformation -Delimiter ';' -Append

# Find users who are in the specific room
(Get-ADUser -SearchBase "OU=XX, OU=XX, OU=XX, OU=XX, OU=XX, DC=XX, DC=XX, DC=XX" -Filter * -Properties l | Where-Object -FilterScript {$_.l -match "Office"}).SamAccountName

# Find users by position
(Get-ADUser -SearchBase "OU=XX, OU=XX, OU=XX, OU=XX, OU=XX, DC=XX, DC=XX, DC=XX" -Filter * -Properties * | Where-Object -FilterScript {$_.Title -like "*city*"}).SamAccountName

# Create a table with physicalDeliveryOfficeName & userID columns, and move user to the proper physicalDeliveryOfficeName
Write-Verbose -Message Office1 -Verbose
Get-ADUser -SearchBase "OU=XX, OU=XX, OU=XX, OU=XX, OU=XX, DC=XX, DC=XX, DC=XX" -Filter * -Properties physicalDeliveryOfficeName | Where-Object -FilterScript {($_.Enabled) -and ($_.physicalDeliveryOfficeName -ne "Office2")} | ForEach-Object -Process {
	[PSCustomObject] @{
		Name   = $_.Name
		userID = (Get-ADUser -Identity $_).SamAccountName
	}

	Write-Verbose -Message "Changing $_" -Verbose
	Get-ADUser -Identity $_.SamAccountName | ForEach-Object -Process {
		Set-ADUser -Identity $_ -Replace @{physicalDeliveryOfficeName = "Office3"}
	}
}

Write-Verbose -Message "Office4" -Verbose
Get-ADUser -SearchBase "OU=XX, OU=XX, OU=XX, OU=XX, OU=XX, DC=XX, DC=XX, DC=XX" -Filter * -Properties physicalDeliveryOfficeName | Where-Object -FilterScript {($_.Enabled) -and ($_.physicalDeliveryOfficeName -ne "Office4")} | ForEach-Object -Process {
	[PSCustomObject] @{
		Name     = $_.Name
		userID   = (Get-ADUser -Identity $_).SamAccountName
	}

	Write-Verbose -Message "Changing $_" -Verbose
	Get-ADUser -Identity $_.SamAccountName | ForEach-Object -Process {
		Set-ADUser -Identity $_ -Replace @{physicalDeliveryOfficeName = "Office4"}
	}
}

# Move all users from one OU to another one
Get-ADUser -SearchBase "OU=XX, OU=XX, OU=XX, OU=XX, OU=XX, DC=XX, DC=XX, DC=XX" -Filter * -Properties * | Move-ADObject -TargetPath "OU=XX, OU=XX, OU=XX, OU=XX, OU=XX, DC=XX, DC=XX, DC=XX"

# Remove OU (if it is a protected one)
Get-ADOrganizationalUnit -Identity "OU=XX, OU=XX, OU=XX, OU=XX, OU=XX, DC=XX, DC=XX, DC=XX" | Set-ADObject -ProtectedFromAccidentalDeletion:$false -PassThru | Remove-ADOrganizationalUnit -Confirm:$false

# Create table with userID and user name
$emails = @(
	"email"
)
foreach ($email in $emails)
{
	Get-ADUser -SearchBase "OU=XX, OU=XX, OU=XX, OU=XX, OU=XX, DC=XX, DC=XX, DC=XX" -Filter * | Where-Object -FilterScript {($_.Enabled) -and ($_.UserPrincipalName -eq $email)} | ForEach-Object -Process {
		[PSCustomObject]@{
			Name  = $_.SamAccountName
			Email = $_.UserPrincipalName
		}
	}
}

# Assign a user to a group from another domain
$ADGroup = Get-ADGroup -Identity global_group -Server global_server
$userID = Get-ADUser -Identity userID -Server eur_server
Add-ADGroupMember -Identity $ADGroup -Members $userID -Server global_server

# Install ExchangeOnlineManagement
Install-Module -Name ExchangeOnlineManagement -Force
Connect-ExchangeOnline
Get-DistributionGroupMember -Identity "*city*"
(Get-UnifiedGroupLinks -Identity "City" -LinkType Members).WindowsLiveID

# Check when user's password expires
Get-ADUser -Identity userID –Properties DisplayName, msDS-UserPasswordExpiryTimeComputed | Select-Object -Property Displayname, @{
	Name       = "Expiration date"
	Expression = {[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}
}

# Automatically install or uninstall required software and restart the computer only outside of the specified business hours
Invoke-WmiMethod -Namespace Root\ccm\ClientSDK -Class CCM_ClientUXSettings -Name SetAutoInstallRequiredSoftwaretoNonBusinessHours -ArgumentList @($TRUE)

# Open C drive on a remote machine
\\pcname\c$
