exit
# PSScriptAnalyzer
Install-PackageProvider -Name NuGet -Force
Install-Module -Name PSScriptAnalyzer -Force
Set-ExecutionPolicy -ExecutionPolicy Bypass -Force
Import-Module PSScriptAnalyzer
Save-Module -Name PSScriptAnalyzer -Path D:\
Invoke-ScriptAnalyzer -Path "D:\Программы\Прочее\ps1\*.ps1" | Where-Object -FilterScript {$_.RuleName -ne "PSAvoidUsingWriteHost"}

# Перерегистрация всех UWP-приложений
(Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\InboxApplications | Get-ItemProperty).Path | Add-AppxPackage -Register -DisableDevelopmentMode

# Установка Microsoft Store из appxbundle
# SW_DVD9_NTRL_Win_10_1903_32_64_ARM64_MultiLang_App_Update_X22-01657.ISO
# https://store.rg-adguard.net CategoryID: 64293252-5926-453c-9494-2d4021f1c78d
Add-AppxPackage -Path D:\Microsoft.DesktopAppInstaller.appxbundle
Add-AppxPackage -Path D:\Microsoft.StorePurchaseApp.appxbundle

# Разрешить подключаться одноуровневому домену
New-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters -Name AllowSingleLabelDnsDomain -Value 1 -Force

# Включение в Планировщике задач удаление устаревших обновлений Office, кроме Office 2019
$action = New-ScheduledTaskAction -Execute powershell.exe -Argument @"
	`$getservice = Get-Service -Name wuauserv
	`$getservice.WaitForStatus('Stopped', '01:00:00')
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
	Start-Sleep -Seconds 60
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
Get-WinEvent -FilterHashtable @{
	LogName = "Windows PowerShell"
	ProviderName = "PowerShell"
	Id = "800"
} | Where-Object -FilterScript {$_.Level -eq "3" -or $_.Level -eq "4"}
#
Get-WinEvent -LogName "Windows PowerShell" | Where-Object -FilterScript {$_.Message -match "HostApplication=(?<a>.*)"} | Format-List -Property *
#
Get-EventLog -LogName "Windows PowerShell" -InstanceId 10 | Where-Object -FilterScript {$_.Message -match "powershell.exe"}
#
$NewProcessName = @{
	Name = "NewProcessName"
	Expression = {$_.Properties[5].Value}
}
$CommandLine = @{
	Name = "CommandLine"
	Expression = {$_.Properties[8].Value}
}
Get-WinEvent -FilterHashtable @{
	LogName = "Security"
	# A new process has been created
	ID = 4688
} | Select-Object TimeCreated, $NewProcessName, $CommandLine
#
function Get-ProcessAuditEvents ([long] $MaxEvents)
{
	function Prettify([string] $Message)
	{
		$Message = [regex]::Replace( $Message, '\s+Token Elevation Type indicates.+$', '', [System.Text.RegularExpressions.RegexOptions]::Singleline)
		$Message = [regex]::Replace( $Message, '(Token Elevation Type:\s+%%1936)', '$1 (Full token)')
		$Message = [regex]::Replace( $Message, '(Token Elevation Type:\s+%%1937)', '$1 (Elevated token)')
		$Message = [regex]::Replace( $Message, '(Token Elevation Type:\s+%%1938)', '$1 (Limited token)')
		return $Message
	}
	Get-WinEvent -MaxEvents $MaxEvents -FilterHashtable @{
		LogName = "Security"
		Id = 4688
	} | Sort-Object -Property TimeCreated | ForEach-Object {
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
# Передача больших файлов по медленным и нестабильным сетям
# Нагружает диск
Import-Module BitsTransfer
Start-BitsTransfer -Source $url -Destination $output
# Start-BitsTransfer -Source $url -Destination $output -Asynchronous

# Исполнить код по ссылке
$url = "https://site.com/1.js"
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
Get-FileHash -Path D:\1.txt -Algorithm MD5

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
"@
Set-Content -Path "$env:ProgramFiles\WinRAR\rarreg.key" -Value $rarregkey -Encoding Unicode -Force

# Удалить первые $c буквы в названиях файлов в папке
$path = "D:\folder"
$e = "flac"
$c = 4
(Get-ChildItem -LiteralPath $path -Filter *.$e) | Rename-Item -NewName {$_.Name.Substring($c)}

# Удалить последние $c буквы в названиях файлов в папке
$path = "D:\folder"
$e = "flac"
$c = 4
Get-ChildItem -LiteralPath $path -Filter *.$e | Rename-Item -NewName {$_.Name.Substring(0,$_.BaseName.Length-$c) + $_.Extension}

# Найти файлы, в названии которых каждое слово не написано с заглавной буквы
$path = "D:\folder"
(Get-ChildItem -LiteralPath $path -File -Recurse | Where-Object -FilterScript {($_.BaseName -replace "'|``") -cmatch "\b\p{Ll}\w*"}).FullName

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
# --list-formats url (in PS)
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
$FolderName = "D:\folder"
(New-Object -ComObject "Shell.Application").Windows() | Where-Object {$_.Document.Folder.Self.Path -eq $FolderName} | ForEach-Object -Process {$_.Quit()}

# StartsWith/EndsWith
$str = "1234"
$str.StartsWith("1")
$str.EndsWith("4")

# Контекстное меню файла
$Target = Get-Item -Path "D:\folder\file.lnk"
$shell = New-Object -ComObject Shell.Application
$folder = $shell.NameSpace($target.DirectoryName)
$file = $folder.ParseName($Target.Name)
$verb = $file.Verbs() | Where-Object -FilterScript {$_.Name -like "Закрепить на начальном &экране"}
$verb.DoIt()

# Конвертировать хэш-таблицу в объекты
$hash = @{
	Name = 'Tobias'
	Age = 66
	Status = 'Online'
}
New-Object PSObject -Property $hash

# Кодирование строки в Base64 и обратно
[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("SecretMessage"))
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

# Оператор -f
$proc = Get-Process | Sort-Object -Property CPU -Descending | Select-Object -First 10
foreach ($p in $proc)
{
	"{0,-10} {1,10}" -f $p.ProcessName, $p.CPU
}

# Без escape ("`"$FileName`"")
$Folder = "${env:ProgramFiles}\Folder\SubFolder"
$Argument = '"{0}"' -f $Folder
Start-Process -FilePath utility.exe -ArgumentList $Argument

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
$list = New-Object System.Collections.ArrayList
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
# Восстановление компонентов хранилища в среде Windows PE
DISM /Get-WimInfo /WimFile:E:\sources\install.wim
DISM /Image:C:\ /Cleanup-Image /RestoreHealth /Source:E:\sources\install.wim:3 /ScratchDir:C:\mnt
# Восстановление системных файлов
sfc /scannow
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

# Включить режим питания
$PowerPlan = Get-CimInstance -Namespace root\cimv2\power -ClassName Win32_PowerPlan | Where-Object -FilterScript {$_.Elementname -eq "Высокая производительность"}
Invoke-CimMethod -InputObject $PowerPlan -MethodName Activate

# Выключить режим гибернации ###
$ActivePowerPlanInstanceID = (Get-CimInstance -Namespace root\cimv2\power -ClassName Win32_PowerPlan | Where-Object -FilterScript {$_.IsActive -eq $true}).InstanceID.Split("\")[1]
$HibernateAfterInstanceID = (Get-CimInstance -Namespace root\cimv2\power -ClassName Win32_PowerSetting | Where-Object -FilterScript {$_.Elementname -eq "Hibernate after"}).InstanceID.Split("\")[1]
Get-CimInstance -Namespace root\cimv2\power -ClassName Win32_PowerSettingDataIndex | Where-Object -FilterScript {$_.InstanceID -eq "Microsoft:PowerSettingDataIndex\$ActivePowerPlanInstanceID\AC\$HibernateAfterInstanceID"} | Set-CimInstance -Property @{SettingIndexValue = 0}

# Функция исключить папку из сканирования Microsoft Defender
function ExclusionPath
{
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory = $true)]
		[string[]]$Paths
	)
	$Paths = $Paths.Replace("`"", "").Split(",").Trim()
	Add-MpPreference -ExclusionPath $Paths -Force
}

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