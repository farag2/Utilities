$userID = "userID"
$Name = "Name"
$Surname = "Surname"
$email = "email"

# Set Email
Set-ADUser -Identity $userID -EmailAddress $email

# Set proxyAddresses
Set-ADUser -Identity $userID -Add @{
	proxyAddresses = "SMTP:$email", "smtp:$userID@mymkc.mail.onmicrosoft.com"
}

# Rename in AD
Get-ADUser -Identity $userID | Rename-ADObject -NewName "$($Surname.ToUpper()) $Name"

# Set name and surname
Get-ADUser -Identity $userID | Set-AdUser -GivenName $Name
Get-ADUser -Identity $userID | Set-AdUser -Surname $Surname

# Set the DisplayName property
Get-AdUser -Identity $userID | Set-AdUser -DisplayName "$($Surname.ToUpper()) $Name"

# Enable user account
Set-ADUser -Identity $userID -Enabled $true

# Set the physicalDeliveryOfficeName property
if ((Get-ADUser -Identity $userID -Properties *).Office -eq "office1")
{
	Get-ADUser -Identity $userID | Set-ADUser -Replace @{physicalDeliveryOfficeName = "office1"}
}

if ((Get-ADUser -Identity $userID -Properties *).Office -eq "office2")
{
	Get-ADUser -Identity $userID | Set-ADUser -Replace @{physicalDeliveryOfficeName = "office2"}
}

if ((Get-ADUser -Identity $userID -Properties *).Office -eq "office3")
{
	Get-ADUser -Identity $userID | Set-ADUser -Replace @{physicalDeliveryOfficeName = "office3"}
}

# Set the UserPrincipalName property
Set-ADUser -Identity $userID -UserPrincipalName $email

# Copy all groups from another user, regardless global or eur they are
$userIDgroups = Read-Host -Prompt "Type userID to copy groups from"
if ($userIDgroups)
{
	# Copy all groups from another user, regardless global or eur they are
	(Get-ADPrincipalGroupMembership -Identity $userIDgroups).name | ForEach-Object -Process {
		if (($_ -ne "Domain Users") -and ($_ -ne "Employee_Home"))
		{
			Write-Verbose -Message $_ -Verbose

			# Global groups to assign to
			try
			{
				Get-ADGroup -Identity $_ -Server "server" | Where-Object -FilterScript {$_.DistinguishedName -notlike "*DC=eur*"} | Add-ADGroupMember -Members (Get-ADUser -Identity $userID -Server "eur.server") -Server "server"
			}
			catch {}

			# Europe groups to assign to
			try
			{
				Get-ADGroup -Identity $_ -Server "eur.server" | Where-Object -FilterScript {$_.DistinguishedName -like "*DC=eur*"} | Add-ADGroupMember -Members (Get-ADUser -Identity $userID -Server "eur.server") -Server "eur.server"
			}
			catch {}
		}
	}
}
else
{
	Write-Warning -Message "No userID inputed. Assigning the main groups anyway"

	# The main groups
	@("group1", "group2", "group3") | ForEach-Object -Process {
		Write-Verbose -Message $_ -Verbose

		# Global groups to assign to
		try
		{
			Get-ADGroup -Identity $_ -Server "server" | Where-Object -FilterScript {$_.DistinguishedName -notlike "*DC=eur*"} | Add-ADGroupMember -Members (Get-ADUser -Identity $userID -Server "eur.server") -Server "server"
		}
		catch {}

		# Europe groups to assign to
		try
		{
			Get-ADGroup -Identity $_ -Server "eur.server" | Where-Object -FilterScript {$_.DistinguishedName -like "*DC=eur*"} | Add-ADGroupMember -Members (Get-ADUser -Identity $userID -Server "eur.server") -Server "eur.server"
		}
		catch {}
	}
}

# Remove user from the "group" and don't ask for confirmation
Remove-ADGroupMember -Identity group -Members $userID -Confirm:$false

# Connect home folder: \\\server\users2$\%userID%
# Set-ADUser -Identity $userID -HomeDirectory \\server\users2$\$userID -HomeDrive Q

# Do not require user to change password at the first logon
Set-ADUser -Identity $userID -ChangePasswordAtLogon $false

# Move user to the appropriate OU
if ((Get-ADUser -Identity $userID -Properties *).Office -eq "office1")
{
	Get-ADUser -Identity $userID | Move-ADObject -TargetPath "OU=XX, OU=XX, OU=XX, OU=XX, OU=XX, DC=XX, DC=XX, DC=XX"
}

if ((Get-ADUser -Identity $userID -Properties *).Office -eq "office2")
{
	Get-ADUser -Identity $userID | Move-ADObject -TargetPath "OU=XX, OU=XX, OU=XX, OU=XX, OU=XX, DC=XX, DC=XX, DC=XX"
}

if ((Get-ADUser -Identity $userID -Properties *).Office -eq "office3")
{
	Get-ADUser -Identity $userID | Move-ADObject -TargetPath "OU=XX, OU=XX, OU=XX, OU=XX, OU=XX, DC=XX, DC=XX, DC=XX"
}

# Set a password to user
if ($userID.Length -le 8)
{
	Set-ADAccountPassword -Identity $userID -NewPassword (ConvertTo-SecureString -AsPlainText "$userID$userID$userID" -Force) -Reset
	Write-Warning -Message "Password set `"$userID$userID$userID`""
}
else
{
	Set-ADAccountPassword -Identity $userID -NewPassword (ConvertTo-SecureString -AsPlainText "$userID$userID" -Force) -Reset
	Write-Warning -Message "Password set `"$userID$userI`""
}
