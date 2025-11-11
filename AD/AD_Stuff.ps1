# Get user's groups
(Get-ADUser -Identity panteav -Properties MemberOf).MemberOf

# Copy groups from another user
(Get-ADUser -SearchBase "OU=Internal,OU=Users,OU=MOS,OU=RU,OU=Corp,DC=fr,DC=COMPANY,DC=lcl" -Filter * -Properties MemberOf | Where-Object -FilterScript {
	$_.SamAccountName -eq "stefanc"
}).MemberOf | ForEach-Object -Process {Add-ADGroupMember -Identity mortana -Members $_}

(Get-ADUser -Identity stefanc -Properties MemberOf).MemberOf | Add-ADGroupMember -Members iliee

# Copy only missing groups from another user
(Get-ADUser -Identity $user_to_copy_from -Properties MemberOf).MemberOf | Where-Object -FilterScript {
	(Get-ADUser -Identity $user_to_copy_to -Properties MemberOf).MemberOf -notcontains $_
} | Add-ADGroupMember -Members $user_to_copy_to

# Add groups to user
$groups = (
	"CN=group1,OU=Groups,OU=MOS,OU=RU,OU=Corp,DC=fr,DC=COMPANY,DC=lcl",
	"CN=group2,OU=Groups,OU=MOS,OU=RU,OU=Corp,DC=fr,DC=COMPANY,DC=lcl"
)
foreach ($group in $groups)
{
	$groupParams = @{
		Identity = $group
	}
	$Group = Get-ADGroup @groupParams
	Add-ADGroupMember -Identity $Group -Members userID
}
#
Get-ADUser -SearchBase "OU=RU,OU=Corp,DC=fr,DC=COMPANY,DC=lcl" -Filter * -Properties MemberOf | Where-Object -FilterScript {$_.Enabled} | ForEach-Object -Process {
	Add-ADGroupMember -Identity RU-MOS-GS-L_PoliciesProcedures_RO -Members (Get-ADUser -Identity $_.SamAccountName) -Confirm:$false
}

# Find user in the specific OU who is the following groups
Get-ADUser -SearchBase "OU=Internal,OU=Users,OU=MOS,OU=RU,OU=Corp,DC=fr,DC=COMPANY,DC=lcl" -Properties MemberOf -Filter * | Where-Object -FilterScript {$_.MemberOf -match "Legal"}

# Create a table with username and email and export into .csv
Get-ADUser -SearchBase "OU=Internal,OU=Users,OU=MOS,OU=RU,OU=Corp,DC=fr,DC=COMPANY,DC=lcl" -Properties MemberOf -Filter * | Where-Object -FilterScript {
	$_.Enabled -eq $true
} | Select-Object -Property SamAccountName, UserPrincipalName | Export-Csv -Path "C:\1.csv" -NoTypeInformation -Delimiter ';' -Append

# Find users who are in the specific room
(Get-ADUser -SearchBase "OU=Internal,OU=Users,OU=MOS,OU=RU,OU=Corp,DC=fr,DC=COMPANY,DC=lcl" -Filter * -Properties l | Where-Object -FilterScript {$_.l -match "Moscow"}).SamAccountName

# Find users by position
(Get-ADUser -SearchBase "OU=Internal,OU=Users,OU=MOS,OU=RU,OU=Corp,DC=fr,DC=COMPANY,DC=lcl" -Filter * -Properties * | Where-Object -FilterScript {$_.Title -like "*volgograd*"}).SamAccountName

# Create a table with physicalDeliveryOfficeName & userID columns, and move user to the proper physicalDeliveryOfficeName
Get-ADUser -SearchBase "OU=Internal,OU=Users,OU=MOS,OU=RU,OU=Corp,DC=fr,DC=COMPANY,DC=lcl" -Filter * -Properties physicalDeliveryOfficeName | Where-Object -FilterScript {($_.Enabled) -and ($_.physicalDeliveryOfficeName -ne "RU McCormick Moscow")} | ForEach-Object -Process {
	[PSCustomObject] @{
		Name   = $_.Name
		userID = (Get-ADUser -Identity $_).SamAccountName
	}

	Get-ADUser -Identity $_.SamAccountName | ForEach-Object -Process {
		Set-ADUser -Identity $_ -Replace @{physicalDeliveryOfficeName = "Office1"}
	}
}

# Move all users from one OU to another one
Get-ADUser -SearchBase "OU=Internal,OU=Users,OU=MOS,OU=RU,OU=Corp,DC=fr,DC=COMPANY,DC=lcl" -Filter * -Properties * | Move-ADObject -TargetPath "OU=Supply Chain, OU=MOS, OU=RU, OU=EMEA, OU=USR, OU=CORP, DC=eur, DC=COMPANY, DC=com"

# Remove OU (if it is a protected one)
Get-ADOrganizationalUnit -Identity "OU=Internal,OU=Users,OU=MOS,OU=RU,OU=Corp,DC=fr,DC=COMPANY,DC=lcl" | Set-ADObject -ProtectedFromAccidentalDeletion:$false -PassThru | Remove-ADOrganizationalUnit -Confirm:$false

# Create table with userID and user name
$emails = @()
foreach ($email in $emails)
{
	Get-ADUser -SearchBase "OU=Internal,OU=Users,OU=MOS,OU=RU,OU=Corp,DC=fr,DC=COMPANY,DC=lcl" -Filter * | Where-Object -FilterScript {($_.Enabled) -and ($_.UserPrincipalName -eq $email)} | ForEach-Object -Process {
		[PSCustomObject]@{
			Name  = $_.SamAccountName
			Email = $_.UserPrincipalName
		}
	}
}

# Assign a user to a group from another domain
$ADGroup = Get-ADGroup -Identity M_GBL_ALL_Employees -Server COMPANY.com
$userID = Get-ADUser -Identity PAUNF -Server eur.COMPANY.com
Add-ADGroupMember -Identity $ADGroup -Members $userID -Server COMPANY.com

# Assign user to a group
Get-ADUser -Identity $UserID | ForEach-Object -Process {
	Add-ADGroupMember -Identity E_EMEA_APP_M365_E5 -Members $_ -Confirm:$false
	Remove-ADGroupMember -Identity E_EMEA_APP_M365_F3_F5Security -Members $_ -Confirm:$false
}

# Install ExchangeOnlineManagement
Install-Module -Name ExchangeOnlineManagement -Force
Connect-ExchangeOnline
Get-DistributionGroupMember -Identity "*moscow*"
(Get-UnifiedGroupLinks -Identity "COMPANY_Russia_Moscow" -LinkType Members).WindowsLiveID

Get-DistributionGroupMember -Identity RU_Logistics_PFDC | ForEach-Object -Process {
	Add-DistributionGroupMember -Identity RU_SupplyChain -Member $_.WindowsLiveID -BypassSecurityGroupManagerCheck
}

# Check when user's passwor expires
Get-ADUser -Identity userID –Properties DisplayName, msDS-UserPasswordExpiryTimeComputed | Select-Object -Property Displayname, @{
	Name       = "Expiration date"
	Expression = {[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}
}

# Open C drive on a remote PC
\\$env:COMPUTERNAME\c$

# Asign every PC in the OU to the group
Get-ADComputer -SearchBase "OU=Laptop, OU=MOS, OU=RU, OU=EMEA, OU=CMP, OU=CORP, DC=eur, DC=COMPANY, DC=com" -Filter * -Properties MemberOf | Where-Object -FilterScript {[string]$_.MemberOf -notmatch "E_EMEA_SCCM_RU_CTX_4_9"} | ForEach-Object -Process {
	Add-ADGroupMember -Members (Get-ADComputer -Identity $_.Name) -Identity E_EMEA_SCCM_RU_CTX_4_9
}

# Remove PC from group
Remove-ADGroupMember -Members (Get-ADComputer -Identity MOSL001718) -Identity E_EMEA_SCCM_RU_CTX_4_9 -Confirm:$false
Get-ADComputer -Identity 7K44273 | ForEach-Object -Process {
	Remove-ADGroupMember -Identity E_EMEA_SCCM_RU_CTX_4_9 -Members $_ -Confirm:$false
}

# Move PC to OU
Get-ADComputer -SearchBase "OU=Default, OU=CMP, OU=QUE, DC=eur, DC=COMPANY, DC=com" -Filter * | Where-Object -FilterScript {$_.Name -eq "PF1JV6C5"} | ForEach-Object -Process {
	Move-ADObject -Identity $_ -TargetPath "OU=Laptop, OU=MOS, OU=RU, OU=EMEA, OU=CMP, OU=CORP, DC=eur, DC=COMPANY, DC=com"
}
Get-ADComputer -Identity PF1JV6C5 | Move-ADObject -TargetPath "OU=Laptop, OU=MOS, OU=RU, OU=EMEA, OU=CMP, OU=CORP, DC=eur, DC=COMPANY, DC=com"

# Count users in group
$All = @()
Get-ADGroupMember -Identity N_HVC_FS_AmerQual -Server na.COMPANY.com | ForEach-Object -Process {
	# EUR domain
	try
	{
		$All += (Get-ADUser -Identity $_.SamAccountName -Server eur.COMPANY.com | Where-Object -FilterScript {$_.DistinguishedName -like "*DC=eur*"}).UserPrincipalName
	}
	catch {}

	# NA domain
	try
	{
		$All += (Get-ADUser -Identity $_.SamAccountName -Server na.COMPANY.com | Where-Object -FilterScript {$_.DistinguishedName -like "*DC=na*"}).UserPrincipalName
	}
	catch {}
}
return $All.Count

# Find group by description
Get-ADGroup -SearchBase "OU=Groups,OU=MOS,OU=RU,OU=Corp,DC=fr,DC=COMPANY,DC=lcl" -Filter * -Properties * | Where-Object -FilterScript {$_.Description -match "Отделы\\Финансы\\Договоры"} | ForEach-Object -Process {
	[PSCustomObject]@{
		Group = $_.SamAccountName
		Path  = $_.Description
	}
}

# SYSVOL
"$env:LOGONSERVER\SYSVOL\$env:USERDNSDOMAIN"

# Get email having userID
$list = @("userID@COMPANY.com")
foreach ($item in $list)
{
	try
	{
		(Get-ADUser -Filter * -Properties * -SearchBase "OU=RU,OU=Corp,DC=fr,DC=COMPANY,DC=lcl" | Where-Object -FilterScript {$_.UserPrincipalName -eq $item}).mail
	}
	catch
	{
		"$item does not exist"
	}
}

# Compare groups
Compare-Object -ReferenceObject (Get-ADPrincipalGroupMembership -Identity userID1).SamAccountName -DifferenceObject (Get-ADPrincipalGroupMembership -Identity userID2).SamAccountName

# Get long paths in all subfolders
try
{
	Get-ChildItem -Path D:\Folder -ErrorAction Stop -Recurse -Force | ForEach-Object -Process {
		try
		{
			if ($_.DirectoryName.Length -gt 246)
			{
				# Write-Host -Object $_.DirectoryName -ForegroundColor Yellow

				[PSCustomObject]@{
					"Path"   = $_.FullName
					"Length" = $_.FullName.Length
				} | Select-Object -Property Path, Length | Export-Csv -Path "F:\Directory.csv" -Encoding UTF8 -NoTypeInformation -Delimiter ';' -Append
			}
			elseif ($_.FullName.Length -gt 260)
			{
				# Write-Host -Object $_.FullName -ForegroundColor Yellow

				[PSCustomObject]@{
					"Path"   = $_.FullName
					"Length" = $_.FullName.Length
				} | Select-Object -Property Path, Length | Export-Csv -Path "F:\File.csv" -Encoding UTF8 -NoTypeInformation -Delimiter ';' -Append
			}
		}
		catch # [System.Management.Automation.RuntimeException]
		{}
	}
}
catch
{
	$_.FullName
}
#
Get-ChildItem -Path D:\Folder -Recurse -Force | ForEach-Object -Process {
	try
	{
		if ($_.DirectoryName.Length -gt 246)
		{
			# Write-Host -Object $_.DirectoryName -ForegroundColor Yellow

			[PSCustomObject]@{
				"Path"   = $_.FullName
				"Length" = $_.FullName.Length
			} | Select-Object -Property Path, Length | Export-Csv -Path "F:\1\Directory.csv" -Encoding UTF8 -NoTypeInformation -Delimiter ';' -Append
		}
		elseif ($_.FullName.Length -gt 260)
		{
			# Write-Host -Object $_.FullName -ForegroundColor Yellow

			[PSCustomObject]@{
				"Path"   = $_.FullName
				"Length" = $_.FullName.Length
			} | Select-Object -Property Path, Length | Export-Csv -Path "F:\1\File.csv" -Encoding UTF8 -NoTypeInformation -Delimiter ';' -Append
		}
	}
	catch # [System.Management.Automation.RuntimeException]
	{
		Write-Host -Object $_.FullName -ForegroundColor Yellow
	}
}

# Get SID in AD
$SID = (Get-ADUser -Identity $env:USERNAME).SID.Value
"Registry::HKEY_USERS\$($SID)_Classes"

# Change password
$NewPassword = (ConvertTo-SecureString -AsPlainText "password" -Force)
Set-ADAccountPassword -Identity userID -Server (Get-ADDomainController).Name -NewPassword $NewPassword

# Password expired/lockedout
(Get-ADUser -SearchBase "OU=RU,OU=Corp,DC=fr,DC=COMPANY,DC=lcl" -Properties * -Filter * | Where-Object -FilterScript {$_.PasswordExpired}).DisplayName
(Get-ADUser -SearchBase "OU=RU,OU=Corp,DC=fr,DC=COMPANY,DC=lcl" -Properties * -Filter * | Where-Object -FilterScript {$_.LockedOut}).DisplayName
#
$Users = @(
	"UserID1",
	"UserID2"
)
"Locked Out"
foreach ($User in $Users)
{
	(Get-ADUser -Identity $User -Properties * | Where-Object -FilterScript {$_.lockedOut}).DisplayName
}

"`nPassword Expired"
foreach ($User in $Users)
{
	(Get-ADUser -Identity $User -Properties * | Where-Object -FilterScript {$_.passwordExpired}).DisplayName
}

# Invoke command remotely
# Get-Service -Name WinRM
# Test-WsMan -ComputerName PC_name
Enter-PSSession -ComputerName PC_name.COMPANY
Get-LocalUser -Name root | Remove-LocalUser -Confirm:$false
Exit-PSSession
# 
Invoke-Command -ComputerName PC_name -ScriptBlock {$env:USERNAME}
# -FilePath C:\Scripts\DiskCollect.ps1

# Forcibly sync Company Portal
Start-Process -FilePath "intunemanagementextension://syncapp" -Wait

# Create AD Group
New-ADGroup -Name RU-MOS-GS-DeployPrinterHR -GroupScope Global -Path "OU=Groups,DC=example,DC=com" -Description "Marketing team group"

# Check who installed apps
$Parameters = @{
	LogName = "Application"
	Id      = "11707"
}
$UserId = @{
	Label      = "UserId"
	Expression = {(New-Object -TypeName System.Security.Principal.SecurityIdentifier($_.UserId)).Translate([System.Security.Principal.NTAccount]).Value}
}
Get-WinEvent -FilterHashtable $Parameters | Select-Object -Property Message, TimeCreated, $UserId

# Unmap all drives
Get-SmbMapping | Remove-SmbMapping -Force
