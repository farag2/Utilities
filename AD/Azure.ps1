# https://www.powershellgallery.com/packages/AzureAD/
Connect-AzureAD

# Create table which laptop is assigned to user
$DeviceIDs = @(
	"hostname1"
)
foreach ($DeviceID in $DeviceIDs)
{
	Get-AzureADDevice -All $true -Searchstring $DeviceID | ForEach-Object -Process {
		Get-AzureADDeviceRegisteredOwner -ObjectId $_.ObjectId | ForEach-Object -Process {
			[PSCustomObject]@{
				DeviceID          = $DeviceID
				DisplayName       = $_.DisplayName
				UserPrincipalName = $_.UserPrincipalName
				MailNickName      = $_.MailNickName
				Managed           = $_.IsManaged
			} | Format-Table
		}
	}
}

# https://www.powershellgallery.com/packages/MSOnline
Connect-MsolService

# Create table with users who has laptop assigned
$Users = @(Get-ADUser -SearchBase "OU=RU, OU=EMEA, OU=USR, OU=CORP, DC=eur, DC=mccormick, DC=com" -Filter * -Properties *)
foreach ($User in $Users)
{
	$hostname = if ($null -ne (Get-MsolDevice -RegisteredOwnerUpn $User.UserPrincipalName -ErrorAction Ignore))
	{
		[string](Get-MsolDevice -RegisteredOwnerUpn $User.UserPrincipalName | Where-Object -FilterScript {
			($_.DeviceOsType -eq "Windows") -and ($_.DeviceTrustType -eq "Domain Joined")}
		).DisplayName
	}

	[PSCustomObject]@{
		userID            = $User.SamAccountName
		email             = $User.UserPrincipalName
		hostname          = "$hostname"
		"Last logon date" = $User.LastLogonDate
	} | Select-Object -Property userID, email, hostname, "Last logon date" | Export-Csv -Path "D:\list.csv" -NoTypeInformation -Delimiter ';' -Append -Force
}



# https://www.powershellgallery.com/packages/Microsoft.Graph.Intune
Connect-MSGraph

# Find users in OU which have laptops assigned and create table with laptops models and s/n
$Users = @(Get-ADUser -SearchBase "OU=, OU=, OU=, OU=, DC=, DC=, DC=com" -Filter * -Properties *)
foreach ($User in $Users)
{
	Get-IntuneManagedDevice -Filter "contains(operatingsystem, 'Windows')" | Get-MSGraphAllPages | Where-Object -FilterScript {$_.emailAddress -eq $User.UserPrincipalName} | ForEach-Object -Process {
		[PSCustomObject]@{
			userID       = $User.SamAccountName
			email        = $User.UserPrincipalName
			model        = $_.model
			deviceName   = $_.deviceName
			serialNumber = $_.serialNumber
		} | Select-Object -Property userID, email, model, deviceName, serialNumber | Export-Csv -Path "C:\Users\nefedod\OneDrive - MC CORMICK & COMPANY INC\2.csv" -NoTypeInformation -Delimiter ';' -Append -Force
	}
}
