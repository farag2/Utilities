# https://theorypc.ca/2017/06/28/remove-ghost-devices-natively-with-powershell/
$removeDevices = $true
$setupapi = @"
using System;
using System.Diagnostics;
using System.Text;
using System.Runtime.InteropServices;
namespace Win32
{
	public static class SetupApi
	{
		[DllImport("setupapi.dll", CharSet = CharSet.Auto)]
		public static extern IntPtr SetupDiGetClassDevs(
		ref Guid ClassGuid,
		IntPtr Enumerator,
		IntPtr hwndParent,
		int Flags
		);

		[DllImport("setupapi.dll", CharSet = CharSet.Auto)]
		public static extern IntPtr SetupDiGetClassDevs(
		IntPtr ClassGuid,
		string Enumerator,
		IntPtr hwndParent,
		int Flags
		);

		[DllImport("setupapi.dll", CharSet = CharSet.Auto, SetLastError = true)]
		public static extern bool SetupDiEnumDeviceInfo(
		IntPtr DeviceInfoSet,
		uint MemberIndex,
		ref SP_DEVINFO_DATA DeviceInfoData
		);

		[DllImport("setupapi.dll", SetLastError = true)]
		public static extern bool SetupDiDestroyDeviceInfoList(
		IntPtr DeviceInfoSet
		);
		[DllImport("setupapi.dll", CharSet = CharSet.Auto, SetLastError = true)]
		public static extern bool SetupDiGetDeviceRegistryProperty(
		IntPtr deviceInfoSet,
		ref SP_DEVINFO_DATA deviceInfoData,
		uint property,
		out UInt32 propertyRegDataType,
		byte[] propertyBuffer,
		uint propertyBufferSize,
		out UInt32 requiredSize
		);
		[DllImport("setupapi.dll", SetLastError = true, CharSet = CharSet.Auto)]
		public static extern bool SetupDiGetDeviceInstanceId(
		IntPtr DeviceInfoSet,
		ref SP_DEVINFO_DATA DeviceInfoData,
		StringBuilder DeviceInstanceId,
		int DeviceInstanceIdSize,
		out int RequiredSize
		);

		[DllImport("setupapi.dll", CharSet = CharSet.Auto, SetLastError = true)]
		public static extern bool SetupDiRemoveDevice(IntPtr DeviceInfoSet,ref SP_DEVINFO_DATA DeviceInfoData);
	}
	[StructLayout(LayoutKind.Sequential)]
	public struct SP_DEVINFO_DATA
	{
		public uint cbSize;
		public Guid classGuid;
		public uint devInst;
		public IntPtr reserved;
	}
	[Flags]
	public enum DiGetClassFlags : uint
	{
		DIGCF_DEFAULT		= 0x00000001,  // only valid with DIGCF_DEVICEINTERFACE
		DIGCF_PRESENT		= 0x00000002,
		DIGCF_ALLCLASSES	= 0x00000004,
		DIGCF_PROFILE		= 0x00000008,
		DIGCF_DEVICEINTERFACE	= 0x00000010,
	}
	public enum SetupDiGetDeviceRegistryPropertyEnum : uint
	{
		SPDRP_DEVICEDESC		= 0x00000000, // DeviceDesc (R/W)
		SPDRP_HARDWAREID		= 0x00000001, // HardwareID (R/W)
		SPDRP_COMPATIBLEIDS		= 0x00000002, // CompatibleIDs (R/W)
		SPDRP_UNUSED0			= 0x00000003, // unused
		SPDRP_SERVICE			= 0x00000004, // Service (R/W)
		SPDRP_UNUSED1			= 0x00000005, // unused
		SPDRP_UNUSED2			= 0x00000006, // unused
		SPDRP_CLASS				= 0x00000007, // Class (R--tied to ClassGUID)
		SPDRP_CLASSGUID			= 0x00000008, // ClassGUID (R/W)
		SPDRP_DRIVER			 = 0x00000009, // Driver (R/W)
		SPDRP_CONFIGFLAGS		= 0x0000000A, // ConfigFlags (R/W)
		SPDRP_MFG			= 0x0000000B, // Mfg (R/W)
		SPDRP_FRIENDLYNAME	= 0x0000000C, // FriendlyName (R/W)
		SPDRP_LOCATION_INFORMATION	= 0x0000000D, // LocationInformation (R/W)
		SPDRP_PHYSICAL_DEVICE_OBJECT_NAME	= 0x0000000E, // PhysicalDeviceObjectName (R)
		SPDRP_CAPABILITIES	= 0x0000000F, // Capabilities (R)
		SPDRP_UI_NUMBER		= 0x00000010, // UiNumber (R)
		SPDRP_UPPERFILTERS	= 0x00000011, // UpperFilters (R/W)
		SPDRP_LOWERFILTERS	= 0x00000012, // LowerFilters (R/W)
		SPDRP_BUSTYPEGUID	= 0x00000013, // BusTypeGUID (R)
		SPDRP_LEGACYBUSTYPE	= 0x00000014, // LegacyBusType (R)
		SPDRP_BUSNUMBER		= 0x00000015, // BusNumber (R)
		SPDRP_ENUMERATOR_NAME		= 0x00000016, // Enumerator Name (R)
		SPDRP_SECURITY		= 0x00000017, // Security (R/W, binary form)
		SPDRP_SECURITY_SDS	= 0x00000018, // Security (W, SDS form)
		SPDRP_DEVTYPE			= 0x00000019, // Device Type (R/W)
		SPDRP_EXCLUSIVE		= 0x0000001A, // Device is exclusive-access (R/W)
		SPDRP_CHARACTERISTICS		= 0x0000001B, // Device Characteristics (R/W)
		SPDRP_ADDRESS			= 0x0000001C, // Device Address (R)
		SPDRP_UI_NUMBER_DESC_FORMAT		= 0X0000001D, // UiNumberDescFormat (R/W)
		SPDRP_DEVICE_POWER_DATA		= 0x0000001E, // Device Power Data (R)
		SPDRP_REMOVAL_POLICY		 = 0x0000001F, // Removal Policy (R)
		SPDRP_REMOVAL_POLICY_HW_DEFAULT	= 0x00000020, // Hardware Removal Policy (R)
		SPDRP_REMOVAL_POLICY_OVERRIDE	= 0x00000021, // Removal Policy Override (RW)
		SPDRP_INSTALL_STATE		= 0x00000022, // Device Install State (R)
		SPDRP_LOCATION_PATHS		= 0x00000023, // Device Location Paths (R)
		SPDRP_BASE_CONTAINERID	= 0x00000024 // Base ContainerID (R)
	}
}
"@
Add-Type -TypeDefinition $setupapi

$removeArray = @()
$array = @()
$setupClass = [Guid]::Empty
$devs = [Win32.SetupApi]::SetupDiGetClassDevs([ref]$setupClass, [IntPtr]::Zero, [IntPtr]::Zero, [Win32.DiGetClassFlags]::DIGCF_ALLCLASSES)
$devInfo = New-Object Win32.SP_DEVINFO_DATA
$devInfo.cbSize = [System.Runtime.InteropServices.Marshal]::SizeOf($devInfo)
$devCount = 0
While ([Win32.SetupApi]::SetupDiEnumDeviceInfo($devs, $devCount, [ref]$devInfo))
{
	$propType = 0
	[byte[]]$propBuffer = $null
	$propBufferSize = 0
	[Win32.SetupApi]::SetupDiGetDeviceRegistryProperty($devs, [ref]$devInfo, [Win32.SetupDiGetDeviceRegistryPropertyEnum]::SPDRP_FRIENDLYNAME, [ref]$propType, $propBuffer, 0, [ref]$propBufferSize) | Out-Null
	[byte[]]$propBuffer = New-Object 'byte[]' $propBufferSize

	$propTypeHWID = 0
	[byte[]]$propBufferHWID = $null
	$propBufferSizeHWID = 0
	[Win32.SetupApi]::SetupDiGetDeviceRegistryProperty($devs, [ref]$devInfo, [Win32.SetupDiGetDeviceRegistryPropertyEnum]::SPDRP_HARDWAREID, [ref]$propTypeHWID, $propBufferHWID, 0, [ref]$propBufferSizeHWID) | Out-Null
	[byte[]]$propBufferHWID = New-Object 'byte[]' $propBufferSizeHWID

	$propTypeDD = 0
	[byte[]]$propBufferDD = $null
	$propBufferSizeDD = 0
	[Win32.SetupApi]::SetupDiGetDeviceRegistryProperty($devs, [ref]$devInfo, [Win32.SetupDiGetDeviceRegistryPropertyEnum]::SPDRP_DEVICEDESC, [ref]$propTypeDD, $propBufferDD, 0, [ref]$propBufferSizeDD) | Out-Null
	[byte[]]$propBufferDD = New-Object 'byte[]' $propBufferSizeDD

	$propTypeIS = 0
	[byte[]]$propBufferIS = $null
	$propBufferSizeIS = 0
	[Win32.SetupApi]::SetupDiGetDeviceRegistryProperty($devs, [ref]$devInfo, [Win32.SetupDiGetDeviceRegistryPropertyEnum]::SPDRP_INSTALL_STATE, [ref]$propTypeIS, $propBufferIS, 0, [ref]$propBufferSizeIS) | Out-Null
	[byte[]]$propBufferIS = New-Object 'byte[]' $propBufferSizeIS

	$propTypeCLSS = 0
	[byte[]]$propBufferCLSS = $null
	$propBufferSizeCLSS = 0
	[Win32.SetupApi]::SetupDiGetDeviceRegistryProperty($devs, [ref]$devInfo, [Win32.SetupDiGetDeviceRegistryPropertyEnum]::SPDRP_CLASS, [ref]$propTypeCLSS, $propBufferCLSS, 0, [ref]$propBufferSizeCLSS) | Out-Null
	[byte[]]$propBufferCLSS = New-Object 'byte[]' $propBufferSizeCLSS
	[Win32.SetupApi]::SetupDiGetDeviceRegistryProperty($devs, [ref]$devInfo,[Win32.SetupDiGetDeviceRegistryPropertyEnum]::SPDRP_CLASS, [ref]$propTypeCLSS, $propBufferCLSS, $propBufferSizeCLSS, [ref]$propBufferSizeCLSS) | Out-Null
	$Class = [System.Text.Encoding]::Unicode.GetString($propBufferCLSS)

	IF(-not [Win32.SetupApi]::SetupDiGetDeviceRegistryProperty($devs, [ref]$devInfo,[Win32.SetupDiGetDeviceRegistryPropertyEnum]::SPDRP_FRIENDLYNAME, [ref]$propType, $propBuffer, $propBufferSize, [ref]$propBufferSize))
	{
		[Win32.SetupApi]::SetupDiGetDeviceRegistryProperty($devs, [ref]$devInfo,[Win32.SetupDiGetDeviceRegistryPropertyEnum]::SPDRP_DEVICEDESC, [ref]$propTypeDD, $propBufferDD, $propBufferSizeDD, [ref]$propBufferSizeDD) | Out-Null
		$FriendlyName = [System.Text.Encoding]::Unicode.GetString($propBufferDD)
		IF ($FriendlyName.Length -ge 1)
		{
			$FriendlyName = $FriendlyName.Substring(0,$FriendlyName.Length-1)
		}
	}
	Else
	{
		$FriendlyName = [System.Text.Encoding]::Unicode.GetString($propBuffer)
		IF ($FriendlyName.Length -ge 1)
		{
			$FriendlyName = $FriendlyName.Substring(0,$FriendlyName.Length-1)
		}
	}

	$InstallState = [Win32.SetupApi]::SetupDiGetDeviceRegistryProperty($devs, [ref]$devInfo,[Win32.SetupDiGetDeviceRegistryPropertyEnum]::SPDRP_INSTALL_STATE, [ref]$propTypeIS, $propBufferIS, $propBufferSizeIS, [ref]$propBufferSizeIS)

	IF(-not [Win32.SetupApi]::SetupDiGetDeviceRegistryProperty($devs, [ref]$devInfo,[Win32.SetupDiGetDeviceRegistryPropertyEnum]::SPDRP_HARDWAREID, [ref]$propTypeHWID, $propBufferHWID, $propBufferSizeHWID, [ref]$propBufferSizeHWID))
	{
		$HWID = ""
	}
	Else
	{
		$HWID = [System.Text.Encoding]::Unicode.GetString($propBufferHWID)
		$HWID = $HWID.split([char]0x0000)[0].ToUpper()
	}

	$obj = New-Object System.Object
	$obj | Add-Member -Type NoteProperty -Name FriendlyName -value $FriendlyName
	$obj | Add-Member -Type NoteProperty -Name HWID -value $HWID
	$obj | Add-Member -Type NoteProperty -Name InstallState -value $InstallState
	$obj | Add-Member -Type NoteProperty -Name Class -value $Class
	IF ($array.Count -le 0)
	{
		Start-Sleep 1
	}
	$array += @($obj)

	$matchFilter = $False
	IF ($removeDevices -eq $true)
	{
		IF ($InstallState -eq $False)
		{
			IF ($matchFilter -eq $False)
			{
				Write-Host "Attempting to removing device $FriendlyName" -ForegroundColor Yellow
				$removeObj = New-Object System.Object
				$removeObj | Add-Member -Type NoteProperty -Name FriendlyName -Value $FriendlyName
				$removeObj | Add-Member -Type NoteProperty -Name HWID -Value $HWID
				$removeObj | Add-Member -Type NoteProperty -Name InstallState -Value $InstallState
				$removeObj | Add-Member -Type NoteProperty -Name Class -Value $Class
				$removeArray += @($removeObj)
				IF([Win32.SetupApi]::SetupDiRemoveDevice($devs, [ref]$devInfo))
				{
					Write-Host "Removed device $FriendlyName" -ForegroundColor Green
				}
				Else
				{
					Write-Host "Failed to remove device $FriendlyName" -ForegroundColor Red
				}
			}
			Else
			{
				Write-Host "Filter matched. Skipping $FriendlyName" -ForegroundColor Yellow
			}
		}
	}
	$devcount++
}

IF ($removeDevices -eq $true)
{
	Write-Host "Removed devices:"
	$removeArray | Sort-Object -Property FriendlyName | Format-Table
	Write-Host "Total removed devices: $($removeArray.count)"
	return $removeArray | Out-Null
}
