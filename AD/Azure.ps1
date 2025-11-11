# https://www.powershellgallery.com/packages/Microsoft.Graph
Install-Module -Name Microsoft.Graph -Force
Connect-MgGraph -Scopes "User.Read.All"

# Get iPad properties
$UserIDs = Get-ADUser -SearchBase "OU=RU,OU=Corp,DC=fr,DC=COMPANY,DC=lcl" -Filter * -Properties * | Where-Object {($_.employeeType -ne "SERVICE") -and $_.Enabled}
foreach ($UserID in $UserIDs)
{
	if (Get-MgUserOwnedDevice -UserId $UserID.UserPrincipalName -ErrorAction Ignore)
	{
		Get-MgUserOwnedDevice -UserId $UserID.UserPrincipalName -ErrorAction Ignore | ForEach-Object -Process {
			Get-MgDevice -DeviceId $_.Id -Property * | Where-Object -FilterScript {
				($_.Manufacturer -eq "Apple") -and ([System.Version]$_.OperatingSystemVersion -gt [System.Version]"18.3") -and ([System.Version]$_.OperatingSystemVersion -lt [System.Version]"26.1") -and ($_.OperatingSystem -eq "iOS")
			} | ForEach-Object -Process {
				[PSCustomObject]@{
					Surname  = $UserID.Surname
					hostname = $_.DisplayName
					Model    = $_.Model
					OS       = $_.OperatingSystem
					Build    = $_.OperatingSystemVersion
					"s/n"    = $_.SerialNumber
				}
			} | Format-Table -AutoSize
		}
	}
}

# Get Windows based laptops properties
# https://www.powershellgallery.com/packages/Microsoft.Graph.DeviceManagement
# https://www.powershellgallery.com/packages/Microsoft.Graph
$UserIDs = Get-ADUser -SearchBase "OU=RU,OU=Corp,DC=fr,DC=COMPANY,DC=lcl" -Filter * -Properties * | Where-Object {($_.employeeType -ne "SERVICE") -and $_.Enabled}
foreach ($UserID in $UserIDs)
{
	if (Get-MgUserOwnedDevice -UserId $UserID.UserPrincipalName -ErrorAction Ignore)
	{
		Get-MgUserOwnedDevice -UserId $UserID.UserPrincipalName -ErrorAction Ignore | ForEach-Object -Process {
			Get-MgDevice -DeviceId $_.Id -Property * | Where-Object {$_.OperatingSystem -eq "Windows"} | ForEach-Object {
				[PSCustomObject]@{
					Surname          = $UserID.Surname
					Manufacturer     = $_.Manufacturer
					Model            = $_.Model
					"s/n"            = $_.SerialNumber
					hostname         = $_.DisplayName
					Build            = $_.OperatingSystemVersion
					"Last Sync Time" = $_.OnPremisesLastSyncDateTime
				} | Format-Table -AutoSize
			}
		}
	}
}

# Export laptop properties
# https://www.powershellgallery.com/packages/Microsoft.Graph.DeviceManagement
# https://www.powershellgallery.com/packages/Microsoft.Graph
$UserIDs = Get-ADUser -SearchBase "OU=RU,OU=Corp,DC=fr,DC=COMPANY,DC=lcl" -Filter * -Properties * | Where-Object {($_.employeeType -ne "SERVICE") -and $_.Enabled}
foreach ($UserID in $UserIDs)
{
	$Devices = Get-MgDeviceManagementManagedDevice -All -Filter "OperatingSystem eq 'Windows' and UserPrincipalName eq '$($UserID.UserPrincipalName)'" -Property *
	foreach ($Device in $Devices)
	{
		[PSCustomObject]@{
			Surname        = $UserID.Surname
			Manufacturer   = $Device.Manufacturer
			Model          = $Device.Model
			"s/n"          = $Device.SerialNumber
			hostname       = $Device.DeviceName
			Build          = $Device.OSVersion
			"Sync Time"    = $Device.LastSyncDateTime
			"Free Storage" = [math]::Round($Device.FreeStorageSpaceInBytes/1GB,2)
		} | Select-Object -Property * | Export-Csv -Path "D:\folder\2.csv" -Encoding UTF8 -NoTypeInformation -Delimiter ';' -Append -Force
	}
}

# Export iPad properties
# https://www.powershellgallery.com/packages/Microsoft.Graph.DeviceManagement
# https://www.powershellgallery.com/packages/Microsoft.Graph
$UserIDs = Get-ADUser -SearchBase "OU=RU,OU=Corp,DC=fr,DC=COMPANY,DC=lcl" -Filter * -Properties * | Where-Object {($_.employeeType -ne "SERVICE") -and $_.Enabled}
foreach ($UserID in $UserIDs)
{
	$Devices = Get-MgDeviceManagementManagedDevice -All -Filter "OperatingSystem eq 'iOS' and UserPrincipalName eq '$($UserID.UserPrincipalName)'" -Property *
	foreach ($Device in $Devices)
	{
		[PSCustomObject]@{
			Surname        = $UserID.Surname
			Model          = $Device.Model
			"s/n"          = $Device.SerialNumber
			Build          = [System.Version]$Device.OSVersion
			"Sync Time"    = $Device.LastSyncDateTime
		} | Select-Object -Property * | Export-Csv -Path "D:\folder\2.csv" -Encoding UTF8 -NoTypeInformation -Delimiter ';' -Append -Force
	}
}

Get-MgDeviceManagementManagedDevice -Filter "OperatingSystem eq 'Windows' and UserPrincipalName eq 'userID@COMPANY.com'" -All -PageSize 100 -Property * -Top 100 | fl *
Get-MgDeviceManagementManagedDevice -Filter "OperatingSystem eq 'iOS' and UserPrincipalName eq 'userID@COMPANY.com'" -All -PageSize 100 -Property * -Top 100 | fl *
Get-MgDeviceManagementDetectedAppManagedDevice -Filter "deviceName eq 'PC_Name'" -Property * -all


# Export installed apps from each laptop
# https://www.powershellgallery.com/packages/Microsoft.Graph.DeviceManagement
# https://www.powershellgallery.com/packages/Microsoft.Graph
if (-not (Test-Path -Path D:\folder))
{
	New-Item -Path D:\folder -ItemType Directory -Force
}
Clear-Variable -Name allDetectedApps -ErrorAction Ignore
$allDetectedApps = @()
$UserIDs = Get-ADUser -SearchBase "OU=RU,OU=Corp,DC=fr,DC=COMPANY,DC=lcl" -Filter * -Properties * | Where-Object {($_.employeeType -ne "SERVICE") -and $_.Enabled}
foreach ($UserID in $UserIDs)
{
	$Devices = Get-MgDeviceManagementManagedDevice -All -Filter "OperatingSystem eq 'Windows' and UserPrincipalName eq '$($UserID.UserPrincipalName)'" -Property *
	foreach ($Device in $Devices)
	{
		Clear-Variable allDetectedApps -ErrorAction Ignore

		$Uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices/$($Device.id)/detectedApps?$top=1000&$skip=0"
		do
		{
			$response = Invoke-MgGraphRequest -Uri $Uri -Method GET
			$allDetectedApps += $response.value
			$uri = $response.'@odata.nextLink'
		}
		while ($uri)

		$allDetectedApps | ForEach-Object {
			[PSCustomObject]@{
				Application = $_.displayName
				Version     = $_.version
			}
		} | Select-Object -Property * | Export-Csv -Path "D:\folder\$($UserID.Surname).$($Device.deviceName).$($Device.serialNumber).csv" -Encoding UTF8 -NoTypeInformation -Delimiter ';' -Append -Force
	}
}

# Export installed apps from each iPad
# https://www.powershellgallery.com/packages/Microsoft.Graph.DeviceManagement
# https://www.powershellgallery.com/packages/Microsoft.Graph
if (-not (Test-Path -Path D:\folder))
{
	New-Item -Path D:\folder -ItemType Directory -Force
}
$UserIDs = Get-ADUser -SearchBase "OU=RU,OU=Corp,DC=fr,DC=COMPANY,DC=lcl" -Filter * -Properties * | Where-Object {($_.employeeType -ne "SERVICE") -and $_.Enabled}
Clear-Variable -Name allDetectedApps -ErrorAction Ignore
$allDetectedApps = @()
foreach ($UserID in $UserIDs)
{
	$Devices = Get-MgDeviceManagementManagedDevice -All -Filter "Manufacturer eq 'Apple' and UserPrincipalName eq '$($UserID.UserPrincipalName)'" -Property *
	foreach ($Device in $Devices)
	{
		Clear-Variable allDetectedApps -ErrorAction Ignore

		$Uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices/$($Device.id)/detectedApps?$top=1000&$skip=0"
		do
		{
			$response = Invoke-MgGraphRequest -Uri $Uri -Method GET
			$allDetectedApps += $response.value
			$uri = $response.'@odata.nextLink'
		}
		while ($uri)

		$allDetectedApps | ForEach-Object {
			[PSCustomObject]@{
				Application = $_.displayName
				Version     = $_.version
			}
		} | Select-Object -Property * | Export-Csv -Path "D:\folder\$($UserID.Surname).$($Device.deviceName).$($Device.SerialNumber).csv" -Encoding UTF8 -NoTypeInformation -Delimiter ';' -Append -Force
	}
}

# Get installed apps list for user within Intune Device ID
$allDetectedApps = @()
$Uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices/374690b6-f43c-4c67-9068-50d94063d287/detectedApps?$top=1000&$skip=0"
do
{
	$response = Invoke-MgGraphRequest -Uri $Uri -Method GET
	$allDetectedApps += $response.value
	$uri = $response.'@odata.nextLink'
}
while ($uri)

$allDetectedApps | ForEach-Object {
	[PSCustomObject]@{
		Application = $_.displayName
		Version     = $_.version
	}
}
