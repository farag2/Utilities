exit
# PSScriptAnalyzer
Install-PackageProvider -Name NuGet -Force
Install-Module -Name PSScriptAnalyzer -Force
Save-Module -Name PSScriptAnalyzer -Path D:\
Invoke-ScriptAnalyzer -Path "D:\Программы\Прочее\ps1\*.ps1" | Where-Object -FilterScript {$_.RuleName -ne "PSAvoidUsingWriteHost"}

# Перерегистрация всех UWP-приложений
(Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\InboxApplications | Get-ItemProperty).Path | Add-AppxPackage -Register -DisableDevelopmentMode

# Установка Microsoft Store из appxbundle
SW_DVD9_NTRL_Win_10_1903_32_64_ARM64_MultiLang_App_Update_X22-01657.ISO
https://store.rg-adguard.net
CategoryID: 64293252-5926-453c-9494-2d4021f1c78d
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx -Name AllowAllTrustedApps -Value 1 -Force
Add-AppxProvisionedPackage -Online -PackagePath D:\Store.appxbundle -LicensePath D:\Store.xml
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx -Name AllowAllTrustedApps -Value 0 -Force

# Разрешить подключаться одноуровневому домену
New-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters -Name AllowSingleLabelDnsDomain -Value 1 -Force

# Стать владельцем ключа в Реестре
$ParentACL = Get-Acl -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.txt"
$k = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey("Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.txt\UserChoice","ReadWriteSubTree","TakeOwnership")
$acl = $k.GetAccessControl()
$null = $acl.SetAccessRuleProtection($false,$true)
$rule = New-Object System.Security.AccessControl.RegistryAccessRule ($ParentACL.Owner,"FullControl","Allow")
$null = $acl.SetAccessRule($rule)
$rule = New-Object System.Security.AccessControl.RegistryAccessRule ($ParentACL.Owner,"SetValue","Deny")
$null = $acl.RemoveAccessRule($rule)
$null = $k.SetAccessControl($acl)

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
	switch ($key.split("\")[0])
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
	`$getservice.WaitForStatus("Stopped", '01:00:00')
	Start-Process -FilePath D:\Программы\Прочее\Office_task.bat
"@
$trigger = New-ScheduledTaskTrigger -Weekly -At 9am -DaysOfWeek Thursday -WeeksInterval 4
$settings = New-ScheduledTaskSettingsSet -Compatibility Win8 -StartWhenAvailable
$principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -RunLevel Highest
$params = @{
	"TaskName"	= "Office"
	"Action"	= $action
	"Trigger"	= $trigger
	"Settings"	= $settings
	"Principal"	= $principal
}
Register-ScheduledTask @Params -Force

# Создать в Планировщике задач задачу со всплывающим окошком с сообщением о перезагрузке
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
(Get-Disk | Where-Object -FilterScript {$_.BusType -ne "USB" -and $_.IsBoot -eq $false} | Get-Partition | Get-Volume | Where-Object -FilterScript {$null -ne $_.DriveLetter}).DriveLetter | ForEach-Object -Process {Join-Path ($_ + ":") $Path}
# Найти диски, не являющиеся загрузочными, исключая диски с пустыми буквами (не исключаются внешние жесткие диски)
(Get-Disk | Where-Object -FilterScript {$_.IsBoot -eq $false} | Get-Partition | Get-Volume | Where-Object -FilterScript {$null -ne $_.DriveLetter}).DriveLetter | ForEach-Object -Process {Join-Path ($_ + ":") $Path}
# Найти первый диск, подключенный через USB, исключая диски с пустыми буквами
(Get-Disk | Where-Object -FilterScript {$_.BusType -eq "USB"} | Get-Partition | Get-Volume | Where-Object -FilterScript {$null -ne $_.DriveLetter}).DriveLetter | ForEach-Object -Process {Join-Path ($_ + ":") $Path} | Select-Object -First 1

# Добавление доменов в hosts
$hostfile = "$env:SystemRoot\System32\drivers\etc\hosts"
$domains = @("site.com","site2.com")
foreach ($hostentry in $domains)
{
	IF (-not (Get-Content -Path $hostfile | Select-String "0.0.0.0 `t $hostentry"))
	{
		Add-Content -Path $hostfile -Value "0.0.0.0 `t $hostentry"
	}
}

# Отделить название от пути
Split-Path -Path file.ext -Leaf
# Отделить путь от названия
Split-Path -Path file.ext -Parent
# Отделить от пути название последней папки
Get-Item -Path file.ext | Split-Path -Parent | Split-Path -Parent | Split-Path -Leaf

# Получить события из журналов событий и файлов журналов отслеживания событий
enum Level
{
	LogAlways		= 0
	Critical		= 1
	Error			= 2
	Warning			= 3
	Informational	= 4
	Verbose			= 5
}
Get-WinEvent -LogName System | Where-Object -FilterScript {$_.LevelDisplayName -match "Критическая" -or $_.LevelDisplayName -match "Ошибка"}
Get-WinEvent -FilterHashtable @{
	LogName = "Windows PowerShell"
	ProviderName = "PowerShell"
	Id = "800"
} | Where-Object -FilterScript {$_.Level -eq "3" -or $_.Level -eq "4"}
Get-WinEvent -LogName "Windows PowerShell" | Where-Object -FilterScript {$_.Message -match "HostApplication=(?<a>.*)"} | Format-List -Property *
Get-EventLog -LogName "Windows PowerShell" -InstanceId 10 | Where-Object -FilterScript {$_.Message -match "powershell.exe"}

# Передача больших файлов по медленным и нестабильным сетям
# Нагружает диск
Import-Module BitsTransfer
Start-BitsTransfer -Source $url -Destination $output
# Start-BitsTransfer -Source $url -Destination $output -Asynchronous

# Скачать файл
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$HT = @{
	Uri = "https://site.com/1.js"
	OutFile = "D:\1.js"
	UseBasicParsing = [switch]::Present
	Verbose = [switch]::Present
}
Invoke-WebRequest @HT

#
$url = "http://"
Invoke-Expression (New-Object System.Net.WebClient).DownloadString($url)

# Скачать и отобразить текстовый файл
(Invoke-WebRequest -Uri "https://site.com/1.js" -OutFile D:\1.js -PassThru).Content

# Прочитать содержимое текстового файла
(Invoke-WebRequest -Uri "https://site.com/1.js").Content

# Подсчет времени
$start_time = Get-Date
Write-Output "Time taken: $((Get-Date).Subtract($start_time).Milliseconds) second(s)"

# Создать архив
Get-ChildItem -Path D:\folder -Filter *.ps1 -Recurse | Compress-Archive -DestinationPath D:\folder2 -CompressionLevel Optimal

# Разархивировать архив
$HT = @{
	Path = "D:\1.zip"
	DestinationPath = "D:\1"
	Force = [switch]::Present
	Verbose = [switch]::Present
}
Expand-Archive @HT

# Конвертировать файл в кодировку UTF8 с BOM
$Path = "D:\file.ext"
(Get-Content -Path $Path -Encoding UTF8) | Set-Content -Encoding UTF8 -Path $Path

# Конвертировать файл в кодировку UTF8 без BOM
$utf8 = New-Object System.Text.UTF8Encoding $false
$Path = "D:\file.ext"
$Content = Get-Content -Path $Path -Raw
Set-Content -Value $utf8.GetBytes($Content) -Encoding Byte -Path $Path

# Вычленить букву диска
Split-Path -Path "D:\file.mp3" -Qualifier

# Получение контрольной суммы файла (MD2, MD4, MD5, SHA1, SHA256, SHA384, SHA512)
certutil -hashfile C:\file.txt SHA1
# Преобразование кодов ошибок в текстовое сообщение
certutil -error 0xc0000409

# Вычислить значение хеш-суммы файла
Get-FileHash D:\1.txt -Algorithm MD5

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
	[System.Security.Cryptography.HashAlgorithm]::Create($HashName).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String))| ForEach-Object -Process {
		[Void]$StringBuilder.Append($_.ToString("x2"))
	}
	$StringBuilder.ToString()
}
Get-StringHash 2 sha1

# Развернуть окно с заголовком "Диспетчер задач", а остальные окна свернуть
$Win32ShowWindowAsync = @{
	Namespace = "Win32Functions"
	Name = "Win32ShowWindowAsync"
	Language = "CSharp"
	MemberDefinition = @"
		[DllImport("user32.dll")]
		public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@
}
IF (-not ("Win32Functions.Win32ShowWindowAsync" -as [type]))
{
	Add-Type @Win32ShowWindowAsync
}
$title = "Диспетчер задач"
Get-Process | Where-Object -FilterScript {$_.MainWindowHandle -ne 0} | ForEach-Object -Process {
	IF ($_.MainWindowTitle -eq $title)
	{
		[Win32Functions.Win32ShowWindowAsync]::ShowWindowAsync($_.MainWindowHandle, 3) | Out-Null
	}
	else
	{
		[Win32Functions.Win32ShowWindowAsync]::ShowWindowAsync($_.MainWindowHandle, 6) | Out-Null
	}
}

# Установить состояние показа окна
# https://docs.microsoft.com/ru-ru/windows/win32/api/winuser/nf-winuser-showwindow
function WindowState
{
	param(
		[Parameter(ValueFromPipeline = $true, Mandatory = $true, Position = 0)]
		[ValidateScript({$_ -ne 0})]
		[System.IntPtr] $MainWindowHandle,
		[ValidateSet("FORCEMINIMIZE", "HIDE", "MAXIMIZE", "MINIMIZE", "RESTORE",
				"SHOW", "SHOWDEFAULT", "SHOWMAXIMIZED", "SHOWMINIMIZED",
				"SHOWMINNOACTIVE", "SHOWNA", "SHOWNOACTIVATE", "SHOWNORMAL")]
		[String] $State = "SHOW"
	)
	$WindowStates = @{
		"HIDE"				=	0
		"SHOWNORMAL"		=	1
		"SHOWMINIMIZED"		=	2
		"MAXIMIZE"			=	3
		"SHOWMAXIMIZED"		=	3
		"SHOWNOACTIVATE"	=	4
		"SHOW"				=	5
		"MINIMIZE"			=	6
		"SHOWMINNOACTIVE"	=	7
		"SHOWNA"			=	8
		"RESTORE"			=	9
		"SHOWDEFAULT"		=	10
		"FORCEMINIMIZE"		=	11
	}
	$Win32ShowWindowAsync = @{
	Namespace = "Win32Functions"
	Name = "Win32ShowWindowAsync"
	Language = "CSharp"
	MemberDefinition = @"
		[DllImport("user32.dll")]
		public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@
	}
	IF (-not ("Win32Functions.Win32ShowWindowAsync" -as [type]))
	{
		Add-Type @Win32ShowWindowAsync
	}
	[Win32Functions.Win32ShowWindowAsync]::ShowWindowAsync($MainWindowHandle , $WindowStates[$State])
}
$MainWindowHandle = (Get-Process -Name notepad | Where-Object -FilterScript {$_.MainWindowHandle -ne 0}).MainWindowHandle
$MainWindowHandle | WindowState -State HIDE

# Установить бронзовый курсор из Windows XP
# Функция для нахождения буквы диска, когда файл находится в известной папке, но не известна буква диска. Подходит, когда файл располагается на USB-носителе
$cursor = "Программы\Прочее\bronze.cur"
function Get-ResolvedPath
{
	param (
		[Parameter(ValueFromPipeline = 1)]
		$Path
	)
	(Get-Disk | Where-Object -FilterScript {$_.BusType -eq "USB"} | Get-Partition | Get-Volume | Where-Object -FilterScript {$null -ne $_.DriveLetter}).DriveLetter | ForEach-Object -Process {Join-Path ($_ + ":") $Path -Resolve -ErrorAction SilentlyContinue}
}
$cursor | Get-ResolvedPath | Copy-Item -Destination $env:SystemRoot\Cursors -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name Arrow -Type ExpandString -Value "%SystemRoot%\cursors\bronze.cur" -Force
$Signature = @{
	Namespace = "SystemParamInfo"
	Name = "WinAPICall"
	Language = "CSharp"
	MemberDefinition = @"
		[DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
		public static extern bool SystemParametersInfo(
		uint uiAction,
		uint uiParam,
		uint pvParam,
		uint fWinIni);
"@
}
IF (-not ("SystemParamInfo.WinAPICall" -as [type]))
{
	Add-Type @Signature
}
[SystemParamInfo.WinAPICall]::SystemParametersInfo(0x0057,0,$null,0)

# Стать владельцем файла
takeown /F D:\file.exe
icacls D:\file.exe /grant:r %username%:F
# Стать владельцем папки
takeown /F C:\HV\10 /R
icacls C:\HV\10 /grant:r %username%:F /T

# Найти файл на всех локальных дисках и вывести его полный путь
$file = "file.ext"
(Get-ChildItem -Path ([System.IO.DriveInfo]::GetDrives() | Where-Object {$_.DriveType -ne "Network"}).Name -Recurse -ErrorAction SilentlyContinue | Where-Object -FilterScript {$_.Name -like "$file"}).FullName

# Создать ini-файл с кодировкой UCS-2 LE BOM
$rarregkey = @"
RAR registration data
Alexander Roshal
Unlimited Company License
UID=00f650198f81e6607ec5
64122122507ec5206fb48daec2aaa67b4afc9a80b6a2e60ac35c4d
78565fc0aaa9d24b459460fce6cb5ffde62890079861be57638717
7131ced835ed65cc743d9777f2ea71a8e32c7e593cf66794343565
b41bcf56929486b8bcdac33d50ecf77399602d355a7873c5e960f7
8c0c621c6c7c2040df0794978f4e20e362354119251b5ea1fecc9d
bfa426c154150408200be88b82c1234bc3d4ee6e979bfff660dfe8
821d4d458f9319f95f2533d09ce2d8b75beac25fb63a3215972308
"@
Set-Content -Path "$env:ProgramFiles\WinRAR\rarreg.key" -Value $rarregkey -Encoding Unicode -Force

# Удалить первые $c буквы в названиях файлов в папке
$path = "D:\folder"
$e = "flac"
$c = 4
(Get-ChildItem -Path $path -Filter *.$e) | Rename-Item -NewName {$_.Name.Substring($c)}

# Удалить последние $c буквы в названиях файлов в папке
$path = "D:\folder"
$e = "flac"
$c = 4
Get-ChildItem -Path $path -Filter *.$e | Rename-Item -NewName {$_.Name.Substring(0,$_.BaseName.Length-$c) + $_.Extension}

# Найти файлы, в названии которых каждое слово не написано с заглавной буквы
(Get-ChildItem -Path D:\Программы\AIMP -File -Recurse | Where-Object -FilterScript {($_.BaseName -replace "'|``") -cmatch "\b\p{Ll}\w*"}).FullName

# Записать прописными буквами первую букву каждого слова в названии каждого файла в папке
$TextInfo = (Get-Culture).TextInfo
$path = "D:\folder"
$e = "flac"
Get-ChildItem -Path $path -Filter *.$e | Rename-Item -NewName {$TextInfo.ToTitleCase($_.BaseName) + $_.Extension}

# Заменить слово в названии файлов в папке
Get-ChildItem -Path "D:\folder" | Rename-Item -NewName {$_.Name.Replace("abc","cba")}

# Добавить REG_NONE
New-ItemProperty -Path HKCU:\Software -Name Name -PropertyType None -Value ([byte[]]@()) -Force

# Скачать видео с помощью youtube-dl
# https://github.com/ytdl-org/youtube-dl/releases
# https://ffmpeg.zeranoe.com/builds
$urls= @(
	"https://",
	"https://"
)
$youtubedl = "D:\youtube-dl.exe"
# --list-formats url
# --format 43+35 url
# --username $username
# --password $password
# --video-password $videopassword
$output = "D:\"
$filename = "%(title)s.mp4"
foreach ($url in $urls)
{
	Start-Process -FilePath $youtubedl -ArgumentList "--output `"$output\$filename`" $url"
}

# Конвертировать binary
"50,33,01".Split(",") | ForEach-Object -Process {"0x$_"}

# Отключить сетевые протоколы
$ComponentIDs = @(
	"ms_tcpip6"
	"ms_pacer"
)
Disable-NetAdapterBinding -Name Ethernet -ComponentID $ComponentIDs

# Вычислить продолжительность видеофайлов в папке
# http://code.avalon-zone.be/retrieve-the-extended-attibutes-of-a-file
Function Get-Duration
{
	param ($TargetFolder)
	$shell = New-Object -ComObject Shell.Application
	$TotalDuration = [timespan]0
	Get-ChildItem -Path $TargetFolder | ForEach-Object -Process {
		$Folder = $shell.Namespace($_.DirectoryName)
		$File = $Folder.ParseName($_.Name)
		$Duration = [timespan]$Folder.GetDetailsOf($File, 27)
		$TotalDuration += $Duration
		[PSCustomObject] @{
			File = $_.Name
			Duration = $Duration
		}
	}
	"`nTotal duration $TotalDuration"
}
(Get-Duration D:\folder | Sort-Object Duration | Out-String).Trim()

# Изменить переменные среды на C:\Temp
setx /M TEMP "%SystemDrive%\Temp"
setx /M TMP "%SystemDrive%\Temp"
setx TEMP "%SystemDrive%\Temp"
setx TMP "%SystemDrive%\Temp"

# Отобразить форму с выпадающим списком накопителей
# Загрузить класс System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms
# Создать графическую форму
$window_form = New-Object System.Windows.Forms.Form
$window_form.Text ="Пример"
$window_form.Width = 600
$window_form.Height = 400
$window_form.AutoSize = $true
# Создать надпись
$Label = New-Object System.Windows.Forms.Label
$Label.Text = "Label"
$Label.Location = New-Object System.Drawing.Point(0,10)
$Label.AutoSize = $true
$window_form.Controls.Add($Label)
# Выпадающий список дисков
$ComboBox = New-Object System.Windows.Forms.ComboBox
$ComboBox.Width = 250
$Disks = Get-PhysicalDisk
Foreach ($Disk in $Disks)
{
	$ComboBox.Items.Add($Disk.FriendlyName);
}
$ComboBox.Location = New-Object System.Drawing.Point(60,10)
$window_form.Controls.Add($ComboBox)
# Надпись
$Label2 = New-Object System.Windows.Forms.Label
$Label2.Text = "Disk size:"
$Label2.Location = New-Object System.Drawing.Point(0,40)
$Label2.AutoSize = $true
$window_form.Controls.Add($Label2)
$Label3 = New-Object System.Windows.Forms.Label
$Label3.Text = ""
$Label3.Location = New-Object System.Drawing.Point(110,40)
$Label3.AutoSize = $true
$window_form.Controls.Add($Label3)
# Кнопка
$Button = New-Object System.Windows.Forms.Button
$Button.Location = New-Object System.Drawing.Size(400,10)
$Button.Size = New-Object System.Drawing.Size(120,23)
$Button.Text = "Check"
$window_form.Controls.Add($Button)
# Расчет
$Button.Add_Click(
	{
		$Label3.Text = [math]::round(($Disks | Where-Object -FilterScript {$_.FriendlyName -eq $ComboBox.SelectedItem}).Size/1GB,2)
	}
)
# Отобразить форму
$window_form.ShowDialog()

# Найти неустановленные обновления
$UpdateSession = New-Object -ComObject Microsoft.Update.Session
$UpdateSearcher = $UpdateSession.CreateupdateSearcher()
$Updates = @($UpdateSearcher.Search("IsHidden=0 and IsInstalled=0").Updates)
$Updates | Select-Object Title

# Закрыть определенное окно Проводника
$folder = "D:\folder"
$shell = New-Object -ComObject Shell.Application
$window = $shell.Windows() | Where-Object {$_.LocationURL -eq "file:///"+([uri]$folder.Replace("\","/")).OriginalString}
$window | ForEach-Object -Process {$_.Quit()}