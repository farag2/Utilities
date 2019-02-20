# PSScriptAnalyzer
Install-PackageProvider -Name NuGet -Force
Remove-Item -Path $env:APPDATA\NuGet -Recurse -Force
Save-Module -Name PSScriptAnalyzer -Path D:\
Invoke-ScriptAnalyzer -Path "D:\Программы\Прочее\ps1\Win 10.ps1"

# Перерегистрация всех UWP-приложений
(Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\InboxApplications | Get-ItemProperty).Path | Add-AppxPackage -Register -DisableDevelopmentMode

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
$acl = $k.GetAccessControl()
$null = $acl.SetAccessRuleProtection($false,$true)
$rule = New-Object System.Security.AccessControl.RegistryAccessRule ($ParentACL.Owner,'FullControl','Allow')
$null = $acl.SetAccessRule($rule)
$rule = New-Object System.Security.AccessControl.RegistryAccessRule ($ParentACL.Owner,'SetValue','Deny')
$null = $acl.RemoveAccessRule($rule)
$null = $k.SetAccessControl($acl)

# Скрыть окно
Start-Process -FilePath notepad.exe
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

# Найти диски, не подключенные через USB и не являющиеся загрузочными, исключая диски с пустыми буквами (исключаются внешние жесткие диски)
(Get-Disk | Where-Object {$_.BusType -ne "USB" -and $_.IsBoot -eq $false} | Get-Partition | Get-Volume | Where-Object {$_.DriveLetter -ne $null}).DriveLetter + ':\'
# Найти диски, не являющиеся загрузочными, исключая диски с пустыми буквами (не исключаются внешние жесткие диски)
(Get-Disk | Where-Object {$_.IsBoot -eq $false} | Get-Partition | Get-Volume | Where-Object {$_.DriveLetter -ne $null}).DriveLetter + ':\'
# Найти первый диск, подключенный через USB, исключая диски с пустыми буквами
(Get-Disk | Where-Object {$_.BusType -eq "USB"} | Get-Partition | Get-Volume | Where-Object {$_.DriveLetter -ne $null}).DriveLetter + ':\' | Select-Object -First 1

# Возвратить полный путь с 'Программы\Прочее\reg\Start.reg' на диске, подключенным через USB
filter Get-FirstResolvedPath
{
	(Get-Disk | Where-Object {$_.BusType -eq "USB"} | Get-Partition | Get-Volume | Where-Object {$null -ne $_.DriveLetter}).DriveLetter + ':\' | Join-Path -ChildPath $_ -Resolve -ErrorAction SilentlyContinue
}
'Программы\Прочее\reg\Start.reg' | Get-FirstResolvedPath

# Добавление доменов в hosts
$hostfile = "$env:SystemRoot\System32\drivers\etc\hosts"
$domains = @("site.com","site2.com")
Foreach ($hostentry in $domains)
{
	IF (!(Get-Content -Path $hostfile | Select-String "0.0.0.0 `t $hostentry"))
	{
		Add-content -Path $hostfile -Value "0.0.0.0 `t $hostentry"
	}
}

# Отделить название от пути
Split-Path -Path file.ext -Leaf
# Отделить путь от названия
Split-Path -Path file.ext -Parent
# Отделить от пути название последней папки
Get-Item -Path file.ext | Split-Path -Parent | Split-Path -Parent | Split-Path -Leaf

# Список сетевых дисков
Get-SmbMapping | Select-Object LocalPath, RemotePath

# Версия ОС
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows nt\CurrentVersion" | Select-Object -Property ProductName, EditionID, ReleaseID,
@{Name = "Build"; Expression = {"$($_.CurrentBuild).$($_.UBR)"}},
@{Name = "InstalledUTC"; Expression = {([datetime]"1/1/1601").AddTicks($_.InstallTime)}},
@{Name = "Computername"; Expression = {$env:COMPUTERNAME}}

# Проверить тип запуска службы
IF ((Get-Service -ServiceName $services).StartType -ne "Disabled")
{
	Stop-Service -ServiceName $services -Force
	Set-Service -ServiceName $services -StartupType Disabled
}

# Получить события из журналов событий и файлов журналов отслеживания событий
<#
LogAlways 0
Critical 1
Error 2
Warning 3
Informational 4
Verbose 5
#>
Get-WinEvent -LogName system | Where-Object {$_.ID -eq 50106} | Select-Object -Property *
Get-WinEvent -LogName system | Where-Object {$_.ID -like '1001' -and $_.source -like 'bugcheck'} | Select-Object -Property *

Get-WinEvent -FilterHashtable @{LogName="System";level="1"}
Get-WinEvent -FilterHashtable @{LogName="System"} | Where-Object -FilterScript {($_.Level -eq 2) -or ($_.Level -eq 3)}

Get-WinEvent -LogName Application | Where-Object {$_.ProviderName -match 'Windows Error*'} | Select-Object TimeCreated, Message | Format-Table -AutoSize -Wrap
Get-WinEvent -LogName System | Where-Object {$_.LevelDisplayName -match 'Критическая' -or $_.LevelDisplayName -match 'Ошибка'} | Select-Object TimeCreated, ID, LevelDisplayName, Message | Sort-Object TimeCreated -Descending | Select-Object -First 10 | Format-Table -AutoSize -Wrap

# Настройка и проверка исключений Защитника Windows
Add-MpPreference -ExclusionProcess D:\folder\file.ext
Add-MpPreference -ExclusionPath D:\folder
Add-MpPreference -ExclusionExtension .ext

# Создание ярлыка
enum WindowStyle
{
	# стандартный размер окна
	Normal	= 4
	# развернутый вид (максимизировано)
	Maximized	= 3
	# свернутое окно (минимизировано)
	Minimized	= 7
}

function Shortcut
{
	[CmdletBinding()]
	param
	(
		# Аргументы командной строки объекта, для которого создаётся ярлык
		[Parameter(ValueFromPipelineByPropertyName)]
		[string]
		$Arguments,

		# Описание объекта
		[Parameter(ValueFromPipelineByPropertyName)]
		[string]
		$Description,

		# Горячие клавиши для запуска ярлыка
		[Parameter(ValueFromPipelineByPropertyName)]
		[string]
		$Hotkey,

		# Полное имя иконки для ярлыка
		[Parameter(ValueFromPipelineByPropertyName)]
		[ValidateScript( {Test-Path $_} )]
		[string]
		$IconLocation,

		# Полный путь объекта для которого создаётся ярлык
		[Parameter(Mandatory, ValueFromPipelineByPropertyName)]
		[ValidateScript( {Test-Path $_} )]
		[string]
		$TargetPath,

		# Путь создаваемого ярлыка
		[Parameter(Mandatory, ValueFromPipelineByPropertyName)]
		[string]
		$ShortcutPath,

		# Стиль окна объекта запускаемого ярлыком
		[Parameter(ValueFromPipelineByPropertyName)]
		[WindowStyle]
		$WindowStyle,

		# Рабочая директория для объекта запускаемого ярлыком
		[Parameter(ValueFromPipelineByPropertyName)]
		[ValidateScript( {Test-Path $_} )]
		[string]
		$WorkingDirectory
	)

	begin
	{
		$shell = New-Object -comObject Wscript.Shell
	}

	process
	{
		$shortcut = $shell.CreateShortcut($ShortcutPath)

		$shortcut.Arguments		= $Arguments
		$shortcut.Description	= $Description
		$shortcut.Hotkey		= $Hotkey
		$shortcut.TargetPath	= $TargetPath
		$shortcut.WorkingDirectory	= $WorkingDirectory

		IF ($WindowStyle)
		{
			$shortcut.WindowStyle = $WindowStyle
		}
		IF ($IconLocation)
		{
			$shortcut.IconLocation = $IconLocation
		}

		$shortcut.Save()
	}
}

<# Пример
$shortcut = [PSCustomObject]@{
	TargetPath   = "C:\Windows\System32\cmd.exe"
	ShortcutPath = ".\dir.lnk"
	Arguments    = "/k dir /b"
	WindowStyle  = "Maximized"
}
$shortcut | New-Shortcut
#>

# Скачать файл
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$HT = @{
	Uri = "https://site.com/1.js"
	OutFile = "D:\1.js"
	UseBasicParsing = [switch]::Present
	Verbose = [switch]::Present
}
Invoke-WebRequest @HT

# Передача больших файлов по медленным и нестабильным сетям
Import-Module BitsTransfer # Нагружает диск
Start-BitsTransfer -Source $url -Destination $output
# Start-BitsTransfer -Source $url -Destination $output -Asynchronous

# Скачать и отобразить текстовый файл
(Invoke-WebRequest -Uri "https://site.com/1.js" -OutFile D:\1.js -PassThru).Content

# Прочитать содержимое текстового файла
(Invoke-WebRequest -Uri "https://site.com/1.js").Content

# Подсчет времени
$start_time = Get-Date
Write-Output "Time taken: $((Get-Date).Subtract($start_time).Milliseconds) second(s)"

# Разархивировать архив
$HT = @{
	Path = "D:\1.zip"
	DestinationPath = "D:\1"
	Force = [switch]::Present
	Verbose = [switch]::Present
}
Expand-Archive @HT

# Обновить переменные среды
IF (!("Win32.NativeMethods" -as [Type]))
{
	Add-Type -Namespace Win32 -Name NativeMethods -MemberDefinition @"
	[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
	public static extern IntPtr SendMessageTimeout(
		IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam,
		uint fuFlags, uint uTimeout, out UIntPtr lpdwResult
	);
"@
}
$HWND_BROADCAST = [IntPtr] 0xffff;
$WM_SETTINGCHANGE = 0x1a;
$SMTO_ABORTIFHUNG = 0x2
$result = [UIntPtr]::Zero

[Win32.Nativemethods]::SendMessageTimeout($HWND_BROADCAST, $WM_SETTINGCHANGE, [UIntPtr]::Zero, "Environment", $SMTO_ABORTIFHUNG, 5000, [ref] $result);