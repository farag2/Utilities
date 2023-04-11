<#
	.SYNOPSIS
	Register app, calculate hash, and associate with an extension with the "How do you want to open this" pop-up hidden

	.PARAMETER ProgramPath
	Set a path to a program to associate an extension with

	.PARAMETER Extension
	Set the extension type

	.PARAMETER Icon
	Set a path to an icon

	.EXAMPLE
	Set-Association -ProgramPath "C:\SumatraPDF.exe" -Extension .pdf -Icon "shell32.dll,100"

	.EXAMPLE
	Set-Association -ProgramPath "%ProgramFiles%\Notepad++\notepad++.exe" -Extension .txt -Icon "%ProgramFiles%\Notepad++\notepad++.exe,0"

	.EXAMPLE
	& "D:\Script.ps1" -Path "%LOCALAPPDATA%\Programs\Microsoft VS Code\Code.exe" -Extensions .rc, .txt

	.LINK
	https://github.com/DanysysTeam/PS-SFTA
	https://github.com/default-username-was-already-taken/set-fileassoc
	https://forum.ru-board.com/profile.cgi?action=show&member=westlife

	.NOTES
	Machine-wide
#>

#Requires -RunAsAdministrator
#Requires -Version 5.1

[CmdletBinding()]
param
(
	[Parameter(
		Mandatory = $true
	)]
	[string]
	$Path,

	[Parameter(
		Mandatory = $true
	)]
	[string[]]
	$Extensions
)

Clear-Host

Set-StrictMode -Version Latest

<#
	.SYNOPSIS
	Register app, calculate hash, and associate with an extension with the "How do you want to open this" pop-up hidden

	.PARAMETER ProgramPath
	Set a path to a program to associate an extension with

	.PARAMETER Extension
	Set the extension type

	.PARAMETER Icon
	Set a path to an icon

	.EXAMPLE
	Set-Association -ProgramPath "C:\SumatraPDF.exe" -Extension .pdf -Icon "shell32.dll,100"

	.EXAMPLE
	Set-Association -ProgramPath "%ProgramFiles%\Notepad++\notepad++.exe" -Extension .txt -Icon "%ProgramFiles%\Notepad++\notepad++.exe,0"

	.LINK
	https://github.com/DanysysTeam/PS-SFTA
	https://github.com/default-username-was-already-taken/set-fileassoc
	https://forum.ru-board.com/profile.cgi?action=show&member=westlife

	.NOTES
	Machine-wide
#>
function Set-Association
{
	[CmdletBinding()]
	Param
	(
		[Parameter(
			Mandatory = $true,
			Position = 0
		)]
		[string]
		$ProgramPath,

		[Parameter(
			Mandatory = $true,
			Position = 1
		)]
		[string]
		$Extension,

		[Parameter(Mandatory = $false)]
		[string]
		$Icon
	)

	$ProgramPath = [System.Environment]::ExpandEnvironmentVariables($ProgramPath)

	if (-not (Test-Path -Path $ProgramPath))
	{
		Write-Verbose -Message $Localization.Skipped -Verbose
		Write-Error -Message $Localization.NoInternetConnection -ErrorAction SilentlyContinue
		Write-Error -Message ($Localization.RestartFunction -f $MyInvocation.Line) -ErrorAction SilentlyContinue

		return
	}

	if ($Icon)
	{
		$Icon = [System.Environment]::ExpandEnvironmentVariables($Icon)
	}

	if (Test-Path -Path $ProgramPath)
	{
		# Generate ProgId
		$ProgId = (Get-Item -Path $ProgramPath).BaseName + $Extension.ToUpper()
	}
	else
	{
		$ProgId = $ProgramPath
	}

	#region functions
	$RegistryUtils = @'
using System;
using System.Runtime.InteropServices;
using System.Security.AccessControl;
using System.Text;
using Microsoft.Win32;
using FILETIME = System.Runtime.InteropServices.ComTypes.FILETIME;

namespace RegistryUtils
{
	public static class Action
	{
		[DllImport("advapi32.dll", CharSet = CharSet.Auto)]
		private static extern int RegOpenKeyEx(UIntPtr hKey, string subKey, int ulOptions, int samDesired, out UIntPtr hkResult);

		[DllImport("advapi32.dll", SetLastError = true)]
		private static extern int RegCloseKey(UIntPtr hKey);

		[DllImport("advapi32.dll", SetLastError=true, CharSet = CharSet.Unicode)]
		private static extern uint RegDeleteKey(UIntPtr hKey, string subKey);

		[DllImport("advapi32.dll", EntryPoint = "RegQueryInfoKey", CallingConvention = CallingConvention.Winapi, SetLastError = true)]
		private static extern int RegQueryInfoKey(UIntPtr hkey, out StringBuilder lpClass, ref uint lpcbClass, IntPtr lpReserved,
			out uint lpcSubKeys, out uint lpcbMaxSubKeyLen, out uint lpcbMaxClassLen, out uint lpcValues, out uint lpcbMaxValueNameLen,
			out uint lpcbMaxValueLen, out uint lpcbSecurityDescriptor, ref FILETIME lpftLastWriteTime);

		[DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
		internal static extern bool OpenProcessToken(IntPtr h, int acc, ref IntPtr phtok);

		[DllImport("kernel32.dll", ExactSpelling = true)]
		internal static extern IntPtr GetCurrentProcess();

		[DllImport("advapi32.dll", SetLastError = true)]
		internal static extern bool LookupPrivilegeValue(string host, string name, ref long pluid);

		[DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
		internal static extern bool AdjustTokenPrivileges(IntPtr htok, bool disall, ref TokPriv1Luid newst, int len, IntPtr prev, IntPtr relen);

		[DllImport("advapi32.dll", CharSet = CharSet.Auto, SetLastError = true)]
		private static extern int RegLoadKey(uint hKey, string lpSubKey, string lpFile);

		[DllImport("advapi32.dll", CharSet = CharSet.Auto, SetLastError = true)]
		private static extern int RegUnLoadKey(uint hKey, string lpSubKey);

		[StructLayout(LayoutKind.Sequential, Pack = 1)]
		internal struct TokPriv1Luid
		{
			public int Count;
			public long Luid;
			public int Attr;
		}

		public static void DeleteKey(RegistryHive registryHive, string subkey)
		{
			UIntPtr hKey = UIntPtr.Zero;

			try
			{
				var hive = new UIntPtr(unchecked((uint)registryHive));
				RegOpenKeyEx(hive, subkey, 0, 0x20019, out hKey);
				RegDeleteKey(hive, subkey);
			}
			finally
			{
				if (hKey != UIntPtr.Zero)
				{
					RegCloseKey(hKey);
				}
			}
		}

		private static DateTime ToDateTime(FILETIME ft)
		{
			IntPtr buf = IntPtr.Zero;
			try
			{
				long[] longArray = new long[1];
				int cb = Marshal.SizeOf(ft);
				buf = Marshal.AllocHGlobal(cb);
				Marshal.StructureToPtr(ft, buf, false);
				Marshal.Copy(buf, longArray, 0, 1);
				return DateTime.FromFileTime(longArray[0]);
			}
			finally
			{
				if (buf != IntPtr.Zero) Marshal.FreeHGlobal(buf);
			}
		}

		public static DateTime? GetLastModified(RegistryHive registryHive, string subKey)
		{
			var lastModified = new FILETIME();
			var lpcbClass = new uint();
			var lpReserved = new IntPtr();
			UIntPtr hKey = UIntPtr.Zero;

			try
			{
				try
				{
					var hive = new UIntPtr(unchecked((uint)registryHive));
					if (RegOpenKeyEx(hive, subKey, 0, (int)RegistryRights.ReadKey, out hKey) != 0)
					{
						return null;
					}

					uint lpcbSubKeys;
					uint lpcbMaxKeyLen;
					uint lpcbMaxClassLen;
					uint lpcValues;
					uint maxValueName;
					uint maxValueLen;
					uint securityDescriptor;
					StringBuilder sb;

					if (RegQueryInfoKey(hKey, out sb, ref lpcbClass, lpReserved, out lpcbSubKeys, out lpcbMaxKeyLen, out lpcbMaxClassLen,
						out lpcValues, out maxValueName, out maxValueLen, out securityDescriptor, ref lastModified) != 0)
					{
						return null;
					}

					var result = ToDateTime(lastModified);
					return result;
				}
				finally
				{
					if (hKey != UIntPtr.Zero)
					{
						RegCloseKey(hKey);
					}
				}
			}
			catch (Exception)
			{
				return null;
			}
		}

		internal const int SE_PRIVILEGE_DISABLED = 0x00000000;
		internal const int SE_PRIVILEGE_ENABLED = 0x00000002;
		internal const int TOKEN_QUERY = 0x00000008;
		internal const int TOKEN_ADJUST_PRIVILEGES = 0x00000020;

		public enum RegistryHives : uint
		{
			HKEY_USERS = 0x80000003,
			HKEY_LOCAL_MACHINE = 0x80000002
		}

		public static void AddPrivilege(string privilege)
		{
			bool retVal;
			TokPriv1Luid tp;
			IntPtr hproc = GetCurrentProcess();
			IntPtr htok = IntPtr.Zero;
			retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);
			tp.Count = 1;
			tp.Luid = 0;
			tp.Attr = SE_PRIVILEGE_ENABLED;
			retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);
			retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
			///return retVal;
		}

		public static int LoadHive(RegistryHives hive, string subKey, string filePath)
		{
			AddPrivilege("SeRestorePrivilege");
			AddPrivilege("SeBackupPrivilege");

			uint regHive = (uint)hive;
			int result = RegLoadKey(regHive, subKey, filePath);

			return result;
		}

		public static int UnloadHive(RegistryHives hive, string subKey)
		{
			AddPrivilege("SeRestorePrivilege");
			AddPrivilege("SeBackupPrivilege");

			uint regHive = (uint)hive;
			int result = RegUnLoadKey(regHive, subKey);

			return result;
		}
	}
}
'@

	if (-not('RegistryUtils.Action' -as [type]))
	{
		Add-Type -TypeDefinition $RegistryUtils
	}

	function Write-ExtensionKeys
	{
		Param
		(
			[Parameter(
				Mandatory = $true,
				Position = 0
			)]
			[string]
			$ProgId,

			[Parameter(
				Mandatory = $true,
				Position = 1
			)]
			[string]
			$Extension
		)

		# Due to "Set-StrictMode -Version Latest" we have to check everything
		if ((Test-Path -Path "HKLM:\SOFTWARE\Classes\$Extension") -and (Get-ItemProperty -Path "HKLM:\SOFTWARE\Classes\$Extension" -Name "(default)" -ErrorAction Ignore))
		{
			if ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Classes\$Extension" -Name "(default)" -ErrorAction Ignore)."(default)")
			{
				# Save possible ProgIds history with extension
				New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts" -Name "$($ProgID)_$($Extension)" -PropertyType DWord -Value 0 -Force
			}
		}

		$Name = "{0}_$($Extension)" -f (Split-Path -Path $ProgId -Leaf)
		New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts" -Name $Name -PropertyType DWord -Value 0 -Force

		if ("$($ProgID)_$($Extension)" -ne $Name)
		{
			New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts" -Name "$($ProgID)_$($Extension)" -PropertyType DWord -Value 0 -Force
		}

		# If ProgId doesn't exist set the specified ProgId for the extensions
		# Due to "Set-StrictMode -Version Latest" we have to check everything
		if (-not (Get-Variable -Name ProgId -ErrorAction Ignore))
		{
			if (-not (Test-Path -Path "HKCU:\Software\Classes\$Extension"))
			{
				New-Item -Path "HKCU:\Software\Classes\$Extension" -Force
			}
			New-ItemProperty -Path "HKCU:\Software\Classes\$Extension" -Name "(default)" -PropertyType String -Value $ProgId -Force
		}

		# Set the specified ProgId in the possible options for the assignment
		if (-not (Test-Path -Path "HKCU:\Software\Classes\$Extension\OpenWithProgids"))
		{
			New-Item -Path "HKCU:\Software\Classes\$Extension\OpenWithProgids" -Force
		}
		New-ItemProperty -Path "HKCU:\Software\Classes\$Extension\OpenWithProgids" -Name $ProgId -PropertyType None -Value ([byte[]]@()) -Force

		# Set the system ProgId to the extension parameters for the File Explorer to the possible options for the assignment, and if absent set the specified ProgId
		# Due to "Set-StrictMode -Version Latest" we have to check everything
		if (Get-Variable -Name OrigProgID -ErrorAction Ignore)
		{
			if (-not (Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$Extension\OpenWithProgids"))
			{
				New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$Extension\OpenWithProgids" -Force
			}
			New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$Extension\OpenWithProgids" -Name $OrigProgID -PropertyType None -Value ([byte[]]@()) -Force
		}

		if (-not (Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$Extension\OpenWithProgids"))
		{
			New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$Extension\OpenWithProgids" -Force
		}
		New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$Extension\OpenWithProgids" -Name $ProgID -PropertyType None -Value ([byte[]]@()) -Force

		# Removing the UserChoice key
		[RegistryUtils.Action]::DeleteKey([Microsoft.Win32.RegistryHive]::CurrentUser, "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$Extension\UserChoice")

		# Setting parameters in UserChoice. The key is being autocreated
		if (-not (Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$Extension\UserChoice"))
		{
			New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$Extension\UserChoice" -Force
		}
		New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$Extension\UserChoice" -Name ProgId -PropertyType String -Value $ProgID -Force

		# Getting a hash based on the time of the section's last modification. After creating and setting the first parameter
		$ProgHash = Get-Hash -ProgId $ProgId -Extension $Extension -SubKey "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$Extension\UserChoice"

		if (-not (Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$Extension\UserChoice"))
		{
			New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$Extension\UserChoice" -Force
		}
		New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$Extension\UserChoice" -Name Hash -PropertyType String -Value $ProgHash -Force

		# Setting a ban on changing the UserChoice section
		$OpenSubKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey("Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$Extension\UserChoice", "ReadWriteSubTree", "TakeOwnership")
		if ($OpenSubKey)
		{
			$Acl = [System.Security.AccessControl.RegistrySecurity]::new()
			# Get current user SID
			$UserSID = (Get-CimInstance -ClassName Win32_UserAccount | Where-Object -FilterScript {$_.Name -eq $env:USERNAME}).SID
			$Acl.SetSecurityDescriptorSddlForm("O:$UserSID`G:$UserSID`D:AI(D;;DC;;;$UserSID)")
			$OpenSubKey.SetAccessControl($Acl)
			$OpenSubKey.Close()
		}
	}

	function Write-AdditionalKeys
	{
		Param
		(
			[Parameter(
				Mandatory = $true,
				Position = 0
			)]
			[string]
			$ProgId,

			[Parameter(
				Mandatory = $true,
				Position = 1
			)]
			[string]
			$Extension
		)

		# If there is the system extension ProgId, write it to the already configured by default
		# Due to "Set-StrictMode -Version Latest" we have to check everything
		if ((Test-Path -Path "HKLM:\SOFTWARE\Classes\$Extension") -and (Get-ItemProperty -Path "HKLM:\SOFTWARE\Classes\$Extension" -Name "(default)" -ErrorAction Ignore))
		{
			if ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Classes\$Extension" -Name "(default)" -ErrorAction Ignore)."(default)")
			{
				if (-not (Test-Path -Path Registry::HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\FileAssociations\ProgIds))
				{
					New-Item -Path Registry::HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\FileAssociations\ProgIds -Force
				}
				New-ItemProperty -Path Registry::HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\FileAssociations\ProgIds -Name "_$($Extension)" -PropertyType DWord -Value 1 -Force
			}
		}

		# Setting 'NoOpenWith' for all registered the extension ProgIDs
		[psobject]$OpenSubkey = Get-Item -Path "Registry::HKEY_CLASSES_ROOT\$Extension\OpenWithProgids" -ErrorAction Ignore | Select-Object -ExpandProperty Property

		if ($OpenSubkey)
		{
			foreach ($AppxProgID in ($OpenSubkey | Where-Object -FilterScript {$_ -match "AppX"}))
			{
				# If an app is installed
				if (Get-ItemPropertyValue -Path "HKCU:\Software\Classes\$AppxProgID\Shell\open" -Name PackageId)
				{
					# If the specified ProgId is equal to UWP installed ProgId
					if ($ProgId -eq $AppxProgID)
					{
						# Remove association limitations for this UWP apps
						Remove-ItemProperty -Path "HKCU:\Software\Classes\$AppxProgID" -Name NoOpenWith -Force -ErrorAction Ignore
						Remove-ItemProperty -Path "HKCU:\Software\Classes\$AppxProgID" -Name NoStaticDefaultVerb -Force -ErrorAction Ignore
					}
					else
					{
						New-ItemProperty -Path "HKCU:\Software\Classes\$AppxProgID" -Name NoOpenWith -PropertyType String -Value "" -Force
					}
				}
			}
		}

		# Due to "Set-StrictMode -Version Latest" we have to check everything
		if (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\KindMap -Name $Extension -ErrorAction Ignore)
		{
			$picture = (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\KindMap -Name $Extension -ErrorAction Ignore).$Extension
		}
		# Due to "Set-StrictMode -Version Latest" we have to check everything
		if ((Test-Path -Path HKLM:\SOFTWARE\Classes\PBrush\CLSID) -and (Get-ItemProperty -Path HKLM:\SOFTWARE\Classes\PBrush\CLSID -Name "(default)" -ErrorAction Ignore))
		{
			$PBrush = (Get-ItemProperty -Path HKLM:\SOFTWARE\Classes\PBrush\CLSID -Name "(default)" -ErrorAction Ignore)."(default)"
		}

		# Due to "Set-StrictMode -Version Latest" we have to check everything
		if (Get-Variable -Name picture -ErrorAction Ignore)
		{
			if (($picture -eq "picture") -and $PBrush)
			{
				New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts -Name "PBrush_$($Extension)" -PropertyType DWord -Value 0 -Force
			}
		}
	}

	function Get-Hash
	{
		[CmdletBinding()]
		[OutputType([string])]
		Param
		(
			[Parameter(
				Mandatory = $true,
				Position = 0
			)]
			[string]
			$ProgId,

			[Parameter(
				Mandatory = $true,
				Position = 1
			)]
			[string]
			$Extension,

			[Parameter(
				Mandatory = $true,
				Position = 2
			)]
			[string]
			$SubKey
		)

		$PatentHash = @'
using System;

namespace FileAssoc
{
	public static class PatentHash
	{
		public static uint[] WordSwap(byte[] a, int sz, byte[] md5)
		{
			if (sz < 2 || (sz & 1) == 1) {
				throw new ArgumentException(String.Format("Invalid input size: {0}", sz), "sz");
			}

			unchecked {
				uint o1 = 0;
				uint o2 = 0;
				int ta = 0;
				int ts = sz;
				int ti = ((sz - 2) >> 1) + 1;

				uint c0 = (BitConverter.ToUInt32(md5, 0) | 1) + 0x69FB0000;
				uint c1 = (BitConverter.ToUInt32(md5, 4) | 1) + 0x13DB0000;

				for (uint i = (uint)ti; i > 0; i--) {
					uint n = BitConverter.ToUInt32(a, ta) + o1;
					ta += 8;
					ts -= 2;

					uint v1 = 0x79F8A395 * (n * c0 - 0x10FA9605 * (n >> 16)) + 0x689B6B9F * ((n * c0 - 0x10FA9605 * (n >> 16)) >> 16);
					uint v2 = 0xEA970001 * v1 - 0x3C101569 * (v1 >> 16);
					uint v3 = BitConverter.ToUInt32(a, ta - 4) + v2;
					uint v4 = v3 * c1 - 0x3CE8EC25 * (v3 >> 16);
					uint v5 = 0x59C3AF2D * v4 - 0x2232E0F1 * (v4 >> 16);

					o1 = 0x1EC90001 * v5 + 0x35BD1EC9 * (v5 >> 16);
					o2 += o1 + v2;
				}

				if (ts == 1) {
					uint n = BitConverter.ToUInt32(a, ta) + o1;

					uint v1 = n * c0 - 0x10FA9605 * (n >> 16);
					uint v2 = 0xEA970001 * (0x79F8A395 * v1 + 0x689B6B9F * (v1 >> 16)) - 0x3C101569 * ((0x79F8A395 * v1 + 0x689B6B9F * (v1 >> 16)) >> 16);
					uint v3 = v2 * c1 - 0x3CE8EC25 * (v2 >> 16);

					o1 = 0x1EC90001 * (0x59C3AF2D * v3 - 0x2232E0F1 * (v3 >> 16)) + 0x35BD1EC9 * ((0x59C3AF2D * v3 - 0x2232E0F1 * (v3 >> 16)) >> 16);
					o2 += o1 + v2;
				}

				uint[] ret = new uint[2];
				ret[0] = o1;
				ret[1] = o2;
				return ret;
			}
		}

		public static uint[] Reversible(byte[] a, int sz, byte[] md5)
		{
			if (sz < 2 || (sz & 1) == 1) {
				throw new ArgumentException(String.Format("Invalid input size: {0}", sz), "sz");
			}

			unchecked {
				uint o1 = 0;
				uint o2 = 0;
				int ta = 0;
				int ts = sz;
				int ti = ((sz - 2) >> 1) + 1;

				uint c0 = BitConverter.ToUInt32(md5, 0) | 1;
				uint c1 = BitConverter.ToUInt32(md5, 4) | 1;

				for (uint i = (uint)ti; i > 0; i--) {
					uint n = (BitConverter.ToUInt32(a, ta) + o1) * c0;
					n = 0xB1110000 * n - 0x30674EEF * (n >> 16);
					ta += 8;
					ts -= 2;

					uint v1 = 0x5B9F0000 * n - 0x78F7A461 * (n >> 16);
					uint v2 = 0x1D830000 * (0x12CEB96D * (v1 >> 16) - 0x46930000 * v1) + 0x257E1D83 * ((0x12CEB96D * (v1 >> 16) - 0x46930000 * v1) >> 16);
					uint v3 = BitConverter.ToUInt32(a, ta - 4) + v2;

					uint v4 = 0x16F50000 * c1 * v3 - 0x5D8BE90B * (c1 * v3 >> 16);
					uint v5 = 0x2B890000 * (0x96FF0000 * v4 - 0x2C7C6901 * (v4 >> 16)) + 0x7C932B89 * ((0x96FF0000 * v4 - 0x2C7C6901 * (v4 >> 16)) >> 16);

					o1 = 0x9F690000 * v5 - 0x405B6097 * (v5 >> 16);
					o2 += o1 + v2;
				}

				if (ts == 1) {
					uint n = BitConverter.ToUInt32(a, ta) + o1;

					uint v1 = 0xB1110000 * c0 * n - 0x30674EEF * ((c0 * n) >> 16);
					uint v2 = 0x5B9F0000 * v1 - 0x78F7A461 * (v1 >> 16);
					uint v3 = 0x1D830000 * (0x12CEB96D * (v2 >> 16) - 0x46930000 * v2) + 0x257E1D83 * ((0x12CEB96D * (v2 >> 16) - 0x46930000 * v2) >> 16);
					uint v4 = 0x16F50000 * c1 * v3 - 0x5D8BE90B * ((c1 * v3) >> 16);
					uint v5 = 0x96FF0000 * v4 - 0x2C7C6901 * (v4 >> 16);
					o1 = 0x9F690000 * (0x2B890000 * v5 + 0x7C932B89 * (v5 >> 16)) - 0x405B6097 * ((0x2B890000 * v5 + 0x7C932B89 * (v5 >> 16)) >> 16);
					o2 += o1 + v2;
				}

				uint[] ret = new uint[2];
				ret[0] = o1;
				ret[1] = o2;
				return ret;
			}
		}

		public static long MakeLong(uint left, uint right) {
			return (long)left << 32 | (long)right;
		}
	}
}
'@

		if ( -not ('FileAssoc.PatentHash' -as [type]))
		{
			Add-Type -TypeDefinition $PatentHash
		}

		function Get-KeyLastWriteTime ($SubKey)
		{
			$LM = [RegistryUtils.Action]::GetLastModified([Microsoft.Win32.RegistryHive]::CurrentUser,$SubKey)
			$FT = ([DateTime]::New($LM.Year, $LM.Month, $LM.Day, $LM.Hour, $LM.Minute, 0, $LM.Kind)).ToFileTime()

			return [string]::Format("{0:x8}{1:x8}", $FT -shr 32, $FT -band [uint32]::MaxValue)
		}

		function Get-DataArray
		{
			[OutputType([array])]

			# Secret static string stored in %SystemRoot%\SysWOW64\shell32.dll
			$userExperience        = "User Choice set via Windows User Experience {D18B6DD5-6124-4341-9318-804003BAFA0B}"
			# Get user SID
			$userSid               = (Get-CimInstance -ClassName Win32_UserAccount | Where-Object -FilterScript {$_.Name -eq $env:USERNAME}).SID
			$KeyLastWriteTime      = Get-KeyLastWriteTime -SubKey $SubKey
			$baseInfo              = ("{0}{1}{2}{3}{4}" -f $Extension, $userSid, $ProgId, $KeyLastWriteTime, $userExperience).ToLowerInvariant()
			$StringToUTF16LEArray  = [System.Collections.ArrayList]@([System.Text.Encoding]::Unicode.GetBytes($baseInfo))
			$StringToUTF16LEArray += (0,0)

			return $StringToUTF16LEArray
		}

		function Get-PatentHash
		{
			[OutputType([string])]
			param
			(
				[Parameter(Mandatory = $true)]
				[byte[]]
				$A,

				[Parameter(Mandatory = $true)]
				[byte[]]
				$MD5
			)

			$Size = $A.Count
			$ShiftedSize = ($Size -shr 2) - ($Size -shr 2 -band 1) * 1

			[uint32[]]$A1 = [FileAssoc.PatentHash]::WordSwap($A, [int]$ShiftedSize, $MD5)
			[uint32[]]$A2 = [FileAssoc.PatentHash]::Reversible($A, [int]$ShiftedSize, $MD5)

			$Ret = [FileAssoc.PatentHash]::MakeLong($A1[1] -bxor $A2[1], $A1[0] -bxor $A2[0])

			return [System.Convert]::ToBase64String([System.BitConverter]::GetBytes([Int64]$Ret))
		}

		$DataArray = Get-DataArray
		$DataMD5   = [System.Security.Cryptography.HashAlgorithm]::Create("MD5").ComputeHash($DataArray)
		$Hash      = Get-PatentHash -A $DataArray -MD5 $DataMD5

		return $Hash
	}
	#endregion functions

	if ($ProgramPath)
	{
		if (-not (Test-Path -Path "HKCU:\Software\Classes\$ProgId\shell\open\command"))
		{
			New-Item -Path "HKCU:\Software\Classes\$ProgId\shell\open\command" -Force
		}
		New-ItemProperty -Path "HKCU:\Software\Classes\$ProgId\shell\open\command" -Name "(Default)" -PropertyType String -Value "`"$ProgramPath`" `"%1`"" -Force

		$FileNameEXE = Split-Path -Path $ProgramPath -Leaf
		if (-not (Test-Path -Path "HKCU:\Software\Classes\Applications\$FileNameEXE\shell\open\command"))
		{
			New-Item -Path "HKCU:\Software\Classes\Applications\$FileNameEXE\shell\open\command" -Force
		}
		New-ItemProperty -Path "HKCU:\Software\Classes\Applications\$FileNameEXE\shell\open\command" -Name "(Default)" -PropertyType String -Value "`"$ProgramPath`" `"%1`"" -Force
	}

	if ($Icon)
	{
		if (-not (Test-Path -Path "HKCU:\Software\Classes\$ProgId\DefaultIcon"))
		{
			New-Item -Path "HKCU:\Software\Classes\$ProgId\DefaultIcon" -Force
		}
		New-ItemProperty -Path "HKCU:\Software\Classes\$ProgId\DefaultIcon" -Name "(default)" -PropertyType String -Value $Icon -Force
	}

	Write-Information -MessageData "" -InformationAction Continue
	Write-Verbose -Message Patient -Verbose

	# If the file extension specified configure the extension
	Write-ExtensionKeys -ProgId $ProgId -Extension $Extension

	# Setting additional parameters to comply with the requirements before configuring the extension
	Write-AdditionalKeys -ProgId $ProgId -Extension $Extension

	# Refresh the desktop icons
	$UpdateExplorer = @{
		Namespace        = "WinAPI"
		Name             = "UpdateExplorer"
		Language         = "CSharp"
		MemberDefinition = @"
[DllImport("shell32.dll", CharSet = CharSet.Auto, SetLastError = false)]
private static extern int SHChangeNotify(int eventId, int flags, IntPtr item1, IntPtr item2);
public static void Refresh()
{
	// Update desktop icons
	SHChangeNotify(0x8000000, 0x1000, IntPtr.Zero, IntPtr.Zero);
}
"@
	}
	if (-not ("WinAPI.UpdateExplorer" -as [type]))
	{
		Add-Type @UpdateExplorer
	}

	[WinAPI.UpdateExplorer]::Refresh()
}

foreach ($Extension in $Extensions)
{
	# Register Notepad++, calculate hash, and associate with an extension with the "How do you want to open this" pop-up hidden
	Set-Association -ProgramPath $Path -Extension $Extension -Icon "$Path,0"
}
