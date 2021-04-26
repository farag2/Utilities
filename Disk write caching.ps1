<#
	.SYNOPSIS
	Configure the disk write caching

	.PARAMETER Disable
	Disable the disk write caching

	.PARAMETER Enable
	Enable the disk write caching

	.EXAMPLE
	DiskWriteCaching -Disable

	.EXAMPLE
	DiskWriteCaching -Enable

	.NOTES
	Current user
#>
function DiskWriteCaching
{
	param
	(
		[Parameter(
			Mandatory = $true,
			ParameterSetName = "Disable"
		)]
		[switch]
		$Disable,

		[Parameter(
			Mandatory = $true,
			ParameterSetName = "Enable"
		)]
		[switch]
		$Enable
	)

	# Get system drive ID regardless of the port number
	$Index = (Get-Partition | Where-Object -FilterScript {$_.DriveLetter -eq $env:SystemDrive[0]}).DiskNumber
	$SystemDriveID = (Get-CimInstance -ClassName CIM_DiskDrive | Where-Object -FilterScript {$_.Index -eq $Index}).PNPDeviceID
	# Get system drive instance
	$PSPath = (Get-ChildItem -Path HKLM:\SYSTEM\CurrentControlSet\Enum\SCSI | Where-Object -FilterScript {$SystemDriveID -match $_.PSChildName}).PSPath
	# We need to go deeper... LeonardoDiCaprio.jpg
	$PSPath = (Get-ChildItem -Path $PSPath | Where-Object -FilterScript {$SystemDriveID -match $_.PSChildName}).PSPath

	# Check whether disk write caching is enabled
	$IsDeviceCacheEnabled = (Get-StorageAdvancedProperty -PhysicalDisk (Get-PhysicalDisk | Where-Object -FilterScript {$_.DeviceID -eq $Index})).IsDeviceCacheEnabled

	switch ($PSCmdlet.ParameterSetName)
	{
		"Disable"
		{
			if ($IsDeviceCacheEnabled)
			{
				if (-not (Test-Path -Path "$PSPath\Device Parameters\Disk"))
				{
					# Create "Disk" folder
					New-Item -Path "$PSPath\Device Parameters\Disk" -Force
				}

				# Disable disk write caching
				New-ItemProperty -Path "$PSPath\Device Parameters\Disk" -Name UserWriteCacheSetting -PropertyType DWord -Value 0 -Force
				New-ItemProperty -Path "$PSPath\Device Parameters\Disk" -Name CacheIsPowerProtected -PropertyType DWord -Value 0 -Force
			}
		}
		"Enable"
		{
			if (-not $IsDeviceCacheEnabled)
			{
				if (-not (Test-Path -Path "$PSPath\Device Parameters\Disk"))
				{
					# Create "Disk" folder
					New-Item -Path "$PSPath\Device Parameters\Disk" -Force
				}

				# Enable disk write caching
				New-ItemProperty -Path "$PSPath\Device Parameters\Disk" -Name UserWriteCacheSetting -PropertyType DWord -Value 1 -Force
				New-ItemProperty -Path "$PSPath\Device Parameters\Disk" -Name CacheIsPowerProtected -PropertyType DWord -Value 0 -Force
			}
		}
	}

	Write-Warning "Make sure to restart your PC!"
}

# DiskWriteCaching -Disable
# DiskWriteCaching -Enable



# https://wintech.sgal.info/2015/11/change-write-caching-policy.html
$DiskNumbersToModify = (1..14)
foreach ($DiskN in $DiskNumbersToModify)
{
	$DiskName = (Get-Disk -Number $DiskN).FriendlyName
	$DiskSN = (Get-Disk -Number $DiskN).SerialNumber
	$DiskPath = (Get-Disk -Number $DiskN).Path
	$DiskType = $DiskPath.Split([char]0x003F,[char]0x0023)
	$RegistryPath += ($DiskType[1]+"\"+$Disktype[2]+"\"+$Disktype[3]+"\Device Parameters\Disk")

	# CacheIsPowerProtected parameter in most cases would be "0"
	New-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Enum -Name CacheIsPowerProtected -Value 0 -PropertyType DWORD -Force

	# "1" turns on write-caching policy, "0" turns off write-caching policy
	New-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Enum -Name UserWriteCacheSetting -Value 1 -PropertyType DWORD -Force
}
