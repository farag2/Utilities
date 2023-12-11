# Get user's groups
(Get-ADUser -Identity panteav -Properties MemberOf).MemberOf

# Copy groups from another user
(Get-ADUser -SearchBase "OU=Internal,OU=Users,OU=MOS,OU=RU,OU=Corp,DC=fr,DC=,DC=lcl" -Filter * -Properties MemberOf | Where-Object -FilterScript {
	$_.SamAccountName -eq "stefanc"
}).MemberOf | ForEach-Object -Process {Add-ADGroupMember -Identity mortana -Members $_}

(Get-ADUser -Identity stefanc -Properties MemberOf).MemberOf | Add-ADGroupMember -Members iliee

# Copy only missing groups from another user
(Get-ADUser -Identity nigmate -Properties MemberOf).MemberOf | Where-Object -FilterScript {
	(Get-ADUser -Identity PE151218 -Properties MemberOf).MemberOf -notcontains $_
} | Add-ADGroupMember -Members PE151218

# Find user in the specific OU who is the following groups
Get-ADUser -SearchBase "OU=Internal,OU=Users,OU=MOS,OU=RU,OU=Corp,DC=fr,DC=,DC=lcl" -Properties MemberOf -Filter * | Where-Object -FilterScript {($_.MemberOf -match "Region_2_RW") -and ($_.MemberOf -match "Regions_RW")}

# Create a table with username and email and export into .csv
Get-ADUser -SearchBase "OU=Internal,OU=Users,OU=MOS,OU=RU,OU=Corp,DC=fr,DC=,DC=lcl" -Properties MemberOf -Filter * | Where-Object -FilterScript {
	$_.Enabled -eq $true
} | Select-Object -Property SamAccountName, UserPrincipalName | Export-Csv -Path "C:\1.csv" -NoTypeInformation -Delimiter ';' -Append

# Find users who are in the specific room
(Get-ADUser -SearchBase "OU=Internal,OU=Users,OU=MOS,OU=RU,OU=Corp,DC=fr,DC=,DC=lcl" -Filter * -Properties l | Where-Object -FilterScript {$_.l -match "Moscow"}).SamAccountName

# Find users by position
(Get-ADUser -SearchBase "OU=Internal,OU=Users,OU=MOS,OU=RU,OU=Corp,DC=fr,DC=,DC=lcl" -Filter * -Properties * | Where-Object -FilterScript {$_.Title -like "*volgograd*"}).SamAccountName

# Create a table with physicalDeliveryOfficeName & userID columns, and move user to the proper physicalDeliveryOfficeName
Get-ADUser -SearchBase "OU=Internal,OU=Users,OU=MOS,OU=RU,OU=Corp,DC=fr,DC=,DC=lcl" -Filter * -Properties physicalDeliveryOfficeName | Where-Object -FilterScript {($_.Enabled) -and ($_.physicalDeliveryOfficeName -ne "RU Moscow")} | ForEach-Object -Process {
	[PSCustomObject] @{
		Name   = $_.Name
		userID = (Get-ADUser -Identity $_).SamAccountName
	}

	Get-ADUser -Identity $_.SamAccountName | ForEach-Object -Process {
		Set-ADUser -Identity $_ -Replace @{physicalDeliveryOfficeName = "RU Moscow"}
	}
}

# Move all users from one OU to another one
Get-ADUser -SearchBase "OU=Internal,OU=Users,OU=MOS,OU=RU,OU=Corp,DC=fr,DC=,DC=lcl" -Filter * -Properties * | Move-ADObject -TargetPath "OU=Supply Chain, OU=MOS, OU=RU, OU=EMEA, OU=USR, OU=CORP, DC=eur, DC=, DC=com"

# Remove OU (if it is a protected one)
Get-ADOrganizationalUnit -Identity "OU=Internal,OU=Users,OU=MOS,OU=RU,OU=Corp,DC=fr,DC=,DC=lcl" | Set-ADObject -ProtectedFromAccidentalDeletion:$false -PassThru | Remove-ADOrganizationalUnit -Confirm:$false

# Create table with userID and user name
$emails = @("userID@ru.domain.com")
foreach ($email in $emails)
{
	Get-ADUser -SearchBase "OU=Internal,OU=Users,OU=MOS,OU=RU,OU=Corp,DC=fr,DC=,DC=lcl" -Filter * | Where-Object -FilterScript {($_.Enabled) -and ($_.UserPrincipalName -eq $email)} | ForEach-Object -Process {
		[PSCustomObject]@{
			Name  = $_.SamAccountName
			Email = $_.UserPrincipalName
		}
	}
}

# Assign a user to a group from another domain
$ADGroup = Get-ADGroup -Identity M_GBL_ALL_Employees -Server domain.com
$userID = Get-ADUser -Identity PAUNF -Server eur.domain.com
Add-ADGroupMember -Identity $ADGroup -Members $userID -Server domain.com

# Assign user to a group
Get-ADUser -Identity $UserID | ForEach-Object -Process {
	Add-ADGroupMember -Identity E_EMEA_APP_M365_E5 -Members $_ -Confirm:$false
	Remove-ADGroupMember -Identity E_EMEA_APP_M365_F3_F5Security -Members $_ -Confirm:$false
}

# Install ExchangeOnlineManagement
Install-Module -Name ExchangeOnlineManagement -Force
Connect-ExchangeOnline
Get-DistributionGroupMember -Identity "*moscow*"
(Get-UnifiedGroupLinks -Identity "MCCK_Russia_Moscow" -LinkType Members).WindowsLiveID

# Check when user's passwor expires
Get-ADUser -Identity nefedod –Properties DisplayName, msDS-UserPasswordExpiryTimeComputed | Select-Object -Property Displayname, @{
	Name       = "Expiration date"
	Expression = {[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}
}

# Open C drive on a remote PC
\\$env:COMPUTERNAME\c$

# Asign every PC in the OU to the group
Get-ADComputer -SearchBase "OU=Laptop, OU=MOS, OU=RU, OU=EMEA, OU=CMP, OU=CORP, DC=eur, DC=, DC=com" -Filter * -Properties MemberOf | Where-Object -FilterScript {[string]$_.MemberOf -notmatch "E_EMEA_SCCM_RU_CTX_4_9"} | ForEach-Object -Process {
	Add-ADGroupMember -Members (Get-ADComputer -Identity $_.Name) -Identity E_EMEA_SCCM_RU_CTX_4_9
}

# Remove PC from group
Remove-ADGroupMember -Members (Get-ADComputer -Identity MOSL001718) -Identity E_EMEA_SCCM_RU_CTX_4_9 -Confirm:$false
Get-ADComputer -Identity 7K44273 | ForEach-Object -Process {
	Remove-ADGroupMember -Identity E_EMEA_SCCM_RU_CTX_4_9 -Members $_ -Confirm:$false
}

# Move PC to OU
Get-ADComputer -SearchBase "OU=Default, OU=CMP, OU=QUE, DC=eur, DC=, DC=com" -Filter * | Where-Object -FilterScript {$_.Name -eq "PF1JV6C5"} | ForEach-Object -Process {
	Move-ADObject -Identity $_ -TargetPath "OU=Laptop, OU=MOS, OU=RU, OU=EMEA, OU=CMP, OU=CORP, DC=eur, DC=, DC=com"
}
Get-ADComputer -Identity PF1JV6C5 | Move-ADObject -TargetPath "OU=Laptop, OU=MOS, OU=RU, OU=EMEA, OU=CMP, OU=CORP, DC=eur, DC=, DC=com"

# Count users in group
$All = @()
Get-ADGroupMember -Identity N_HVC_FS_AmerQual -Server na.domain.com | ForEach-Object -Process {
	# EUR domain
	try
	{
		$All += (Get-ADUser -Identity $_.SamAccountName -Server eur.domain.com | Where-Object -FilterScript {$_.DistinguishedName -like "*DC=eur*"}).UserPrincipalName
	}
	catch {}

	# NA domain
	try
	{
		$All += (Get-ADUser -Identity $_.SamAccountName -Server na.mdomain.com | Where-Object -FilterScript {$_.DistinguishedName -like "*DC=na*"}).UserPrincipalName
	}
	catch {}
}
return $All.Count

# Find group by description
Get-ADGroup -SearchBase "OU=Groups,OU=MOS,OU=RU,OU=Corp,DC=fr,DC=,DC=lcl" -Filter * -Properties * | Where-Object -FilterScript {$_.Description -match "Отделы\\Финансы\\Договоры"} | ForEach-Object -Process {
	[PSCustomObject]@{
		Group = $_.SamAccountName
		Path  = $_.Description
	}
}

# SYSVOL
$env:LOGONSERVER\SYSVOL\$env:USERDNSDOMAIN

# Make a string from array
# Quote every iten in array
(Get-Content -Path "C:\Users\cw200403\Downloads\новый 2.txt" -raw).Replace("`n", "").Replace("`r", "") | ForEach-Object -Process {
	Add-Content -Path "C:\Users\cw200403\Downloads\новый 3.txt" -value "$_" -Force
}

# Get email having userID
$list = @("userID@email.com")
foreach ($item in $list)
{
	try
	{
		(Get-ADUser -Filter * -Properties * -SearchBase "OU=RU,OU=Corp,DC=fr,DC=,DC=lcl" | Where-Object -FilterScript {$_.UserPrincipalName -eq $item}).mail
	}
	catch
	{
		"$item doesn't exist"
	}
}

# Remove new lines
(Get-Content -Path "C:\Users\cw200403\Downloads\новый 2.txt" -raw).Replace("`n", "").Replace("`r", "") | ForEach-Object -Process {
    Add-Content -Path "C:\Users\cw200403\Downloads\новый 3.txt" -value "$_" -Force
}

# Compare
Compare-Object -ReferenceObject (Get-ADPrincipalGroupMembership -Identity belouso).SamAccountName -DifferenceObject (Get-ADPrincipalGroupMembership -Identity pe151147).SamAccountName
