# Change location of the user folders programmatically (without moving user files) within interactive menu
# using up/down arrows and Enter key to make a selection 
function KnownFolderPath
{
	param
	(
		[Parameter(Mandatory = $true)]
		[ValidateSet("Desktop", "Documents", "Downloads", "Music", "Pictures", "Videos")]
		[string]
		$KnownFolder,

		[Parameter(Mandatory = $true)]
		[string]
		$Path
	)
	$KnownFolders = @{
		"Desktop"	= @("B4BFCC3A-DB2C-424C-B029-7FE99A87C641");
		"Documents"	= @("FDD39AD0-238F-46AF-ADB4-6C85480369C7", "f42ee2d3-909f-4907-8871-4c22fc0bf756");
		"Downloads"	= @("374DE290-123F-4565-9164-39C4925E467B", "7d83ee9b-2244-4e70-b1f5-5393042af1e4");
		"Music"		= @("4BD8D571-6D19-48D3-BE97-422220080E43", "a0c69a99-21c8-4671-8703-7934162fcf1d");
		"Pictures"	= @("33E28130-4E1E-4676-835A-98395C3BC3BB", "0ddd015d-b06c-45d5-8c4c-f59713854639");
		"Videos"	= @("18989B1D-99B5-455B-841C-AB7C74E4DDFC", "35286a68-3c57-41a1-bbb1-0eae73d76c95");
	}
	$Signature = @{
		Namespace = "WinAPI"
		Name = "KnownFolders"
		Language = "CSharp"
		MemberDefinition = @"
			[DllImport("shell32.dll")]
			public extern static int SHSetKnownFolderPath(ref Guid folderId, uint flags, IntPtr token, [MarshalAs(UnmanagedType.LPWStr)] string path);
"@
	}
	if (-not ("WinAPI.KnownFolders" -as [type]))
	{
		Add-Type @Signature
	}
	foreach ($guid in $KnownFolders[$KnownFolder])
	{
		[WinAPI.KnownFolders]::SHSetKnownFolderPath([ref]$guid, 0, 0, $Path)
	}
	(Get-Item -Path $Path -Force).Attributes = "ReadOnly"
}

function UserShellFolder
{
	param
	(
		[Parameter(Mandatory = $true)]
		[ValidateSet("Desktop", "Documents", "Downloads", "Music", "Pictures", "Videos")]
		[string]
		$UserFolder,

		[Parameter(Mandatory = $true)]
		[string]
		$FolderPath
	)

	$UserShellFoldersRegName = @{
		"Desktop"	=	"Desktop"
		"Documents"	=	"Personal"
		"Downloads"	=	"{374DE290-123F-4565-9164-39C4925E467B}"
		"Music"		=	"My Music"
		"Pictures"	=	"My Pictures"
		"Videos"	=	"My Video"
	}

	$UserShellFoldersGUID = @{
		"Desktop"	=	"{754AC886-DF64-4CBA-86B5-F7FBF4FBCEF5}"
		"Documents"	=	"{F42EE2D3-909F-4907-8871-4C22FC0BF756}"
		"Downloads"	=	"{7D83EE9B-2244-4E70-B1F5-5393042AF1E4}"
		"Music"		=	"{A0C69A99-21C8-4671-8703-7934162FCF1D}"
		"Pictures"	=	"{0DDD015D-B06C-45D5-8C4C-F59713854639}"
		"Videos"	=	"{35286A68-3C57-41A1-BBB1-0EAE73D76C95}"
	}

	$DesktopINI = @{
		"Desktop"	=	"",
						"[.ShellClassInfo]",
						"LocalizedResourceName=@%SystemRoot%\system32\shell32.dll,-21769",
						"IconResource=%SystemRoot%\system32\imageres.dll,-183"
		"Documents"	=	"",
						"[.ShellClassInfo]",
						"LocalizedResourceName=@%SystemRoot%\system32\shell32.dll,-21770",
						"IconResource=%SystemRoot%\system32\imageres.dll,-112",
						"IconFile=%SystemRoot%\system32\shell32.dll",
						"IconIndex=-235"
		"Downloads"	=	"",
						"[.ShellClassInfo]","LocalizedResourceName=@%SystemRoot%\system32\shell32.dll,-21798",
						"IconResource=%SystemRoot%\system32\imageres.dll,-184"
		"Music"		=	"",
						"[.ShellClassInfo]","LocalizedResourceName=@%SystemRoot%\system32\shell32.dll,-21790",
						"InfoTip=@%SystemRoot%\system32\shell32.dll,-12689",
						"IconResource=%SystemRoot%\system32\imageres.dll,-108",
						"IconFile=%SystemRoot%\system32\shell32.dll","IconIndex=-237"
		"Pictures"	=	"",
						"[.ShellClassInfo]",
						"LocalizedResourceName=@%SystemRoot%\system32\shell32.dll,-21779",
						"InfoTip=@%SystemRoot%\system32\shell32.dll,-12688",
						"IconResource=%SystemRoot%\system32\imageres.dll,-113",
						"IconFile=%SystemRoot%\system32\shell32.dll",
						"IconIndex=-236"
		"Videos"	=	"",
						"[.ShellClassInfo]",
						"LocalizedResourceName=@%SystemRoot%\system32\shell32.dll,-21791",
						"InfoTip=@%SystemRoot%\system32\shell32.dll,-12690",
						"IconResource=%SystemRoot%\system32\imageres.dll,-189",
						"IconFile=%SystemRoot%\system32\shell32.dll","IconIndex=-238"
	}

	$UserShellFolderRegValue = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name $UserShellFoldersRegName[$UserFolder]
	if ($UserShellFolderRegValue -ne $FolderPath)
	{
		if ((Get-ChildItem -Path $UserShellFolderRegValue | Measure-Object).Count -ne 0)
		{
			if ($RU)
			{
				Write-Error -Message "В папке $UserShellFolderRegValue осталась файлы. Переместите их вручную в новое расположение" -ErrorAction SilentlyContinue
			}
			else
			{
				Write-Error -Message "Some files left in the $UserShellFolderRegValue folder. Move them manually to a new location" -ErrorAction SilentlyContinue
			}
		}
		if (-not (Test-Path -Path $FolderPath))
		{
			New-Item -Path $FolderPath -ItemType Directory -Force
		}
		KnownFolderPath -KnownFolder $UserFolder -Path $FolderPath
		New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name $UserShellFoldersGUID[$UserFolder] -PropertyType ExpandString -Value $FolderPath -Force
		Set-Content -Path "$FolderPath\desktop.ini" -Value $DesktopINI[$UserFolder] -Encoding Unicode -Force
		(Get-Item -Path "$FolderPath\desktop.ini" -Force).Attributes = "Hidden", "System", "Archive"
		(Get-Item -Path "$FolderPath\desktop.ini" -Force).Refresh()
	}
}

function ShowMenu
{
	param
	(
		[Parameter(Mandatory = $true)]
		[string]
		$Title,

		[Parameter(Mandatory = $true)]
		[array]
		$Menu,

		[Parameter(Mandatory = $true)]
		[int]
		$Default
	)

	Write-Verbose $Title -Verbose

	$minY = [Console]::CursorTop
	$y = [Math]::Max([Math]::Min($Default, $Menu.Count), 0)
	do
	{
		[Console]::CursorTop = $minY
		[Console]::CursorLeft = 0
		$i = 0
		foreach ($item in $Menu)
		{
			$colors = @{
				BackgroundColor = if ($i -ne $y)
				{
					[Console]::BackgroundColor
				}
				else
				{
					"Cyan"
				}
				ForegroundColor = if ($i -ne $y)
				{
					[Console]::ForegroundColor
				}
				else
				{
					"Blue"
				}
			}
			Write-Host (' {0}. {1} ' -f ($i+1), $item) @colors
			$i++
		}
		$k = [Console]::ReadKey()
		switch ($k.Key)
		{
			"UpArrow"
			{
				if ($y -gt 0)
				{
					$y--
				}
			}
			"DownArrow"
			{
				if ($y -lt ($Menu.Count - 1))
				{
					$y++
				}
			}
			"Enter"
			{
				return $Menu[$y]
			}
		}
	}
	while ($k.Key -notin ([ConsoleKey]::Escape, [ConsoleKey]::Enter))
}

$DriveLetters = @((Get-Disk | Where-Object -FilterScript {$_.BusType -ne "USB"} | Get-Partition | Get-Volume | Where-Object -FilterScript {$null -ne $_.DriveLetter}).DriveLetter | Sort-Object)
if ($DriveLetters.Count -gt 1)
{
	# If drive letters count is more than, then make the second drive in the list the default drive
	# Если количество букв дисков больше одного, то сделать второй диск в списке диском по умолчанию
	$Default = 1
}
else
{
	$Default = 0
}

# Desktop
# Рабочий стол
if ($RU)
{
	$Title = "Выберите букву диска, в корне которого будет создана папка для `"Рабочий стол`".`nФайлы не будут перенесены: сделайте это вручную"
}
else
{
	$Title = "Choose the drive letter in the root of which the `"Desktop`" folder will be created.`nFiles will not be moved. Do it manually"
}
$SelectedDrive = ShowMenu -Title $Title -Menu $DriveLetters -Default $Default
UserShellFolder -UserFolder Desktop -FolderPath "${SelectedDrive}:\Desktop"

# Documents
# Документы
if ($RU)
{
	$Title = "Выберите букву диска, в корне которого будет создана папка для `"Документы`".`nФайлы не будут перенесены: сделайте это вручную"
}
else
{
	$Title = "Choose the drive letter in the root of which the `"Documents`" folder will be created.`nFiles will not be moved. Do it manually"
}
$SelectedDrive = ShowMenu -Title $Title -Menu $DriveLetters -Default $Default
UserShellFolder -UserFolder Documents -FolderPath "${SelectedDrive}:\Documents"

# Downloads
# Загрузки
if ($RU)
{
	$Title = "Выберите букву диска, в корне которого будет создана папка для `"Загрузки`""
}
else
{
	$Title = "Choose the drive letter in the root of which the `"Downloads`" folder will be created.`nFiles will not be moved. Do it manually"
}
$SelectedDrive = ShowMenu -Title $Title -Menu $DriveLetters -Default $Default
UserShellFolder -UserFolder Downloads -FolderPath "${SelectedDrive}:\Downloads"

# Music
# Музыка
if ($RU)
{
	$Title = "Выберите букву диска, в корне которого будет создана папка для `"Музыка`".`nФайлы не будут перенесены: сделайте это вручную"
}
else
{
	$Title = "Choose the drive letter in the root of which the `"Music`" folder will be created.`nFiles will not be moved. Do it manually"
}
$SelectedDrive = ShowMenu -Title $Title -Menu $DriveLetters -Default $Default
UserShellFolder -UserFolder Music -FolderPath "${SelectedDrive}:\Music"

# Pictures
# Изображения
if ($RU)
{
	$Title = "Выберите букву диска, в корне которого будет создана папка для `"Изображения`".`nФайлы не будут перенесены: сделайте это вручную"
}
else
{
	$Title = "Choose the drive letter in the root of which the `"Pictures`" folder will be created.`nFiles will not be moved. Do it manually"
}
$SelectedDrive = ShowMenu -Title $Title -Menu $DriveLetters -Default $Default
UserShellFolder -UserFolder Pictures -FolderPath "${SelectedDrive}:\Pictures"

# Videos
# Видео
if ($RU)
{
	$Title = "Выберите букву диска, в корне которого будет создана папка для `"Видео`".`nФайлы не будут перенесены: сделайте это вручную"
}
else
{
	$Title = "Choose the drive letter in the root of which the `"Videos`" folder will be created.`nFiles will not be moved. Do it manually"
}
$SelectedDrive = ShowMenu -Title $Title -Menu $DriveLetters -Default $Default
UserShellFolder -UserFolder Videos -FolderPath "${SelectedDrive}:\Videos"