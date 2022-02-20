# ABBYY FineReader
if (Test-Path -Path "${env:ProgramFiles(x86)}\ABBYY FineReader 15")
{
	if (-not (Test-Path -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\ABBYY FineReader 15 OCR-редактор.lnk"))
	{
		Copy-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\ABBYY FineReader 15\ABBYY FineReader 15 OCR-редактор.lnk" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force -ErrorAction Ignore
	}
	Remove-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\ABBYY FineReader 15" -Recurse -Force -ErrorAction Ignore

	Remove-Printer -Name *ABBYY* -ErrorAction Ignore
}

# AIMP
if (Test-Path -Path "${env:ProgramFiles(x86)}\AIMP")
{
	if (-not (Test-Path -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\AIMP.lnk"))
	{
		Copy-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\AIMP\AIMP*.lnk" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force -ErrorAction Ignore
	}

	$Remove = @(
		"$env:PUBLIC\Desktop\AIMP.lnk",
		"$env:ProgramData\Microsoft\Windows\Start Menu\Programs\AIMP",
		"${env:ProgramFiles(x86)}\AIMP\!Backup",
		"${env:ProgramFiles(x86)}\AIMP\history.txt",
		"${env:ProgramFiles(x86)}\AIMP\AIMP.url",
		"${env:ProgramFiles(x86)}\AIMP\license.rtf",
		"${env:ProgramFiles(x86)}\AIMP\Help",
		"${env:ProgramFiles(x86)}\AIMP\Skins",
		"${env:ProgramFiles(x86)}\AIMP\Plugins\aimp_AnalogMeter",
		"${env:ProgramFiles(x86)}\AIMP\Plugins\aimp_infobar",
		"${env:ProgramFiles(x86)}\AIMP\Plugins\aimp_lastfm",
		"${env:ProgramFiles(x86)}\AIMP\Plugins\aimp_scheduler",
		"${env:ProgramFiles(x86)}\AIMP\Plugins\Aorta"
	)
	Remove-Item -Path $Remove -Recurse -Force -ErrorAction Ignore

	Get-ChildItem -Path "${env:ProgramFiles(x86)}\AIMP\Langs" -Exclude russian.lng -Force | Remove-Item -Force

	$Arguments = @(
		# Disable the context menu integration
		"/REG=M0"
		# Associate files with AIMP
		"/REG=R1"
		# Make AIMP a default audio player
		"/REG=R2"
	)
	Start-Process -FilePath "${env:ProgramFiles(x86)}\AIMP\Elevator.exe" -ArgumentList $Arguments

	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

	$Parameters = @{
		Uri             = "https://raw.githubusercontent.com/farag2/Utilities/master/AIMP/AIMP.ini"
		OutFile         = "$env:APPDATA\AIMP\AIMP.ini"
		UseBasicParsing = $true
		Verbose         = $true
	}
	Invoke-WebRequest @Parameters

	$Parameters = @{
		Uri             = "https://raw.githubusercontent.com/farag2/Utilities/master/AIMP/AIMPac.ini"
		OutFile         = "$env:APPDATA\AIMP\AIMPac.ini"
		UseBasicParsing = $true
		Verbose         = $true
	}
	Invoke-WebRequest @Parameters

	# Save the current ID in the variable
	$ID = Get-Content -Path "$env:APPDATA\AIMP\Skins\Default.ini" | Select-Object -Index 1

	$Parameters = @{
		Uri             = "https://raw.githubusercontent.com/farag2/Utilities/master/AIMP/Default.ini"
		OutFile         = "$env:APPDATA\AIMP\Skins\Default.ini"
		UseBasicParsing = $true
		Verbose         = $true
	}
	Invoke-WebRequest @Parameters

	$Defaultini = Get-Content -Path "$env:APPDATA\AIMP\Skins\Default.ini" -Encoding Default
	$Defaultini[1] = $ID
	$Defaultini | Set-Content -Path "$env:APPDATA\AIMP\Skins\Default.ini" -Encoding Default -Force
}

# CCleaner
if (Test-Path -Path "$env:ProgramFiles\CCleaner")
{
	Stop-Process -Name CCleaner64 -Force -ErrorAction Ignore

	if (-not (Test-Path -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\CCleaner.lnk"))
	{
		Copy-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\CCleaner\CCleaner.lnk" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force
	}

	$Remove = @(
		"$env:ProgramData\Microsoft\Windows\Start Menu\Programs\CCleaner",
		"$env:ProgramFiles\CCleaner\CCleaner.exe",
		"$env:ProgramFiles\CCleaner\CCUpdate.exe",
		"$env:PUBLIC\Desktop\CCleaner.lnk",
		"$env:ProgramFiles\CCleaner\Setup",
		"Registry::HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\*CCleaner*"
	)
	Remove-Item -Path $Remove -Recurse -Force -ErrorAction Ignore

	Remove-Item -Path "$env:ProgramFiles\CCleaner\Lang" -Exclude lang-1049.dll -Recurse -Force -ErrorAction Ignore
	Unregister-ScheduledTask -TaskName *CCleaner* -Confirm:$false
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "CCleaner Smart Cleaning" -Force -ErrorAction Ignore

	$Parameters = @{
		Uri             = "https://raw.githubusercontent.com/farag2/Utilities/master/CCleaner/ccleaner.ini"
		OutFile         = "$env:ProgramFiles\CCleaner\ccleaner.ini"
		UseBasicParsing = $true
		Verbose         = $true
	}
	Invoke-WebRequest @Parameters
}

# CUE Splitter
if (Test-Path -Path "${env:ProgramFiles(x86)}\Medieval Software\Medieval CUE Splitter")
{
	Copy-Item -Path "${env:ProgramFiles(x86)}\Medieval Software\Medieval CUE Splitter" -Destination "${env:ProgramFiles(x86)}" -Recurse -Force

	$Remove = @(
		"${env:ProgramFiles(x86)}\Medieval Software",
		"${env:ProgramFiles(x86)}\Medieval CUE Splitter\FLAG",
		"${env:ProgramFiles(x86)}\Medieval CUE Splitter\LANG",
		"${env:ProgramFiles(x86)}\Medieval CUE Splitter\Freeware.html"
	)
	Remove-Item -Path $Remove -Recurse -Force -ErrorAction Ignore

	if (-not (Test-Path -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Medieval CUE Splitter.lnk"))
	{
		Move-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Medieval Software\Medieval CUE Splitter\Medieval CUE Splitter v1.2.lnk" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force
		Rename-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Medieval CUE Splitter v1.2.lnk" -NewName "Medieval CUE Splitter.lnk" -Force
	}
	Remove-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Medieval Software" -Recurse -Force -ErrorAction Ignore
	Remove-Item -Path "$env:PUBLIC\Desktop\Medieval CUE Splitter.lnk" -Force -ErrorAction Ignore

	if (-not (Test-Path -Path "HKCU:\Software\Medieval\CUE Splitter\Config"))
	{
		New-Item -Path "HKCU:\Software\Medieval\CUE Splitter\Config" -Force
	}
	if (-not (Test-Path -Path "HKCU:\Software\Medieval\CUE Splitter\FileMask"))
	{
		New-Item -Path "HKCU:\Software\Medieval\CUE Splitter\FileMask" -Force
	}
	New-ItemProperty -Path "HKCU:\Software\Medieval\CUE Splitter" -Name FirstTimeAssociation -Value 821760 -Force
	New-ItemProperty -Path "HKCU:\Software\Medieval\CUE Splitter\Config" -Name CheckUpdates -Value 0 -Force
	New-ItemProperty -Path "HKCU:\Software\Medieval\CUE Splitter\Config" -Name SaveStatus -Value 0 -Force
	New-ItemProperty -Path "HKCU:\Software\Medieval\CUE Splitter\Config" -Name M3U -Value 0 -Force
	New-ItemProperty -Path "HKCU:\Software\Medieval\CUE Splitter\Config" -Name M3U_Mask -Value 0 -Force
	New-ItemProperty -Path "HKCU:\Software\Medieval\CUE Splitter\Config" -Name CUE -Value 0 -Force
	New-ItemProperty -Path "HKCU:\Software\Medieval\CUE Splitter\Config" -Name CUE_Mask -Value 0 -Force
	New-ItemProperty -Path "HKCU:\Software\Medieval\CUE Splitter\Config" -Name Mask_Count -Value 1 -Force
	New-ItemProperty -Path "HKCU:\Software\Medieval\CUE Splitter\Config" -Name CodePage -Value 138 -Force
	New-ItemProperty -Path "HKCU:\Software\Medieval\CUE Splitter\Config" -Name CUE_Coding -Value 1 -Force
	New-ItemProperty -Path "HKCU:\Software\Medieval\CUE Splitter\FileMask" -Name Name_0 -PropertyType String -Value Default -Force
	New-ItemProperty -Path "HKCU:\Software\Medieval\CUE Splitter\FileMask" -Name Text_0 -PropertyType String -Value "%t" -Force

	$Shell = New-Object -ComObject Wscript.Shell
	$Shortcut = $Shell.CreateShortcut("$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Medieval CUE Splitter.lnk")
	$Shortcut.TargetPath = "${env:ProgramFiles(x86)}\Medieval CUE Splitter\CUE_Splitter.exe"
	$ShortCut.IconLocation = "${env:ProgramFiles(x86)}\Medieval CUE Splitter\CUE_Splitter.exe,0"
	$Shortcut.Save()
}

# Firefox
if (Test-Path -Path "$env:ProgramFiles\Mozilla Firefox")
{
	Remove-Item -Path "$env:PUBLIC\Desktop\Firefox.lnk" -Force -ErrorAction Ignore
}

# Icaros
if (Test-Path -Path "$env:ProgramFiles\Icaros")
{
	$Remove = @(
		"$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Icaros",
		"$env:ProgramFiles\Icaros\README.txt",
		"$env:ProgramFiles\Icaros\Licenses"
	)
	Remove-Item -Path $Remove -Recurse -Force -ErrorAction Ignore

	Remove-Item -Path "$env:ProgramFiles\Icaros\Resources\Localize" -Exclude Config.ru.po -Recurse -Force -ErrorAction Ignore

	if (-not (Test-Path -Path HKLM:\SOFTWARE\Icaros))
	{
		New-Item -Path HKLM:\SOFTWARE\Icaros -Force
	}
	New-ItemProperty -Path HKLM:\SOFTWARE\Icaros -Name "Thumbnail Extensions" -PropertyType String -Value "ape;cb7;cbr;cbz;divx;epub;flac;flv;mk3d;mka;mkv;mpc;ofr;ofs;ogg;ogm;ogv;opus;rm;rmvb;spx;tak;tta;wav;webm;wv;xvid" -Force
	New-ItemProperty -Path HKLM:\SOFTWARE\Icaros -Name "Excluded Properties" -PropertyType String -Value ".mkv;.mk3d;.webm;.ogm;.ogv;.flv;.avi;.divx;.xvid;.rm;.rmvb" -Force
	New-ItemProperty -Path HKLM:\SOFTWARE\Icaros -Name "Prop Local" -PropertyType String -Value "ru" -Force

	Start-Process -FilePath "$env:ProgramFiles\Icaros\IcarosConfig.exe" -ArgumentList "-activate"
}

# MPC-BE
if (Test-Path -Path "$env:ProgramFiles\MPC-BE x64")
{
	$DesktopFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name Desktop
	Remove-Item -Path "$DesktopFolder\MPC-BE x64.lnk" -Force -ErrorAction Ignore

	$Remove = @(
		"$env:ProgramData\Microsoft\Windows\Start Menu\Programs\MPC-BE x64",
		"$env:ProgramFiles\MPC-BE x64\Authors mpc-hc team.txt",
		"$env:ProgramFiles\MPC-BE x64\Authors.txt",
		"$env:ProgramFiles\MPC-BE x64\Changelog.Rus.txt",
		"$env:ProgramFiles\MPC-BE x64\Changelog.txt",
		"$env:ProgramFiles\MPC-BE x64\COPYING.txt",
		"$env:ProgramFiles\MPC-BE x64\Readme.txt"
	)
	Remove-Item -Path $Remove -Recurse -Force -ErrorAction Ignore

	Remove-Item -Path "$env:ProgramFiles\MPC-BE x64\Lang" -Exclude mpcresources.ru.dll -Recurse -Force -ErrorAction Ignore

	$Parameters = @{
		Uri     = "https://raw.githubusercontent.com/farag2/Utilities/master/MPC-BE/mpc-be64.ini"
		OutFile = "$env:ProgramFiles\MPC-BE x64\mpc-be64.ini"
		Verbose = $true
	}
	Invoke-WebRequest @Parameters
}

# Notepad++
if (Test-Path -Path "$env:ProgramFiles\Notepad++")
{
	Stop-Process -Name notepad++ -Force -ErrorAction Ignore

	$Remove = @(
		"$env:ProgramFiles\Notepad++\change.log",
		"$env:ProgramFiles\Notepad++\LICENSE",
		"$env:ProgramFiles\Notepad++\readme.txt",
		"$env:ProgramFiles\Notepad++\autoCompletion",
		"$env:ProgramFiles\Notepad++\plugins"
	)
	Remove-Item -Path $Remove -Recurse -Force -ErrorAction Ignore
	Remove-Item -Path "$env:ProgramFiles\Notepad++\localization" -Exclude russian.xml -Recurse -Force -ErrorAction Ignore

	New-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\CLSID\{B298D29A-A6ED-11DE-BA8C-A68E55D89593}\Settings" -Name Title -PropertyType String -Value "Открыть с помощью &Notepad++" -Force
	New-ItemProperty -Path "HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache" -Name "C:\Program Files\Notepad++\notepad++.exe.FriendlyAppName" -PropertyType String -Value "Notepad++" -Force

	cmd.exe --% /c ftype txtfile=%ProgramFiles%\Notepad++\notepad++.exe "%1"
	cmd.exe --% /c assoc .cfg=txtfile
	cmd.exe --% /c assoc .ini=txtfile
	cmd.exe --% /c assoc .log=txtfile
	cmd.exe --% /c assoc .nfo=txtfile
	cmd.exe --% /c assoc .ps1=txtfile
	cmd.exe --% /c assoc .xml=txtfile
	cmd.exe --% /c assoc txtfile\DefaultIcon=%ProgramFiles%\Notepad++\notepad++.exe,0

	[xml]$config = Get-Content -Path "$env:APPDATA\Notepad++\config.xml" -Force
	# Fluent UI: large
	$config.NotepadPlus.GUIConfigs.GUIConfig | Where-Object -FilterScript {$_.name -eq "ToolBar"} | ForEach-Object -Process {$_."#text" = "large"}
	# Mute all sounds
	$config.NotepadPlus.GUIConfigs.GUIConfig | Where-Object -FilterScript {$_.name -eq "MISC"} | ForEach-Object -Process {$_.muteSounds = "yes"}
	# Show White Space and TAB
	$config.NotepadPlus.GUIConfigs.GUIConfig | Where-Object -FilterScript {$_.name -eq "ScintillaPrimaryView"} | ForEach-Object -Process {$_.whiteSpaceShow = "show"}
	# 2 find buttons mode
	$config.NotepadPlus.FindHistory | ForEach-Object -Process {$_.isSearch2ButtonsMode = "yes"}
	# Wrap around
	$config.NotepadPlus.FindHistory | ForEach-Object -Process {$_.wrap = "yes"}
	# Disable creating backups
	$config.NotepadPlus.GUIConfigs.GUIConfig | Where-Object -FilterScript {$_.name -eq "Backup"} | ForEach-Object -Process {$_.action = "0"}
	$config.Save("$env:APPDATA\Notepad++\config.xml")

	if (-not (Test-Path -Path $env:ProgramFiles\Notepad++\localization))
	{
		New-Item -Path $env:ProgramFiles\Notepad++\localization -ItemType Directory -Force
	}
	$Parameters = @{
		Uri             = "https://raw.githubusercontent.com/farag2/Utilities/master/Notepad%2B%2B/localization/russian.xml"
		OutFile         = "$env:ProgramFiles\Notepad++\localization\russian.xml"
		UseBasicParsing = $true
		Verbose         = $true
	}
	Invoke-WebRequest @Parameters

	# Open the config file to apply all changes
	Start-Process -FilePath "$env:APPDATA\Notepad++\config.xml"
}

# Office
if (Test-Path -Path "$env:ProgramFiles\Microsoft Office\root")
{
	Remove-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Office Tools" -Recurse -Force -ErrorAction Ignore
}

# Paint.net
if (Test-Path -Path "$env:ProgramFiles\paint.net")
{
	Remove-Item -Path "$env:ProgramFiles\paint.net\Resources" -Exclude ru -Recurse -Force -ErrorAction Ignore
	Remove-Item -Path "$env:ProgramFiles\paint.net\License.txt" -Force -ErrorAction Ignore
	Remove-Item -Path "$env:PUBLIC\Desktop\paint.net.lnk" -Force -ErrorAction Ignore

	if (-not (Test-Path -LiteralPath Registry::HKEY_CLASSES_ROOT\*\shell\Paint.NET))
	{
		New-Item -Path Registry::HKEY_CLASSES_ROOT\*\shell\Paint.NET -Force
		New-ItemProperty -LiteralPath Registry::HKEY_CLASSES_ROOT\*\shell\Paint.NET -Name "(Default)" -PropertyType String -Value "Открыть с помощью Paint.NET" -Force

		$Value = "$env:ProgramFiles\Paint.NET\PaintDotNet.exe"
		New-ItemProperty -LiteralPath Registry::HKEY_CLASSES_ROOT\*\shell\Paint.NET -Name Icon -PropertyType String -Value "$Value,0" -Force

		if (-not (Test-Path -LiteralPath Registry::HKEY_CLASSES_ROOT\*\shell\Paint.NET\command))
		{
			New-Item -Path Registry::HKEY_CLASSES_ROOT\*\shell\Paint.NET\command -Force
		}
		New-ItemProperty -LiteralPath Registry::HKEY_CLASSES_ROOT\*\shell\Paint.NET\command -Name "(Default)" -PropertyType String -Value "$Value `"%1`"" -Force
	}
}

# qBittorrent
if (Test-Path -Path "$env:ProgramFiles\qBittorrent")
{
	if (-not (Test-Path -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\qBittorrent.lnk"))
	{
		Copy-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\qBittorrent\qBittorrent.lnk" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force
	}
	Remove-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\qBittorrent" -Recurse -Force -ErrorAction Ignore
	Remove-Item -Path "$env:ProgramFiles\qBittorrent\translations" -Exclude qt_ru.qm, qtbase_ru.qm -Recurse -Force -ErrorAction Ignore

	$Parameters = @{
		Uri             = "https://raw.githubusercontent.com/farag2/Utilities/master/qBittorrent/qBittorrent.ini"
		OutFile         = "$env:APPDATA\qBittorrent\qBittorrent.ini"
		UseBasicParsing = $true
		Verbose         = $true
	}
	Invoke-WebRequest @Parameters

	$LatestVersion = (Invoke-RestMethod -Uri "https://api.github.com/repos/jagannatharjun/qbt-theme/releases/latest").assets.browser_download_url
	$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
	$Parameters = @{
		Uri     = $LatestVersion
		OutFile = "$DownloadsFolder\qbt-theme.zip"
		Verbose = $true
	}
	Invoke-WebRequest @Parameters

	<#
		.SYNOPSIS
		Expand the specific file from ZIP archive. Folder structure will be created recursively

		.Parameter Source
		The source ZIP archive

		.Parameter Destination
		Where to expand file

		.Parameter File
		Assign the file to expand

		.Example
		ExtractZIPFile -Source "D:\Folder\File.zip" -Destination "D:\Folder" -File "Folder1/Folder2/File.txt"
	#>
	function ExtractZIPFile
	{
		[CmdletBinding()]
		param
		(
			[string]
			$Source,

			[string]
			$Destination,

			[string]
			$File
		)

		Add-Type -Assembly System.IO.Compression.FileSystem

		$ZIP = [IO.Compression.ZipFile]::OpenRead($Source)
		$Entries = $ZIP.Entries | Where-Object -FilterScript {$_.FullName -eq $File}

		$Destination = "$Destination\$(Split-Path -Path $File -Parent)"

		if (-not (Test-Path -Path $Destination))
		{
			New-Item -Path $Destination -ItemType Directory -Force
		}

		$Entries | ForEach-Object -Process {[IO.Compression.ZipFileExtensions]::ExtractToFile($_, "$($Destination)\$($_.Name)", $true)}

		$ZIP.Dispose()
	}

	$Parameters = @{
		Source      = "$DownloadsFolder\qbt-theme.zip"
		Destination = "$env:APPDATA\qBittorrent"
		File        = "darkstylesheet.qbtheme"
	}
	ExtractZIPFile @Parameters

	Remove-Item -Path "$DownloadsFolder\qbt-theme.zip" -Force

	# Enable dark theme
	$qbtheme = (Resolve-Path -Path "$env:APPDATA\qBittorrent\darkstylesheet.qbtheme").Path.Replace("\", "/")
	(Get-Content -Path "$env:APPDATA\qBittorrent\qBittorrent.ini" -Encoding Default) -replace "General\\CustomUIThemePath=", "General\CustomUIThemePath=$qbtheme" | Set-Content -Path "$env:APPDATA\qBittorrent\qBittorrent.ini" -Encoding Default -Force
}

# Steam
if (Test-Path -Path "${env:ProgramFiles(x86)}\Steam")
{
	if (-not (Test-Path -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Steam.lnk"))
	{
		Copy-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Steam\Steam.lnk" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force
	}
	Remove-Item -Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Steam" -Recurse -Force -ErrorAction Ignore
	Remove-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Steam" -Recurse -Force -ErrorAction Ignore
	Remove-Item -Path "$env:PUBLIC\Desktop\Steam.lnk" -Force -ErrorAction Ignore
	Remove-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Run -Name Steam -Force -ErrorAction Ignore
}

# VSCode
if (Test-Path -Path "$env:ProgramFiles\Microsoft VS Code")
{
	if (-not (Test-Path -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Visual Studio Code.lnk"))
	{
		Copy-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Visual Studio Code\Visual Studio Code.lnk" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force ###
	}
	Remove-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Visual Studio Code" -Recurse -Force -ErrorAction Ignore
}

# WinRAR
if (Test-Path -Path "$env:ProgramFiles\WinRAR")
{
	if (-not (Test-Path -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\WinRAR.lnk"))
	{
		Copy-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\WinRAR\WinRAR.lnk" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force
	}
	$Remove = @(
		"$env:ProgramData\Microsoft\Windows\Start Menu\Programs\WinRAR",
		"$env:APPDATA\Microsoft\Windows\Start Menu\Programs\WinRAR",
		"$env:ProgramFiles\WinRAR\License.txt",
		"$env:ProgramFiles\WinRAR\Order.htm",
		"$env:ProgramFiles\WinRAR\Rar.txt",
		"$env:ProgramFiles\WinRAR\ReadMe*.txt",
		"$env:ProgramFiles\WinRAR\WhatsNew.txt",
		"$env:ProgramFiles\WinRAR\WinRAR.chm"
	)
	Remove-Item -Path $Remove -Recurse -Force -ErrorAction Ignore

	$Parameters = @{
		Uri     = "https://raw.githubusercontent.com/farag2/Utilities/master/WinRAR/WinRAR/WinRAR.ini"
		OutFile = "$env:ProgramFiles\WinRAR\WinRAR.ini"
		UseBasicParsing = $true
		Verbose         = $true
	}
	Invoke-WebRequest @Parameters

	# Change the file encoding to UTF-16 LE
	(Get-Content -Path "$env:ProgramFiles\WinRAR\WinRAR.ini" -Encoding Default) | Set-Content -Path "$env:ProgramFiles\WinRAR\WinRAR.ini" -Encoding BigEndianUnicode -Force

	# Start WinRAR to apply changes
	Start-Process -FilePath "$env:ProgramFiles\WinRAR\WinRAR.exe" -ArgumentList "-setup_integration" -Wait
}
