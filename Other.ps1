# PSScriptAnalyzer
Install-PackageProvider -Name NuGet -Force
Install-Module -Name PSScriptAnalyzer -Force
Save-Module -Name PSScriptAnalyzer -Path D:\
Invoke-ScriptAnalyzer -Path "D:\Программы\Прочее\ps1\Win 10.ps1"

# Перерегистрация всех UWP-приложений
# https://forums.mydigitallife.net/threads/guide-add-store-to-windows-10-enterprises-sku-ltsb-ltsc.70741/page-30#post-1468779
(Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\InboxApplications | Get-ItemProperty).Path | Add-AppxPackage -Register -DisableDevelopmentMode

# Домен
New-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters -Name AllowSingleLabelDnsDomain -Value 1 -Force

# Установка приложений из Магазина
https://store.rg-adguard.net
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
$AsyncWindow = Add-Type –MemberDefinition @"
	[DllImport("user32.dll")]
	public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@ -name "Win32ShowWindowAsync" -namespace Win32Functions –PassThru
$hwnd0 = (Get-Process -Name notepad).MainWindowHandle
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
		"HKEY_CLASSES_ROOT"
		{
			$reg = [Microsoft.Win32.Registry]::ClassesRoot
			$key = $key.substring(18)
		}
		"HKEY_CURRENT_USER"
		{
			$reg = [Microsoft.Win32.Registry]::CurrentUser
			$key = $key.substring(18)
		}
		"HKEY_LOCAL_MACHINE"
		{
			$reg = [Microsoft.Win32.Registry]::LocalMachine
			$key = $key.substring(19)
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
TakeownRegistry ("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WinDefend")

# Включение в Планировщике задач удаление устаревших обновлений Office, кроме Office 2019
$action = New-ScheduledTaskAction -Execute powershell.exe -Argument @"
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
$action = New-ScheduledTaskAction -Execute powershell.exe -Argument @"
`$getservice = Get-Service -Name wuauserv
`$getservice.WaitForStatus('Stopped', '01:00:00')
Get-ChildItem -Path `$env:SystemRoot\SoftwareDistribution\Download -Recurse -Force | Remove-Item -Recurse -Force
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
$action = New-ScheduledTaskAction -Execute powershell.exe -Argument @"
-WindowStyle Hidden `
Add-Type -AssemblyName System.Windows.Forms
`$global:balmsg = New-Object System.Windows.Forms.NotifyIcon
`$path = (Get-Process -Id `$pid).Path
`$balmsg.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon(`$path)
`$balmsg.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning
`$balmsg.BalloonTipText = 'Перезагрузка через 1 мин.'
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
(Get-Disk | Where-Object {$_.BusType -ne "USB" -and $_.IsBoot -eq $false} | Get-Partition | Get-Volume | Where-Object {$null -ne $_.DriveLetter}).DriveLetter | ForEach-Object {Join-Path ($_ + ":") $Path}
# Найти диски, не являющиеся загрузочными, исключая диски с пустыми буквами (не исключаются внешние жесткие диски)
(Get-Disk | Where-Object {$_.IsBoot -eq $false} | Get-Partition | Get-Volume | Where-Object {$null -ne $_.DriveLetter}).DriveLetter | ForEach-Object {Join-Path ($_ + ":") $Path}
# Найти первый диск, подключенный через USB, исключая диски с пустыми буквами
(Get-Disk | Where-Object {$_.BusType -eq "USB"} | Get-Partition | Get-Volume | Where-Object {$null -ne $_.DriveLetter}).DriveLetter | ForEach-Object {Join-Path ($_ + ":") $Path} | Select-Object -First 1

# Добавление доменов в hosts
$hostfile = "$env:SystemRoot\System32\drivers\etc\hosts"
$domains = @("site.com","site2.com")
Foreach ($hostentry in $domains)
{
	IF (-not (Get-Content -Path $hostfile | Select-String "0.0.0.0 `t $hostentry"))
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
Get-SmbMapping | Select-Object -Property LocalPath, RemotePath

# Версия ОС
$Channel = (Get-CimInstance -ClassName SoftwareLicensingProduct | Where-Object {$null -ne $_.PartialProductKey -and $_.ApplicationID -eq "55c92734-d682-4d71-983e-d6ec3f16059f"}).ProductKeyChannel
$ProductName = @{
	Name = "ProductName"
	Expression = {"$($_.ProductName) $($_.ReleaseId) $Channel"}
}
$Build = @{
	Name = "Build"
	Expression = {"$($_.CurrentMajorVersionNumber).$($_.CurrentMinorVersionNumber).$($_.CurrentBuild).$($_.UBR)"}
}
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows nt\CurrentVersion" | Select-Object -Property $ProductName, $Build | Format-List

# Проверить тип запуска службы
IF ((Get-Service -ServiceName wuauserv).StartType -eq "Disabled")
{
	Start-Service -ServiceName wuauserv -Force
	Set-Service -ServiceName wuauserv -StartupType Automatic
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

Get-WinEvent -LogName Application | Where-Object {$_.ProviderName -match 'Windows Error*'} | Select-Object -Property TimeCreated, Message | Format-Table -AutoSize -Wrap
Get-WinEvent -LogName System | Where-Object {$_.LevelDisplayName -match 'Критическая' -or $_.LevelDisplayName -match 'Ошибка'} | Select-Object -Property TimeCreated, ID, LevelDisplayName, Message | Sort-Object TimeCreated -Descending | Select-Object -First 10 | Format-Table -AutoSize -Wrap

# Настройка и проверка исключений Защитника Windows
Add-MpPreference -ExclusionProcess D:\folder\file.ext
Add-MpPreference -ExclusionPath D:\folder
Add-MpPreference -ExclusionExtension .ext

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
IF (-not ([System.Management.Automation.PSTypeName]'WindowsDesktopTools.Explorer').Type)
{
	$type = @{
		Namespace = 'WindowsDesktopTools'
		Name = 'Explorer'
		Language = 'CSharp'
		MemberDefinition = @'
			private static readonly IntPtr HWND_BROADCAST = new IntPtr(0xffff);
			private const int WM_SETTINGCHANGE = 0x1a;
			private const int SMTO_ABORTIFHUNG = 0x0002;
			[DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = false)]
			static extern bool SendNotifyMessage(IntPtr hWnd, uint Msg, IntPtr wParam, string lParam);
			[DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = false)]
			private static extern IntPtr SendMessageTimeout(IntPtr hWnd, int Msg, IntPtr wParam, string lParam, int fuFlags, int uTimeout, IntPtr lpdwResult);
			[DllImport("shell32.dll", CharSet = CharSet.Auto, SetLastError = false)]
			private static extern int SHChangeNotify(int eventId, int flags, IntPtr item1, IntPtr item2);
			public static void Refresh()
			{
				// Update desktop icons
				SHChangeNotify(0x8000000, 0x1000, IntPtr.Zero, IntPtr.Zero);
				// Update environment variables
				SendMessageTimeout(HWND_BROADCAST, WM_SETTINGCHANGE, IntPtr.Zero, null, SMTO_ABORTIFHUNG, 100, IntPtr.Zero);
				// Update taskbar
				SendNotifyMessage(HWND_BROADCAST, WM_SETTINGCHANGE, IntPtr.Zero, "TraySettings");
			}
'@
	}
	Add-Type @type
}
[WindowsDesktopTools.Explorer]::Refresh()

# Конвертировать в кодировку UTF8 с BOM
(Get-Content -Path "D:\1.ps1" -Encoding UTF8) | Set-Content -Encoding UTF8 -Path "D:\1.ps1"

# Вычленить букву диска
Split-Path -Path "D:\file.mp3" -Qualifier

# try/catch
try
{
	Do-Something
}
catch
{
	Write-Output "Something threw an exception"
}

# Получение контрольной суммы файла (MD2, MD4, MD5, SHA1, SHA256, SHA384, SHA512)
certutil -hashfile C:\file.txt SHA1
# Преобразование кодов ошибок в текстовое сообщение
certutil -error 0xc0000409

# Вычислить значение хеш-суммы строки
Function Get-StringHash
{
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$String,

		[Parameter(Mandatory = $true)]
		[ValidateSet("MACTripleDES", "MD5", "RIPEMD160", "SHA1", "SHA256", "SHA384", "SHA512")]
		[String] $HashName
	)
	$StringBuilder = New-Object System.Text.StringBuilder
	[System.Security.Cryptography.HashAlgorithm]::Create($HashName).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String))| ForEach-Object {
		[Void]$StringBuilder.Append($_.ToString("x2"))
	}
	$StringBuilder.ToString()
}
Get-StringHash 2 sha1

# Вычислить значение хеш-суммы файла
Get-FileHash D:\1.txt -Algorithm MD5

# Получить список установленных приложений
$keys = @("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
"HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall")
foreach ($key in $keys)
{
	(Get-ItemProperty $key\* | Where-Object {$_.DisplayName -ne $null}).DisplayName
}

# Проверить, добавлен ли уже класс
IF (-not (([System.Management.Automation.PSTypeName]"Win32Functions.Win32ShowWindowAsync").Type))
{
	code
}
#
IF (-not ("Win32Functions.Win32ShowWindowAsync" -as [type]))
{
	code
}

# Развернуть окно с заголовком "Диспетчер задач", а остальные окна свернуть
IF (-not ("Win32Functions.Win32ShowWindowAsync" -as [type]))
{
	$Win32ShowWindowAsync = Add-Type -MemberDefinition @"
	[DllImport("user32.dll")]
	public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@ -name "Win32ShowWindowAsync" -Namespace Win32Functions -PassThru
}
$title = "Диспетчер задач"
Get-Process | Where-Object {$_.MainWindowHandle -ne 0} | ForEach-Object {
	IF ($_.MainWindowTitle -eq $title)
	{
		$Win32ShowWindowAsync::ShowWindowAsync($_.MainWindowHandle, 3) | Out-Null
	}
	else
	{
		$Win32ShowWindowAsync::ShowWindowAsync($_.MainWindowHandle, 6) | Out-Null
	}
}

# Do/Until
Do
{
	$preferences = Get-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager -Name Preferences -ErrorAction SilentlyContinue
}
Until ($preferences)

# Закрепить на начальном экране ярлык
$Target = "D:\folder\file.lnk"
$Directory = (Get-Childitem -Path $Target).Directory
$File = (Get-ChildItem -Path $Target).Name
$shell = New-Object -ComObject "Shell.Application"
$folder = $shell.Namespace("$Directory\")
$file = $folder.Parsename("$File")
$verb = $file.Verbs() | Where-Object {$_.Name -like "Закрепить на начальном &экране"}
$verb.DoIt()

# Закрепить на панели задач ярлык
$Target = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\file.lnk"
$Value = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.taskbarpin").ExplorerCommandHandler
IF (-not (Test-Path -Path "HKCU:\Software\Classes\*\shell\pin"))
{
	New-Item -Path "HKCU:\Software\Classes\*\shell\pin" -Force
}
New-ItemProperty -LiteralPath "HKCU:\Software\Classes\*\shell\pin" -Name ExplorerCommandHandler -Type String -Value $Value -Force
$Shell = New-Object -ComObject "Shell.Application"
$Folder = $Shell.Namespace((Get-Item -Path $Target).DirectoryName)
$Item = $Folder.ParseName((Get-Item -Path Target).Name)
$Item.InvokeVerb("pin")
Remove-Item -LiteralPath "HKCU:\Software\Classes\*\shell\pin" -Recurse

# Открепить от панели задач ярлык
$Target = "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\file.lnk"
$Value = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.taskbarpin").ExplorerCommandHandler
IF (-not (Test-Path -Path "HKCU:\Software\Classes\*\shell\pin"))
{
	New-Item -Path "HKCU:\Software\Classes\*\shell\pin" -Force
}
New-ItemProperty -LiteralPath "HKCU:\Software\Classes\*\shell\pin" -Name ExplorerCommandHandler -Type String -Value $Value -Force
$Shell = New-Object -ComObject "Shell.Application"
$Folder = $Shell.Namespace((Get-Item -Path $Target).DirectoryName)
$Item = $Folder.ParseName((Get-Item -Path $Target).Name)
$Item.InvokeVerb("pin")
Remove-Item -LiteralPath "HKCU:\Software\Classes\*\shell\pin" -Recurse

# Установить состояние показа окна
function WindowState
{
	param(
		[Parameter( ValueFromPipeline = $true, Mandatory = $true, Position = 0 )]
		[ValidateScript({$_ -ne 0 })]
		[System.IntPtr] $MainWindowHandle,
		[ValidateSet('FORCEMINIMIZE', 'HIDE', 'MAXIMIZE', 'MINIMIZE', 'RESTORE',
				'SHOW', 'SHOWDEFAULT', 'SHOWMAXIMIZED', 'SHOWMINIMIZED',
				'SHOWMINNOACTIVE', 'SHOWNA', 'SHOWNOACTIVATE', 'SHOWNORMAL')]
		[String] $State = 'SHOW'
	)
	$WindowStates = @{
		'FORCEMINIMIZE'   = 11
		'HIDE'            = 0
		'MAXIMIZE'        = 3
		'MINIMIZE'        = 6
		'RESTORE'         = 9
		'SHOW'            = 5
		'SHOWDEFAULT'     = 10
		'SHOWMAXIMIZED'   = 3
		'SHOWMINIMIZED'   = 2
		'SHOWMINNOACTIVE' = 7
		'SHOWNA'          = 8
		'SHOWNOACTIVATE'  = 4
		'SHOWNORMAL'      = 1
	}
	IF (-not ( "Win32Functions.Win32ShowWindowAsync" -as [Type]))
	{
		Add-Type -MemberDefinition @"
		[DllImport("user32.dll")]
		public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@ -Namespace 'Win32Functions' -Name 'Win32ShowWindowAsync'
	}
	[Win32Functions.Win32ShowWindowAsync]::ShowWindowAsync($MainWindowHandle , $WindowStates[$State])
}
$MainWindowHandle = (Get-Process -Name notepad | Where-Object {$_.MainWindowHandle -ne 0}).MainWindowHandle
$MainWindowHandle | WindowState -State HIDE

# Установить бронзовый курсор из Windows XP
$cursor = 'Программы\Прочее\bronze.cur'
function Get-ResolvedPath
{
	param ([Parameter(ValueFromPipeline = 1)]$Path)
	(Get-Disk | Where-Object {$_.BusType -eq "USB"} | Get-Partition | Get-Volume | Where-Object {$null -ne $_.DriveLetter}).DriveLetter | ForEach-Object {Join-Path ($_ + ":") $Path -Resolve -ErrorAction SilentlyContinue}
}
$cursor | Get-ResolvedPath | Copy-Item -Destination $env:SystemRoot\Cursors -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name Arrow -Type ExpandString -Value "%SystemRoot%\cursors\bronze.cur" -Force
$CSharpSig = @"
[DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
public static extern bool SystemParametersInfo(
uint uiAction,
uint uiParam,
uint pvParam,
uint fWinIni);
"@
$CursorRefresh = Add-Type -MemberDefinition $CSharpSig -Name WinAPICall -Namespace SystemParamInfo –PassThru
$CursorRefresh::SystemParametersInfo(0x0057,0,$null,0)