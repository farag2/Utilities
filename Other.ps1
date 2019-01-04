# PSScriptAnalyzer
Install-PackageProvider -Name NuGet -Force
Remove-Item $env:APPDATA\NuGet -Recurse -Force
Save-Module -Name PSScriptAnalyzer -Path D:\
Invoke-ScriptAnalyzer "D:\Программы\Прочее\ps1\Win 10.ps1"

# Перерегистрация всех UWP-приложений
((Get-ChildItem HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\InboxApplications) | Get-ItemProperty).Path | Add-AppxPackage -Register -DisableDevelopmentMode

# Домен
New-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters -Name AllowSingleLabelDnsDomain -Value 1 -Force

# Установка приложений из Магазина
https://store.rg-adguard.net URL (link) и Retail
https://www.microsoft.com/store/productId/9nmjcx77qkpx
Add-AppxPackage -Path "D:\Microsoft.LanguageExperiencePackru-ru_17134.5.13.0_neutral__8wekyb3d8bbwe.Appx"

# Показать сообщения о блокировке изменений папок приложениями посредством управляемого доступа
(Get-WinEvent -LogName "Microsoft-Windows-Windows Defender/Operational" | Where-Object {$_.ID -eq "1123" -or $_.ID -eq "1124" -or $_.ID -eq "1127"}).Message

# Стать владельцем ключа в Реестре
$ParentACL = Get-Acl -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.txt"
$k = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey("Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.txt\UserChoice",'ReadWriteSubTree','TakeOwnership')
$acl  = $k.GetAccessControl()
$null = $acl.SetAccessRuleProtection($false,$true)
$rule = New-Object System.Security.AccessControl.RegistryAccessRule ($ParentACL.Owner,'FullControl','Allow')
$null = $acl.SetAccessRule($rule)
$rule = New-Object System.Security.AccessControl.RegistryAccessRule ($ParentACL.Owner,'SetValue','Deny')
$null = $acl.RemoveAccessRule($rule)
$null = $k.SetAccessControl($acl)

# Скрыть окно
Start-Process notepad.exe
$WindowCode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
$AsyncWindow = Add-Type -MemberDefinition $WindowCode -Name Win32ShowWindowAsync -namespace Win32Functions -PassThru
$hwnd0 = (Get-Process -Name notepad)[0].MainWindowHandle
$null = $AsyncWindow::ShowWindowAsync($hwnd0, 0)

# Стать владельцем ключа в Реестре
function ElevatePrivileges
{
	param($Privilege)
	$Definition = @"
	using System;
	using System.Runtime.InteropServices;
	public class AdjPriv
	{
		[DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
		internal static extern bool AdjustTokenPrivileges(IntPtr htok, bool disall, ref TokPriv1Luid newst, int len, IntPtr prev, IntPtr rele);
		[DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
		internal static extern bool OpenProcessToken(IntPtr h, int acc, ref IntPtr phtok);
		[DllImport("advapi32.dll", SetLastError = true)]
		internal static extern bool LookupPrivilegeValue(string host, string name, ref long pluid);
		[StructLayout(LayoutKind.Sequential, Pack = 1)]
		internal struct TokPriv1Luid
		{
			public int Count;
			public long Luid;
			public int Attr;
		}
		internal const int SE_PRIVILEGE_ENABLED = 0x00000002;
		internal const int TOKEN_QUERY = 0x00000008;
		internal const int TOKEN_ADJUST_PRIVILEGES = 0x00000020;
		public static bool EnablePrivilege(long processHandle, string privilege)
		{
			bool retVal;
			TokPriv1Luid tp;
			IntPtr hproc = new IntPtr(processHandle);
			IntPtr htok = IntPtr.Zero;
			retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);
			tp.Count = 1;
			tp.Luid = 0;
			tp.Attr = SE_PRIVILEGE_ENABLED;
			retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);
			retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
			return retVal;
		}
	}
"@
	$ProcessHandle = (Get-Process -id $pid).Handle
	$type = Add-Type $definition -PassThru
	$type[0]::EnablePrivilege($processHandle, $Privilege)
}

function TakeownRegistry($key)
{
	switch ($key.split('\')[0])
	{
		"HKCR"
		{
			$reg = [Microsoft.Win32.Registry]::ClassesRoot
			$key = $key.substring(18)
		}
		"HKCU"
		{
			$reg = [Microsoft.Win32.Registry]::CurrentUser
			$key = $key.substring(18)
		}
		"HKLM"
		{
			$reg = [Microsoft.Win32.Registry]::LocalMachine
			$key = $key.substring(19)
		}
		"HKU"
		{
			$reg = [Microsoft.Win32.Registry]::Users
			$key = $key.substring(20)
		}
		"HKCC"
		{
			$reg = [Microsoft.Win32.Registry]::CurrentConfig
			$key = $key.substring(21)
		}
	}
    $admins = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544")
    $admins = $admins.Translate([System.Security.Principal.NTAccount])
    $key = $reg.OpenSubKey($key, "ReadWriteSubTree", "TakeOwnership")
    $acl = $key.GetAccessControl()
    $acl.SetOwner($admins)
    $key.SetAccessControl($acl)
    $acl = $key.GetAccessControl()
    $rule = New-Object System.Security.AccessControl.RegistryAccessRule($admins, "FullControl", "Allow")
    $acl.SetAccessRule($rule)
    $key.SetAccessControl($acl)
}
do {} until (ElevatePrivileges SeTakeOwnershipPrivilege)
TakeownRegistry ("HKLM\SOFTWARE\Microsoft\Windows Defender\Spynet")

# Включение в Планировщике задач удаление устаревших обновлений Office, кроме Office 2019
$action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument @"
`$getservice = Get-Service -Name wuauserv
`$getservice.WaitForStatus('Stopped', '01:00:00')
Start-Process -FilePath D:\Программы\Прочее\Office_task.bat
"@
$trigger = New-ScheduledTaskTrigger -Weekly -At 9am -DaysOfWeek Thursday -WeeksInterval 4
$settings = New-ScheduledTaskSettingsSet -Compatibility Win8 -StartWhenAvailable
$principal = New-ScheduledTaskPrincipal -UserID System -RunLevel Highest
$params = @{
"TaskName"	= "Office"
"Action"	= $action
"Trigger"	= $trigger
"Settings"	= $settings
"Principal"	= $principal
}
Register-ScheduledTask @Params -Force

# Включение в Планировщике задач очистки папки %SYSTEMROOT%\SoftwareDistribution\Download
$action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument @"
`$getservice = Get-Service -Name wuauserv
`$getservice.WaitForStatus('Stopped', '01:00:00')
Get-ChildItem -Path $env:SystemRoot\SoftwareDistribution\Download -Recurse -Force | Remove-Item -Recurse -Force
"@
$trigger = New-ScheduledTaskTrigger -Weekly -At 9am -DaysOfWeek Thursday -WeeksInterval 4
$settings = New-ScheduledTaskSettingsSet -Compatibility Win8 -StartWhenAvailable
$principal = New-ScheduledTaskPrincipal -UserID System -RunLevel Highest
$params = @{
"TaskName"	= "SoftwareDistribution"
"Action"	= $action
"Trigger"	= $trigger
"Settings"	= $settings
"Principal"	= $principal
}
Register-ScheduledTask @Params -Force

# Включение в Планировщике задач всплывающего окошка с сообщением о перезагрузке
$action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument @"
-WindowStyle Hidden `
Add-Type -AssemblyName System.Windows.Forms
`$global:balmsg = New-Object System.Windows.Forms.NotifyIcon
`$path = (Get-Process -Id `$pid).Path
`$balmsg.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon(`$path)
`$balmsg.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning
`$balmsg.BalloonTipText = 'ПК перезагрузится через 1 минуту'
`$balmsg.BalloonTipTitle = 'Внимание'
`$balmsg.Visible = `$true
`$balmsg.ShowBalloonTip(60000)
Start-Sleep -s 60
Restart-Computer
"@
$trigger = New-ScheduledTaskTrigger -Weekly -At 10am -DaysOfWeek Thursday -WeeksInterval 4
$settings = New-ScheduledTaskSettingsSet -Compatibility Win8 -StartWhenAvailable
$principal = New-ScheduledTaskPrincipal -UserID $env:USERNAME -RunLevel Highest
$params = @{
"TaskName"	= "Reboot"
"Action"	= $action
"Trigger"	= $trigger
"Settings"	= $settings
"Principal"	= $principal
}
Register-ScheduledTask @Params -Force

# Найти  диск, не подключенный через USB и не являющийся загрузочным (исключаются внешние жесткие диски)
(Get-Disk | Where-Object {$_.BusType -ne "USB" -and $_.IsBoot -eq $false} | Get-Partition | Get-Volume).DriveLetter | ForEach-Object {$_ + ':\'}
# Найти диск, не являющийся загрузочным (не исключаются внешние жесткие диски)
(Get-Disk | Where-Object {$_.IsBoot -eq $false} | Get-Partition | Get-Volume).DriveLetter | ForEach-Object {$_ + ':\'}
# Найти первый диск, подключенный через USB
(Get-Disk | Where-Object {$_.BusType -eq "USB"} | Get-Partition | Get-Volume).DriveLetter | ForEach-Object {$_ + ':\'} | Select-Object -First 1

# Возвратить путь с 'Программы\Прочее\reg\Start.reg' на диске, подключенным через USB
filter Get-FirstResolvedPath
{
	(Get-Disk | Where-Object {$_.BusType -eq "USB"} | Get-Partition | Get-Volume).DriveLetter | ForEach-Object {$_ + ':\'} | Join-Path -ChildPath $_ -Resolve -ErrorAction SilentlyContinue | Select-Object -First 1
}
'Программы\Прочее\reg\Start.reg' | Get-FirstResolvedPath

# Добавление доменов в hosts
$hostfile = "$env:SystemRoot\System32\drivers\etc\hosts"
$domains = @("site.com","site2.com")
Foreach ($hostentry in $domains)
{
    IF (!(Get-Content $hostfile | Select-String "0.0.0.0 `t $hostentry"))
    {
        Add-content -path $hostfile -value "0.0.0.0 `t $hostentry"
    }
}

# Отделить название от пути
Split-Path file.ext -Leaf
# Отделить путь от названия
Split-Path file.ext -Parent
# Отделить от пути название последней папки
Get-Item file.ext | Split-Path -Parent | Split-Path -Parent | Split-Path -Leaf

# Список сетевых дисков
Get-SmbMapping | Select-Object LocalPath, RemotePath

# Включить Управляемый доступ к папкам
Set-MpPreference -EnableControlledFolderAccess Enabled
# Добавить защищенную папку
$drives = Get-Disk | Where-Object {$_.BusType -ne "USB" -and $_.IsBoot -eq $false}
IF ($drives)
{
	$drives = ($drives | Get-Partition | Get-Volume).DriveLetter | ForEach-Object {$_ + ':\'}
	Foreach ($drive In $drives)
	{
		Add-MpPreference -ControlledFolderAccessProtectedFolders $drive
	}
}