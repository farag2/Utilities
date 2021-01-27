exit
# Перерегистрация всех UWP-приложений
(Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\InboxApplications | Get-ItemProperty).Path | Add-AppxPackage -Register -DisableDevelopmentMode

# Восстановить UWP-приложения
$DamagedPackages = @()
$DamagedFiles = (Get-ChildItem -Path "$env:ProgramFiles\WindowsApps\" -Recurse | Where-Object -FilterScript {$_.Length -eq 0}).FullName

foreach ($DamagedFile in $DamagedFiles)
{
	if ($DamagedFile -like "*8wekyb3d8bbwe*")
	{
		$DamagedPackages += ((Split-Path -Path $DamagedFile).Replace("$env:ProgramFiles\WindowsApps\","") -Split ("8wekyb3d8bbwe"))[0] + "8wekyb3d8bbwe"
	}
}

foreach ($Package in $($DamagedPackages | Get-Unique))
{
	New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModel\StateChange\PackageList\$Package" -Force
	New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModel\StateChange\PackageList\$Package" -Name PackageStatus -Value 2 -PropertyType DWORD -Force
}

Get-CimInstance -Namespace "Root\cimv2\mdm\dmmap" -ClassName "MDM_EnterpriseModernAppManagement_AppManagement01" | Invoke-CimMethod -MethodName UpdateScanMethod

foreach ($Package in $($DamagedPackages | Get-Unique))
{
	Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModel\StateChange\PackageList\$Package" -Force
}

# Установка Microsoft Store из appxbundle
# SW_DVD9_NTRL_Win_10_20H2_32_64_ARM64_MultiLang_Inbox_Apps_X22-36106.ISO
# https://store.rg-adguard.net
# https://yadi.sk/d/10Ttj2IVOKQ0Og
Add-AppxPackage -Path D:\Microsoft.DesktopAppInstaller.appxbundle
Add-AppxPackage -Path D:\Microsoft.StorePurchaseApp.appxbundle

# Разрешить подключаться к одноуровневому домену
New-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters -Name AllowSingleLabelDnsDomain -Value 1 -Force

# Включение в Планировщике задач удаление устаревших обновлений Office, кроме Office 2019
$Script = '
	(Get-Service -Name wuauserv).WaitForStatus("Stopped", "01:00:00")
	Start-Process -FilePath D:\folder\Office_task.cmd
'
$EncodedScript = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($Script))
$action = New-ScheduledTaskAction -Execute powershell.exe -Argument "-WindowStyle Hidden -EncodedCommand $EncodedScript"
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

# Найти диски, не подключенные через USB и не являющиеся загрузочными, исключая диски с пустыми буквами (исключаются внешние жесткие диски)
(Get-Disk | Where-Object -FilterScript {$_.BusType -ne "USB" -and $_.IsBoot -eq $false} | Get-Partition | Get-Volume | Where-Object -FilterScript {$null -ne $_.DriveLetter}).DriveLetter | ForEach-Object -Process {Join-Path ($_ + ":") $Path}
# Найти диски, не являющиеся загрузочными, исключая диски с пустыми буквами (не исключаются внешние жесткие диски)
(Get-Disk | Where-Object -FilterScript {$_.IsBoot -eq $false} | Get-Partition | Get-Volume | Where-Object -FilterScript {$null -ne $_.DriveLetter}).DriveLetter | ForEach-Object -Process {Join-Path ($_ + ":") $Path}
# Найти первый диск, подключенный через USB, исключая диски с пустыми буквами
(Get-Disk | Where-Object -FilterScript {$_.BusType -eq "USB"} | Get-Partition | Get-Volume | Where-Object -FilterScript {$null -ne $_.DriveLetter}).DriveLetter | ForEach-Object -Process {Join-Path ($_ + ":") $Path} | Select-Object -First 1

# Добавление доменов в hosts
$hostfile = "$env:SystemRoot\System32\drivers\etc\hosts"
$domains = @("site.com", "site2.com")
foreach ($hostentry in $domains)
{
	if (-not (Get-Content -Path $hostfile | Select-String "0.0.0.0 `t $hostentry"))
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
# [Level]::LogAlways.Value__
# [Level]0

# WinEvent
# https://schneegans.de/windows/process-audit/
# https://devblogs.microsoft.com/commandline/how-to-determine-what-just-ran-on-windows-console/
$Level = @{
	Name = "Level"
	Expression = {[Level]$_.Level}
}
Get-WinEvent -LogName System | Select-Object Id, $Level, ProviderName, ThreadId, LevelDisplayName, TaskDisplayName
Get-WinEvent -LogName System | Where-Object -FilterScript {$_.LevelDisplayName -match "Критическая" -or $_.LevelDisplayName -match "Ошибка"}
#
$WindowsPowerShell = @{
	LogName = "Windows PowerShell"
	ProviderName = "PowerShell"
	Id = "800"
}
Get-WinEvent -FilterHashtable $WindowsPowerShell | Where-Object -FilterScript {$_.Level -eq "3" -or $_.Level -eq "4"}
#
Get-WinEvent -LogName "Windows PowerShell" | Where-Object -FilterScript {$_.Message -match "HostApplication=(?<a>.*)"} | Format-List -Property *
# Устарело
Get-EventLog -LogName "Windows PowerShell" -InstanceId 10 | Where-Object -FilterScript {$_.Message -match "powershell.exe"}
#
$Security = @{
	LogName = "Security"
	Id = 4688
}
$NewProcessName = @{
	Name = "NewProcessName"
	Expression = {$_.Properties[5].Value}
}
$CommandLine = @{
	Name = "CommandLine"
	Expression = {$_.Properties[8].Value}
}
Get-WinEvent -FilterHashtable $Security | Select-Object TimeCreated, $NewProcessName, $CommandLine | Format-Table -AutoSize -Wrap
#
function Get-ProcessAuditEvents ([long]$MaxEvents)
{
	function Prettify([string]$Message)
	{
		$Message = [regex]::Replace($Message, '\s+Token Elevation Type indicates.+$', '', [System.Text.RegularExpressions.RegexOptions]::Singleline)
		$Message = [regex]::Replace($Message, '(Token Elevation Type:\s+%%1936)', '$1 (Full token)')
		$Message = [regex]::Replace($Message, '(Token Elevation Type:\s+%%1937)', '$1 (Elevated token)')
		$Message = [regex]::Replace($Message, '(Token Elevation Type:\s+%%1938)', '$1 (Limited token)')
		return $Message
	}
	$Security = @{
		LogName = "Security"
		Id = 4688
	}
	Get-WinEvent -MaxEvents $MaxEvents -FilterHashtable $Security | Sort-Object -Property TimeCreated | ForEach-Object {
		[pscustomobject] @{
			TimeCreated = $_.TimeCreated
			Message		= $_.Message
		}
	}
}
Get-ProcessAuditEvents -MaxEvents 10 | Format-List
#
$ParentProcess = @{
	Label = "ParentProcess"
	Expression = {$_.Properties[13].Value}
}
Get-WinEvent -LogName Security | Where-Object -FilterScript {$_.Id -eq "4688"} | Where-Object -FilterScript {$_.Properties[5].Value -match 'conhost'} | Select-Object TimeCreated, $ParentProcess | Select-Object -First 10

# Исполнить код по ссылке
$url = "https://site.com/1.js"
Invoke-Expression (New-Object -TypeName System.Net.WebClient).DownloadString($url)

# Скачать и отобразить текстовый файл
(Invoke-WebRequest -Uri "https://site.com/1.js" -OutFile D:\1.js -PassThru -UseBasicParsing).Content

# Прочитать содержимое текстового файла
(Invoke-WebRequest -Uri "https://site.com/1.js" -UseBasicParsing).Content

# Создать архив
Get-ChildItem -Path D:\folder -Filter *.ps1 -Recurse | Compress-Archive -DestinationPath D:\folder2 -CompressionLevel Optimal

# Разархивировать архив
$Parameters = @{
	Path = "D:\1.zip"
	DestinationPath = "D:\1"
	Force = [switch]::Present
	Verbose = [switch]::Present
}
Expand-Archive @Parameters

# Вычленить букву диска
Split-Path -Path "D:\file.mp3" -Qualifier

# Получение контрольной суммы файла (MD2, MD4, MD5, SHA1, SHA256, SHA384, SHA512)
certutil -hashfile C:\file.txt SHA1

# Преобразование кодов ошибок в текстовое сообщение
certutil -error 0xc0000409

# Вычислить значение хеш-суммы файла
Get-FileHash -Path D:\1.txt -Algorithm MD5

# Вычислить значение хеш-суммы строки
function Get-StringHash
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]
		$String,

		[Parameter(Mandatory = $true)]
		[ValidateSet("MACTripleDES", "MD5", "RIPEMD160", "SHA1", "SHA256", "SHA384", "SHA512")]
		[string]
		$HashName
	)

	$StringBuilder = New-Object -TypeName System.Text.StringBuilder
	[System.Security.Cryptography.HashAlgorithm]::Create($HashName).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String))| ForEach-Object -Process {
		[Void]$StringBuilder.Append($_.ToString("x2"))
	}
	$StringBuilder.ToString()
}
Get-StringHash -String "2" -HashName SHA1

# Развернуть окно с заголовком "Диспетчер задач", а остальные окна свернуть
$Win32ShowWindowAsync = @{
	Namespace = "WinAPI"
	Name = "Win32ShowWindowAsync"
	Language = "CSharp"
	MemberDefinition = @"
		[DllImport("user32.dll")]
		public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@
}
if (-not ("WinAPI.Win32ShowWindowAsync" -as [type]))
{
	Add-Type @Win32ShowWindowAsync
}
$title = "Диспетчер задач"
Get-Process | Where-Object -FilterScript {$_.MainWindowHandle -ne 0} | ForEach-Object -Process {
	if ($_.MainWindowTitle -eq $title)
	{
		[WinAPI.Win32ShowWindowAsync]::ShowWindowAsync($_.MainWindowHandle, 3) | Out-Null
	}
	else
	{
		[WinAPI.Win32ShowWindowAsync]::ShowWindowAsync($_.MainWindowHandle, 6) | Out-Null
	}
}

# Установить состояние показа окна
# https://docs.microsoft.com/ru-ru/windows/win32/api/winuser/nf-winuser-showwindow
function WindowState
{
	[CmdletBinding()]
	param
	(
		[Parameter(
			ValueFromPipeline = $true,
			Mandatory = $true,
			Position = 0
		)]
		[ValidateScript({$_ -ne 0})]
		[System.IntPtr]
		$MainWindowHandle,

		[ValidateSet(
			"FORCEMINIMIZE", "HIDE", "MAXIMIZE", "MINIMIZE", "RESTORE",
			"SHOW", "SHOWDEFAULT", "SHOWMAXIMIZED", "SHOWMINIMIZED",
			"SHOWMINNOACTIVE", "SHOWNA", "SHOWNOACTIVATE", "SHOWNORMAL"
		)]
		[string]
		$State = "SHOW"
	)

	$WindowStates = @{
		"HIDE"				=	0 # Скрыть окно и активизировать другое окно
		"SHOWNORMAL"		=	1 # Активизировать и отобразить окно, если окно свернуто или развернуто
		"SHOWMINIMIZED"		=	2 # Отобразить окно в свернутом виде
		"MAXIMIZE"			=	3 # Maximizes the specified window
		"SHOWMAXIMIZED"		=	3 # Activates the window and displays it as a maximized window
		"SHOWNOACTIVATE"	=	4 # Отобразить окно в соответствии с последними значениями позиции и размера. Активное окно остается активным
		"SHOW"				=	5 # Активизировать окно
		"MINIMIZE"			=	6 # Свернуть окно и активизировать следующее окно в Z-порядке (следующее под свернутым окном)
		"SHOWMINNOACTIVE"	=	7
		"SHOWNA"			=	8 # Отобразить окно в текущем состоянии. Активное окно остается активным
		"RESTORE"			=	9 # Активизировать и отобразить окно. Если окно свернуто или развернуто, Windows восстанавливает его исходный размер и положение
		"SHOWDEFAULT"		=	10 # (1+9) Активизировать и отобразить окно на переднем плане, если было свернуто или скрыто
		"FORCEMINIMIZE"		=	11 # Minimizes a window, even if the thread that owns the window is not responding. This flag should only be used when minimizing windows from a different thread
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

	if (-not ("Win32Functions.Win32ShowWindowAsync" -as [type]))
	{
		Add-Type @Win32ShowWindowAsync
	}
	[Win32Functions.Win32ShowWindowAsync]::ShowWindowAsync($MainWindowHandle , $WindowStates[$State])
}
$MainWindowHandle = (Get-Process -Name notepad | Where-Object -FilterScript {$_.MainWindowHandle -ne 0}).MainWindowHandle
$MainWindowHandle | WindowState -State HIDE

# Функция для нахождения буквы диска, когда файл находится в известной папке, но не известна буква диска. Подходит, когда файл располагается на USB-носителе
function Get-ResolvedPath
{
	[CmdletBinding()]
	param
	(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $true
		)]
		[string]
		$Path
	)

	$DriveLetter = (Get-Disk | Where-Object -FilterScript {$_.BusType -eq "USB"} | Get-Partition | Get-Volume | Where-Object -FilterScript {$null -ne $_.DriveLetter}).DriveLetter
	$DriveLetter | ForEach-Object -Process {[string]$_ + ":\" + $Path}
}
Get-ResolvedPath -Path "Программы\Прочее" | Copy-Item -Destination $env:SystemRoot\Cursors -Force

# Установить бронзовый курсор из Windows XP
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
if (-not ("SystemParamInfo.WinAPICall" -as [type]))
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
$Key = @"
RAR registration data
"@
Set-Content -Path $Path\file.ini -Value $Key -Encoding Unicode -Force

# Удалить первые $c буквы в названиях файлов в папке
$Path = "D:\folder"
$Extension = "flac"
$Characters = 4
(Get-ChildItem -LiteralPath $Path -Filter *.$Extension) | Rename-Item -NewName {$_.Name.Substring($Characters)}

# Удалить последние $c буквы в названиях файлов в папке
$Path = "D:\folder"
$Extension = "flac"
$Characters = 4
Get-ChildItem -LiteralPath $Path -Filter *.$Extension | Rename-Item -NewName {$_.Name.Substring(0,$_.BaseName.Length-$Characters) + $_.Extension}

# Найти файлы, в названии которых каждое слово не написано с заглавной буквы
$Path = "D:\folder"
(Get-ChildItem -LiteralPath $Path -File -Recurse | Where-Object -FilterScript {($_.BaseName -replace "'|``") -cmatch "\b\p{Ll}\w*"}).FullName

# Записать прописными буквами первую букву каждого слова в названии каждого файла в папке
$Path = "D:\folder"
$Extension = "flac"
Get-ChildItem -Path $Path -Filter *.$Extension | Rename-Item -NewName {(Get-Culture).TextInfo.ToTitleCase($_.BaseName) + $_.Extension}

# Перевод первых букв в верхний регистр (капитализация)
$String = "аа аа аа"
(Get-Culture).TextInfo.ToTitleCase($String.ToLower())

# Подсчитать количество символов в строке
("string" | Measure-Object -Character).Characters

# Заменить слово в названии файлов в папке
Get-ChildItem -Path "D:\folder" | Rename-Item -NewName {$_.Name.Replace("abc","cba")}

# Переименовать расширения в папке
$Path = "D:\folder"
Get-ChildItem -Path $Path | Rename-Item -NewName {$_.FullName.Replace(".txt1",".txt")}

# Добавить REG_NONE
New-ItemProperty -Path HKCU:\Software -Name Name -PropertyType None -Value ([byte[]]@()) -Force

# Скачать видео с помощью youtube-dl
# https://github.com/ytdl-org/youtube-dl/releases
# https://ffmpeg.zeranoe.com/builds
# "D:\youtube-dl.exe" --list-formats url
$URLs = @(
	"",
	""
)
# --format 43+35 url
# --username $username
# --password $password
# --video-password $videopassword
$youtubedl = "D:\Downloads\youtube-dl.exe"
$output = "D:\"
$title = "%(title)s.mp4"

$n = 1
foreach ($URL in $URLs)
{
	# 1. FileName.mp4
	$FileName = "{0}. {1}" -f $n++, $title
	Start-Process -FilePath $youtubedl -ArgumentList "--output `"$output\$FileName`" --format 136+251 $url"
}

# Binary
"50,33,01".Split(",") | ForEach-Object -Process {"0x$_"}
#
$int = 0x6054b50
$bytes = [System.BitConverter]::GetBytes($int)
$int = [System.BitConverter]::ToInt32($bytes, 0)
'0x{0:x}' -f $int

# Отключить сетевые протоколы
$ComponentIDs = @(
	"ms_tcpip6"
	"ms_pacer"
)
Disable-NetAdapterBinding -Name Ethernet -ComponentID $ComponentIDs

# Вычислить продолжительность видеофайлов в папке
# http://code.avalon-zone.be/retrieve-the-extended-attibutes-of-a-file
function Get-Duration
{
	[CmdletBinding()]
	[OutputType([string])]
	Param
	(
		[Parameter(Mandatory = $true)]
		$Path,
		$Extention
	)

	$Shell = New-Object -ComObject Shell.Application
	$TotalDuration = [timespan]0
	Get-ChildItem -Path $Path -Filter "*.$Extention" | ForEach-Object -Process {
		$Folder = $Shell.Namespace($_.DirectoryName)
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
# (Get-Duration -Path D:\folder -Extention mp4 | Sort-Object Duration | Out-String).Trim()


# Найти неустановленные обновления
$UpdateSession = New-Object -ComObject Microsoft.Update.Session
$UpdateSearcher = $UpdateSession.CreateupdateSearcher()
$Updates = @($UpdateSearcher.Search("IsHidden=0 and IsInstalled=0").Updates)
$Updates | Select-Object Title

# Закрыть определенное окно Проводника
$FolderName = "D:\folder"
(New-Object -ComObject "Shell.Application").Windows() | Where-Object {$_.Document.Folder.Self.Path -eq $FolderName} | ForEach-Object -Process {$_.Quit()}

# StartsWith/EndsWith
$String = "1234"
$String.StartsWith("1")
$String.EndsWith("4")

# Глаголы ярлыка в контекстном меню
$Target = Get-Item -Path "D:\folder\file.lnk"
$Shell = New-Object -ComObject Shell.Application
$Folder = $Shell.NameSpace($Target.DirectoryName)
$file = $Folder.ParseName($Target.Name)
$Verb = $File.Verbs() | Where-Object -FilterScript {$_.Name -like "Закрепить на начальном &экране"}
$Verb.DoIt()

# Конвертировать хэш-таблицу в объекты
$hash = @{
	Name = 'Tobias'
	Age = 66
	Status = 'Online'
}
New-Object -TypeName PSObject -Property $hash

# Кодирование строки в Base64 и обратно
[Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes("SecretMessage"))
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("U2VjcmV0TWVzc2FnZQ=="))

# Удалить неудаляемый ключ в реестре
$parent = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.ps1', $true)
$parent.DeleteSubKey('UserChoice', $true)
$parent.Close()

# Показания накопителей
Get-PhysicalDisk | Get-StorageReliabilityCounter | Select-Object -Property *

# Что запускается автоматически
Get-EventLog -LogName System -InstanceId 1073748869 | ForEach-Object {
	[PSCustomObject]@{
		Date = $_.TimeGenerated
		Name = $_.ReplacementStrings[0]
		Path = $_.ReplacementStrings[1]
		StartMode = $_.ReplacementStrings[3]
		User = $_.ReplacementStrings[4]
	}
}

# break, continue, return, exit
function Test-Function
{
	$fishtank = 1..10
	foreach ($fish in $fishtank)
	{
		if ($fish -eq 7)
		{
			# break		# abort loop
			# continue	# skip just this iteration, but continue loop
			# return	# abort code, and continue in caller scope
			# exit		# abort code at caller scope
		}
		"fishing fish #$fish"
	}
	"Done"
}
Test-Function
"Script done"

# Найти все процессы notepad, сконвертировать в массив и убить процессы
@(Get-Process -Name Notepad).ForEach({Stop-Process -InputObject $_})

# Проверить, сходятся ли хэш-суммы из файла .cat с хэш-суммами файлов в папке
$HT = @{
	CatalogFilePath = "D:\file.cat"
	Path = "D:\folder"
	Detailed = $true
	FilesToSkip = "file.xml"
}
Test-FileCatalog @HT

# Спец. символы
# Null `0
# Alert`a
# Backspace`b
# Form feed`f
# New line`n
# Carriage return`r
# Horizontal tab`t
# Vertical tab`v
# Stop parsing --%

# Оператор -format
$Processes = Get-Process | Sort-Object -Property CPU -Descending | Select-Object -First 10
foreach ($Process in $Processes)
{
	"{0,-10} {1,10}" -f $Process.ProcessName, $Process.CPU
}

# JSON
# Список
$JSON = @{}
$basket = @(
	"apples",
	"pears"
)
$JSON | Add-Member -MemberType NoteProperty -Name Data -Value $basket -Force
$JSON | ConvertTo-Json

# Массив
$JSON = @{}
$array = @{}
$person = @{
	"Name" = "Matt"
	"Colour" = "Black"
}
$array.Add("Person",$person)
#$array | Add-Member -MemberType NoteProperty -Name Person -Value $person -Force
$JSON | Add-Member -MemberType NoteProperty -Name Data -Value $array -Force
$JSON | ConvertTo-Json -Depth 4

# Комбинирование списка с массивом
$JSON = @{}
$basket = @{
	"Basket" = "apples","pears","oranges","strawberries"
}
$JSON | Add-Member -MemberType NoteProperty -Name Data -Value $basket -Force
$JSON | ConvertTo-Json

# Список содержит массив
$JSON = @{}
$list = New-Object -TypeName System.Collections.ArrayList
$list.Add(@{
	"Name" = "John"
	"Surname" = "Smith"
	"OnSubscription" = $true
})
$list.Add(@{
	"Name2" = "John"
	"Surname2" = "Smith"
	"OnSubscription2" = $true
})
$customers = @{
	"Customers" = $list
}
$JSON | Add-Member -MemberType NoteProperty -Name Data -Value $customers -Force
$JSON | ConvertTo-Json -Depth 4

# Вложенные уровени
$JSON = @{}
$Lelevs = @{
	Level2 = @{
		Level3 = @{
			Level4 = @{
				P1 = "T1"
			}
		}
	}
}
$JSON | Add-Member -MemberType NoteProperty -Name Level1 -Value $Lelevs
$JSON | ConvertTo-Json -Depth 4
#
$edge = Get-Content -Path "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Preferences" | ConvertFrom-Json
$alternate_urls = @(
	"{google:baseURL}#q={searchTerms}",
	"{google:baseURL}search#q={searchTerms}"
)
$Google = @{
	template_url_data = @{
		"alternate_urls" = $alternate_urls
		"contextual_search_url" = "{google:baseURL}_/contextualsearch?{google:contextualSearchVersion}{google:contextualSearchContextData}"
	}
}
$edge | Add-Member -MemberType NoteProperty -Name default_search_provider_data -Value $Google -Force

ConvertTo-Json -InputObject $edge | Set-Content -Path "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Preferences" -Force

# Сбросить пароль локального пользователя через WinPE
# WinPE
MOVE C:\Windows\system32\utilman.exe C:\Windows\system32\utilman.exe.bak
RENAME C:\Windows\system32\utilman.exe utilman.exe.bak
COPY C:\Windows\system32\cmd.exe C:\Windows\system32\utilman.exe
wpeutil reboot
#
$user = (Get-LocalUser | Where-Object -FilterScript {$_.Enabled}).Name
$user
$Password = Read-Host -Prompt "Enter the new password" -AsSecureString
Get-LocalUser -Name $user | Set-LocalUser -Password $Password
# WinPE
DEL C:\Windows\system32\utilman.exe /F
RENAME C:\Windows\system32\utilman.exe.bak utilman.exe

# Восстановление компонентов хранилища
DISM /Online /Cleanup-Image /RestoreHealth

# Восстановление компонентов хранилища локально
DISM /Get-WimInfo /WimFile:E:\sources\install.wim
DISM /Online /Cleanup-Image /RestoreHealth /Source:E:\sources\install.wim:3 /LimitAccess
# Восстановление системных файлов
sfc /scannow

# Восстановление компонентов хранилища в среде Windows PE
DISM /Get-WimInfo /WimFile:E:\sources\install.wim
DISM /Image:C:\ /Cleanup-Image /RestoreHealth /Source:E:\sources\install.wim:3 /ScratchDir:C:\mnt
# Восстановление системных файлов в среде Windows PE
sfc /scannow /offbootdir=C:\ /offwindir=C:\Windows

# Очистка папки WinSxS
DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase

# Операторы Google
Только на указанном сайте: site:site.ru
В заголовке страницы: intitle:"index of"
В тексте страницы: intext:текст
В тексте url: inurl:текст
В тексте ссылок: inanchor:текст
По расширению ext:pdf
Со схожей тематикой: related:site.ru
Ссылки на данный ресурс: link:site.ru
Кэш страницы: cache:site.ru
Точная фраза: "site"
Любой текст: *pedia.org
Логическое ИЛИ: site1 | site2
Логическое НЕ: error -warning
Диапазон: cve 2006..2016

# Проверка: был ли скрипт сохранен в кодировке UTF-8 c BOM, если он запускается локально
if ($PSCommandPath)
{
	$bytes = Get-Content -Path $PSCommandPath -Encoding Byte -Raw
	if ($bytes[0] -ne 239 -and $bytes[1] -ne 187 -and $bytes[2] -ne 191)
	{
		Write-Warning -Message "The script wasn't saved in `"UTF-8 with BOM`" encoding"
		break
	}
}

# Write-Progress
$ExcludedAppxPackages = @(
	# ...
	# Панель управления NVidia
	"NVIDIACorp.NVIDIAControlPanel"
)
$OFS = "|"
$AppxPackages = (Get-AppxPackage -PackageTypeFilter Bundle -AllUsers).Name | Select-String $ExcludedAppxPackages -NotMatch
foreach ($AppxPackage in $AppxPackages)
{
	Write-Progress -Activity "Uninstalling UWP apps" -Status "Removing $AppxPackage" -PercentComplete ($AppxPackages.IndexOf($AppxPackage)/$AppxPackages.Count * 100)
	Get-AppxPackage -PackageTypeFilter Bundle -AllUsers | Where-Object -FilterScript {$_.Name -cmatch $AppxPackage} | Remove-AppxPackage -AllUsers
}
Write-Progress -Activity "Uninstalling UWP apps" -Completed

#
$Fruits = "Apple","Pear","Banana","Orange"
$Fruits.GetType()

$Fruits.Add("Kiwi")
$Fruits.Remove("Apple")
$Fruits.IsFixedSize

[System.Collections.ArrayList]$ArrayList = $Fruits
$ArrayList.GetType()

$ArrayList.Add("Kiwi")
$ArrayList
$ArrayList.Remove("Apple")
$ArrayList

# Конвертировать массив в System.Collections.ObjectModel.Collection`1
$Collection = {$Fruits}.Invoke()
$Collection
$Collection.GetType()

$Collection.Add("Melon")
$Collection
$Collection.Remove("Apple")
$Collection

# Ожидание процесса
do
{
	$Process = Get-Process -Name notepad
	if ($Process)
	{
		Write-Host "Running: $($Process.Name)"
		Start-Sleep -Milliseconds 500
	}
}
until (-not ($Process))
#
while ($true)
{
	$Process = Get-Process -Name notepad
	if ($Process)
	{
		Write-Host "Running: $($Process.Name)"
		Start-Sleep -Milliseconds 500
	}
}
#
$Process = Get-Process -Name notepad
while
(
	$($Process.Refresh()
	$Process.ProcessName)
)
{
	Write-Host "Running: $($Process.Name)"
	Start-Sleep -Milliseconds 500
}

# Цикл
Write-Host ""
do
{
	$Prompt = Read-Host -Prompt " "
	if ([string]::IsNullOrEmpty($Prompt))
	{
		break
	}
	else
	{
		switch ($Prompt)
		{
			"Y" {}
			"N" {}
			Default {}
		}
	}
}
while ($Prompt -ne "N")

# Сравнить бинарные значения
((Get-ItemPropertyValue -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer -Name link) -join " ") -ne ([byte[]](00, 00, 00, 00) -join " ")

# Ключ из UEFI
(Get-CimInstance -ClassName SoftwareLicensingService).OA3xOriginalProductKey

# Активация Windows
slmgr.vbs /skms <servername>
slmgr.vbs /ato


# Получить имя исключения при ошибке
$Error[0].Exception.GetType().FullName

# Закрыть все папки, не убивая процесс explorer.exe
(New-Object -ComObject Shell.Application).Windows() | Where-Object {$null -ne $_.FullName} | Where-Object {$_.FullName.EndsWith("\explorer.exe") } | ForEach-Object -Process {$_.Quit()}

# Вывести таблицу с количеством строк и названием файлов в подпапке. -Raw читает файл с пустыми строками
$FullName = @{
	Name = "File"
	Expression = {$_.FullName}
}
$Lines = @{
	Name = "Lines"
	Expression = {Get-Content -Path $_ -Raw | Measure-Object -Line | Select-Object -ExpandProperty Lines}
}
Get-ChildItem -Path "D:\Sophia\*\*" -File -Filter *.psd1 -Force | ForEach-Object -Process {$_ | Select-Object -Property $FullName, $Lines} | Format-Table -AutoSize

# Вывести описание ошибки
function Convert-Error ([int]$ErrorCode)
{
	CertUtil -error $ErrorCode
	"`n"
	New-Object -TypeName System.ComponentModel.Win32Exception($ErrorCode)
}
Convert-Error -2147287037

# Удалить строки в файле, начинающиеся с "//", удалив также оставшиеся пустые строки
Get-Content -Path $settings | Where-Object -FilterScript {$_ -notmatch "//"} | Where-Object -FilterScript {$_.Trim(" `t")} | Set-Content -Path $settings -Force

# Поставить кавычки на каждом элементе
Get-Content -Path D:\file.txt -Force | ForEach-Object -Process {"'$_'"} | Set-Content -Path D:\file.txt -Force
