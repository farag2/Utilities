exit
# Re-register all UWP apps
$Bundles = (Get-AppXPackage -PackageTypeFilter Framework -AllUsers).PackageFullName
Get-ChildItem -Path "HKLM:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\PackageRepository\Packages" | ForEach-Object -Process {
	Get-ItemProperty -Path $_.PSPath
} | Where-Object -FilterScript {$_.Path -match "Program Files"} | Where-Object -FilterScript {$_.PSChildName -notin $Bundles} | Where-Object -FilterScript {$_.Path -match "x64"} | ForEach-Object -Process {
	"$($_.Path)\AppxManifest.xml"
} | Add-AppxPackage -Register -ForceApplicationShutdown -ForceUpdateFromAnyVersion -DisableDevelopmentMode -Verbose
# Check for UWP apps updates
Get-CimInstance -Namespace "Root\cimv2\mdm\dmmap" -ClassName "MDM_EnterpriseModernAppManagement_AppManagement01" | Invoke-CimMethod -MethodName UpdateScanMethod

# Restore all UWP apps
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
# Check for UWP apps updates
Get-CimInstance -Namespace "Root\cimv2\mdm\dmmap" -ClassName "MDM_EnterpriseModernAppManagement_AppManagement01" | Invoke-CimMethod -MethodName UpdateScanMethod

foreach ($Package in $($DamagedPackages | Get-Unique))
{
	Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModel\StateChange\PackageList\$Package" -Force
}

<#
	Install Microsoft Store from appxbundle
	SW_DVD9_NTRL_Win_10_20H2_32_64_ARM64_MultiLang_Inbox_Apps_X22-36106.ISO
	https://store.rg-adguard.net
	https://yadi.sk/d/10Ttj2IVOKQ0Og
#>
Add-AppxPackage -Path D:\Microsoft.DesktopAppInstaller.appxbundle
Add-AppxPackage -Path D:\Microsoft.StorePurchaseApp.appxbundle

# Allow to connect to a single label domain
New-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters -Name AllowSingleLabelDnsDomain -Value 1 -Force

# Find all non-USB & non-boot drives except nulled letter drives (external USB drives are excluded)
(Get-Disk | Where-Object -FilterScript {$_.BusType -ne "USB" -and $_.IsBoot -eq $false} | Get-Partition | Get-Volume | Where-Object -FilterScript {$null -ne $_.DriveLetter}).DriveLetter | ForEach-Object -Process {Join-Path ($_ + ":") $Path}
# Find non-boot drives except nulled letter drives (external USB drives are not excluded)
(Get-Disk | Where-Object -FilterScript {$_.IsBoot -eq $false} | Get-Partition | Get-Volume | Where-Object -FilterScript {$null -ne $_.DriveLetter}).DriveLetter | ForEach-Object -Process {Join-Path ($_ + ":") $Path}
# Find the first USB drive except nulled letter drives
(Get-Disk | Where-Object -FilterScript {$_.BusType -eq "USB"} | Get-Partition | Get-Volume | Where-Object -FilterScript {$null -ne $_.DriveLetter}).DriveLetter | ForEach-Object -Process {Join-Path ($_ + ":") $Path} | Select-Object -First 1

# Add domains to hosts
$hosts = "$env:SystemRoot\System32\drivers\etc\hosts"
$Domains = @("site.com", "site2.com")
foreach ($Domain in $Domains)
{
	if (-not (Get-Content -Path $hosts -Force | Select-String -SimpleMatch "0.0.0.0 `t $Domain"))
	{
		Add-Content -Path $hosts -Value "0.0.0.0 `t $Domain" -Force
	}
}

# Split the name from the path
Split-Path -Path file.ext -Leaf
# Split the path from the name
Split-Path -Path file.ext -Parent
# Split the last folder name from the path
Get-Item -Path file.ext | Split-Path -Parent | Split-Path -Parent | Split-Path -Leaf

# Events categories
enum Level
{
	LogAlways     = 0
	Critical      = 1
	Error         = 2
	Warning       = 3
	Informational = 4
	Verbose       = 5
}
# [Level]::LogAlways.value__
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
# Deprecated
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

# Invoke code
$url = "https://site.com/1.js"
Invoke-Expression (New-Object -TypeName System.Net.WebClient).DownloadString($url)

# Download and show text
(Invoke-WebRequest -Uri "https://site.com/1.js" -OutFile D:\1.js -PassThru -UseBasicParsing).Content

# Get text file content
(Invoke-WebRequest -Uri "https://site.com/1.js" -UseBasicParsing).Content

# Create a zip archive
Get-ChildItem -Path D:\folder -Filter *.ps1 -Recurse | Compress-Archive -DestinationPath D:\folder2 -CompressionLevel Optimal

# Expand zip archive
$Parameters = @{
	Path = "D:\1.zip"
	DestinationPath = "D:\1"
	Force = [switch]::Present
	Verbose = [switch]::Present
}
Expand-Archive @Parameters

# Split the drive letter
Split-Path -Path "D:\file.mp3" -Qualifier

# Get error description
certutil -error 0xc0000409

# Get file hash
Get-FileHash -Path D:\1.txt -Algorithm MD5

# Get string hash
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

# Expand the window with "Task manager" title but others to minimize
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

# Set a window state
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

# Find drive letter when we know where file is but a drive letter is unknown
# Suitable for situations when file is located on a USB drive
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
Get-ResolvedPath -Path "Folder\folder" | Copy-Item -Destination $env:SystemRoot\Cursors -Force

# Become a file owner
takeown /F D:\file.exe
icacls D:\file.exe /grant:r %username%:F
# Become a folder owner
takeown /F C:\HV\10 /R
icacls C:\HV\10 /grant:r %username%:F /T

# Search for a file on all local drives and its' full path
$file = "file.ext"
(Get-ChildItem -Path ([System.IO.DriveInfo]::GetDrives() | Where-Object {$_.DriveType -ne "Network"}).Name -Recurse -ErrorAction SilentlyContinue | Where-Object -FilterScript {$_.Name -like "$file"}).FullName

# Remove the first $c letters in the file names in a folder
$Path = "D:\folder"
$Extension = "flac"
$Characters = 4
(Get-ChildItem -LiteralPath $Path -Filter *.$Extension) | Rename-Item -NewName {$_.Name.Substring($Characters)}

# Remove the last $c letters in the file names in a folder
$Path = "D:\folder"
$Extension = "flac"
$Characters = 4
Get-ChildItem -LiteralPath $Path -Filter *.$Extension | Rename-Item -NewName {$_.Name.Substring(0,$_.BaseName.Length-$Characters) + $_.Extension}

# Find files in the name of which every word isn't capitalized
$Path = "D:\folder"
(Get-ChildItem -LiteralPath $Path -File -Recurse | Where-Object -FilterScript {($_.BaseName -replace "'|``") -cmatch "\b\p{Ll}\w*"}).FullName

# Capitize the first letter for every word in the files names in a folder
$Path = "D:\folder"
$Extension = "flac"
Get-ChildItem -Path $Path -Filter *.$Extension | Rename-Item -NewName {(Get-Culture).TextInfo.ToTitleCase($_.BaseName) + $_.Extension}

# Capitalize the first letters
$String = "аа аа аа"
(Get-Culture).TextInfo.ToTitleCase($String.ToLower())

# Count chars in a string
("string" | Measure-Object -Character).Characters

# Replace a word in a file name in a folder
Get-ChildItem -Path "D:\folder" | Rename-Item -NewName {$_.Name.Replace("abc","cba")}

# Replace an extension name in a folder
$Path = "D:\folder"
Get-ChildItem -Path $Path | Rename-Item -NewName {$_.FullName.Replace(".txt1",".txt")}

# Add REG_NONE
New-ItemProperty -Path HKCU:\Software -Name Name -PropertyType None -Value ([byte[]]@()) -Force

# Binary
"50,33,01".Split(",") | ForEach-Object -Process {"0x$_"}
#
$int = 0x6054b50
$bytes = [System.BitConverter]::GetBytes($int)
$int = [System.BitConverter]::ToInt32($bytes, 0)
'0x{0:x}' -f $int

# Disable net protocols
$ComponentIDs = @(
	"ms_tcpip6",
	"ms_pacer"
)
Disable-NetAdapterBinding -Name Ethernet -ComponentID $ComponentIDs

# Calculate videofiles' length in a folder
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
(Get-Duration -Path D:\folder -Extention mp4 | Sort-Object Duration | Out-String).Trim()


# Find all uninstalled updates
$UpdateSession = New-Object -ComObject Microsoft.Update.Session
$UpdateSearcher = $UpdateSession.CreateupdateSearcher()
$Updates = @($UpdateSearcher.Search("IsHidden=0 and IsInstalled=0").Updates)
$Updates | Select-Object -ExpandProperty Title

# Closed the specific File Explorer window
$FolderName = "D:\folder"
(New-Object -ComObject "Shell.Application").Windows() | Where-Object {$_.Document.Folder.Self.Path -eq $FolderName} | ForEach-Object -Process {$_.Quit()}

# StartsWith/EndsWith
$String = "1234"
$String.StartsWith("1")
$String.EndsWith("4")

# Context menu verbs
$Target = Get-Item -Path "D:\folder\file.lnk"
$Shell = New-Object -ComObject Shell.Application
$Folder = $Shell.NameSpace($Target.DirectoryName)
$file = $Folder.ParseName($Target.Name)
$Verb = $File.Verbs() | Where-Object -FilterScript {$_.Name -like "Закрепить на начальном &экране"}
$Verb.DoIt()

# Convert hash table into objects
$hash = @{
	Name = 'Tobias'
	Age = 66
	Status = 'Online'
}
New-Object -TypeName PSObject -Property $hash

# Encode using Base64 and vice versa
[Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes("SecretMessage"))
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("U2VjcmV0TWVzc2FnZQ=="))

# Remove unremovable registry key
$parent = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.ps1', $true)
$parent.DeleteSubKey('UserChoice', $true)
$parent.Close()

# Drives properties
Get-PhysicalDisk | Get-StorageReliabilityCounter | Select-Object -Property *

# Show all autostarts. Even drivers
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

# Find all notepad.exe processes, convert into an array and kill all
@(Get-Process -Name Notepad).ForEach({Stop-Process -InputObject $_})

# Compare hashes from .cat files
$HT = @{
	CatalogFilePath = "D:\file.cat"
	Path = "D:\folder"
	Detailed = $true
	FilesToSkip = "file.xml"
}
Test-FileCatalog @HT

# Reset local user password via WinPE
# In the WinPE
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

# Restoring components
Repair-WindowsImage -Online -RestoreHealth
DISM /Online /Cleanup-Image /RestoreHealth

# Restoring components locally
DISM /Get-WimInfo /WimFile:E:\sources\install.wim
Get-WindowsImage -ImagePath "E:\sources\install.wim"

DISM /Online /Cleanup-Image /RestoreHealth /Source:E:\sources\install.wim:1 /LimitAccess
Repair-WindowsImage -Online -RestoreHealth -Source E:\sources\install.wim:1 -LimitAccess

# Restoring system files
sfc /scannow

# Restoring components in the Windows PE
DISM /Get-WimInfo /WimFile:E:\sources\install.wim
DISM /Image:C:\ /Cleanup-Image /RestoreHealth /Source:E:\sources\install.wim:3 /ScratchDir:C:\mnt
# Restoring system files in the Windows PE
sfc /scannow /offbootdir=C:\ /offwindir=C:\Windows

# WinSxS cleaning up
DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase

# Check if a file is saved in UTF-8 with BOM encoding
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

# Arrays
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

# Conver an array into System.Collections.ObjectModel.Collection`1
$Collection = {$Fruits}.Invoke()
$Collection
$Collection.GetType()

$Collection.Add("Melon")
$Collection
$Collection.Remove("Apple")
$Collection

# Waiting for a process
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

# for
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

# Compare binary values
((Get-ItemPropertyValue -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer -Name link) -join " ") -ne ([byte[]](00, 00, 00, 00) -join " ")

# Get UEFI license key
(Get-CimInstance -ClassName SoftwareLicensingService).OA3xOriginalProductKey

# Activate Windows
slmgr.vbs /skms <servername>
slmgr.vbs /ato

# Get exception name
$Error[0].Exception.GetType().FullName

# Close all windows without killing the File Explorer process
(New-Object -ComObject Shell.Application).Windows() | Where-Object {$null -ne $_.FullName} | Where-Object {$_.FullName.EndsWith("\explorer.exe") } | ForEach-Object -Process {$_.Quit()}

# Show table with files names and lines count in a folder. -Raw reads blank lines
$FullName = @{
	Name = "File"
	Expression = {$_.FullName}
}
$Lines = @{
	Name = "Lines"
	Expression = {Get-Content -Path $_.FullName -Raw | Measure-Object -Line | Select-Object -ExpandProperty Lines}
}
Get-ChildItem -Path "D:\Folder" -Depth 0 -File -Filter *.psd1 -Recurse -Force | ForEach-Object -Process {$_ | Select-Object -Property $FullName, $Lines} | Format-Table -AutoSize

# Show table with files names and lines count in a folder except the specific folder
$FullName = @{
	Name = "File"
	Expression = {$_.FullName}
}
$Lines = @{
	Name = "Lines"
	Expression = {Get-Content -Path $_.FullName -Raw | Measure-Object -Line | Select-Object -ExpandProperty Lines}
}
Get-ChildItem -Path "D:\Folder" -Recurse -File -Force | Where-Object -FilterScript {$_.PSParentPath -notmatch "sophos"} | ForEach-Object -Process {$_ | Select-Object -Property $FullName, $Lines} | Format-Table -AutoSize
(Get-ChildItem -Path "D:\Folder" -Recurse -File -Force | Where-Object -FilterScript {$_.PSParentPath -notmatch "sophos"} | ForEach-Object -Process {(Get-Content -Path $_.FullName).Count} | Measure-Object -Sum).Sum

# Count the total number of lines in all files in all subfolders
$i = 0
Get-ChildItem -Path "D:\folder" -Depth 0 -Exclude *.dll, *.winmd, *.ps1 -File -Recurse -Force | ForEach-Object -Process {
    (Get-Content -Path $_.FullName -Raw | Measure-Object -Line).Lines | ForEach-Object -Process {
        $i += $_
    }
}
Write-Verbose -Message "Total number of lines is: $i" -Verbose

# Error description
function Convert-Error ([int]$ErrorCode)
{
	CertUtil -error $ErrorCode
	"`n"
	New-Object -TypeName System.ComponentModel.Win32Exception($ErrorCode)
}
Convert-Error -2147287037

# Remove lines starting with "//" and blank spaces
Get-Content -Path $settings | Where-Object -FilterScript {$_ -notmatch "//"} | Where-Object -FilterScript {$_.Trim(" `t")} | Set-Content -Path $settings -Force

# Quote every item
Get-Content -Path D:\file.txt -Force | ForEach-Object -Process {"'$_'"}
# PowerShell 7.x
@("1", "2", "3") | Join-String -Property $_ -DoubleQuote -Separator ', '

# Restore every files from Defender quarantine to their origin location
# https://docs.microsoft.com/en-us/windows/security/threat-protection/microsoft-defender-antivirus/command-line-arguments-microsoft-defender-antivirus
(Get-MpThreat).Resources.Replace('file:_',"") | ForEach-Object -Process {
	# Start-Sleep -Seconds 3
	Start-Process -FilePath "$env:ProgramFiles\Windows Defender\MpCmdRun.exe" -ArgumentList @("-Restore -FilePath `"$_`"") -Wait
}

# Insert an XML node
[xml]$XML1 = @"
<toast duration="$ToastDuration" scenario="reminder">
    <visual>
        <binding template="ToastGeneric">
            <group>
                <subgroup>
                    <text hint-style="body" hint-wrap="true" >$EventText</text>
                </subgroup>
            </group>
        </binding>
    </visual>
</toast>
"@

[xml]$XML2 = @"
<toast>
    <actions>
        <input id="SnoozeTimer" type="selection" title="Select a Snooze Interval" defaultInput="1">
            <selection id="1" content="1 Minute"/>
        </input>
        <action activationType="system" arguments="snooze" hint-inputId="SnoozeTimer" content="$SnoozeTitle" id="test-snooze"/>
    </actions>
</toast>
"@

$XML1.toast.AppendChild($XML1.ImportNode($XML2.toast.actions, $true))
$XML1.Save("C:\1.xml")

# Validate all .psd1 in all folders
$Folder = Get-ChildItem -Path "D:\Desktop\Sophia Script" -Recurse -Include *.psd1
foreach ($Item in $Folder.DirectoryName)
{
	Import-LocalizedData -FileName Sophia.psd1 -BaseDirectory $Item -BindingVariable Data
}

# Adding and Removing Items from a PowerShell Array
# https://www.jonathanmedd.net/2014/01/adding-and-removing-items-from-a-powershell-array.html
$Fruits = "Apple", "Pear", "Banana", "Orange"
$Fruits.GetType()
$Fruits.Add("Kiwi")
# $Fruits.Remove("Apple")
$Fruits.IsFixedSize

$Fruits = $Fruits -ne "Apple"
$Fruits

$Fruits = {$Fruits}.Invoke()
$Fruits.GetType()

$Collection.Add("Melon")
$Collection.Remove("Apple")
$Collection

# Set start-up powershell.exe location for Desktop
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

if (-not (Test-Path -Path $profile))
{
	New-Item -Path $profile -Force
}

$Value = "Set-Location -Path (Get-ItemPropertyValue -Path `"HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders`" -Name Desktop)"
Add-Content -Path $profile -Value $Value -Force

# Restart script by itself
try
{
	. $PSCommandPath
}
catch
{
	$Error.Exception.Message

	continue
}

# Check if Microsoft Defender is enabled
$cimParams = @{
	Namespace = "root/SecurityCenter2"
	ClassName = "Antivirusproduct"
}
$productState = (Get-CimInstance @CimParams | Where-Object -FilterScript {$_.displayName -match "Defender"}).productState

$AVState = ('0x{0:x}' -f $productState).Substring(3, 2)
if ($AVState -match "00|01")
{
	$false
}
else
{
	$true
}

(Get-MpComputerStatus).AntivirusEnabled -eq $true

# Disable NTFS compression in all subfolders
# https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/compact
$Paths = Get-ChildItem -Path D:\Folder -Recurse -Directory -Force
foreach ($Path in $Paths.FullName)
{
	$RecurseArgument = ('/S:{0}' -f $Path)
	& compact.exe /U $RecurseArgument
}

# Disable NTFS compression for the parent subfolder
$ParentFolder = Split-Path -Path $Paths.FullName -Parent
& compact.exe /U $ParentFolder 

# Isolate IP addresses only
$Array = @('Handshake', 'Success', 'Status', 200, '192.30.253.113', 'OK', 0xF, "2001:4860:4860::8888")
$Array | Where-Object -FiletScript {-not ($_ -as [Double]) -and ($_ -as [IPAddress])}

# Get the latest GitHub release version via GitHub API
try
{
	$LatestRelease = (Invoke-RestMethod -Uri "https://api.github.com/repos/farag2/Sophia-Script-for-Windows/releases/latest").tag_name
	$CurrentRelease = (Get-Module -Name Sophia).Version.ToString()
	switch ([System.Version]$LatestRelease -gt [System.Version]$CurrentRelease)
	{
		$true
		{

		}
	}
}
catch [System.Net.WebException]
{
	
}
	
# Parse PowerShell manifest
Import-PowerShellDataFile -Path D:\Manifest.psd1

# Trigger Windows Update for detecting new updates
# https://michlstechblog.info/blog/windows-10-trigger-detecting-updates-from-command-line
# https://omgdebugging.com/2017/10/09/command-line-equivalent-of-wuauclt-in-windows-10-windows-server-2016/
(New-Object -ComObject Microsoft.Update.AutoUpdate).DetectNow()
usoclient StartScan

# Check whether fTPM 2.0 supported
$CurrentVersion = (Get-CimInstance -Namespace root/cimv2/Security/MicrosoftTpm -ClassName Win32_Tpm).SpecVersion.Split(",").Trim() | Select-Object -First 1
if ([System.Version]$CurrentVersion -lt [System.Version]"2.0")
{}

# Exclude KB update from installing
(New-Object -ComObject Microsoft.Update.Session).CreateUpdateSearcher().Search("IsHidden = 0").Updates | Where-Object -FilterScript {$_.KBArticleIDs -eq "5005463"} | ForEach-Object -Process {$_.IsHidden = $true}

# Download and install all Store related UWP packages. Even for LTSC
wsreset -i

# Save file in the UTF-8 without BOM encoding
Set-Content -Value (New-Object -TypeName System.Text.UTF8Encoding -ArgumentList $false).GetBytes($(Get-Content -Path d:\file.txt -Raw)) -Encoding Byte -Path d:\file.txt -Force

# Check for a Windows Update pending reboot
$Parameters = @{
	Namespace  = "root\CIMv2"
	ClassName  = "StdRegProv"
	MethodName = "EnumKey"
}

$Parameters.Arguments = @{
	hDefKey     = [UInt32]2147483650
	sSubKeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing"
}
(Invoke-CimMethod @Parameters).sNames -contains "RebootPending"

$Parameters.Arguments = @{
	hDefKey     = [UInt32]2147483650
	sSubKeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update"
}
(Invoke-CimMethod @Parameters).sNames -contains "RebootRequired"

# Since Windows 22H2 22557 build
# https://oofhours.com/2022/04/27/language-pack-handling-in-windows-11-continues-to-evolve/
# https://en.wikipedia.org/wiki/IETF_language_tag
# LanguagePackManagement module
Install-Language -Language en-US
Get-InstalledLanguage
Set-SystemPreferredUILanguage
Get-SystemPreferredUILanguage
Uninstall-Language

# Bypass the Internet account creation in Windows 11
# Shift+F10
OOBE\BYPASSNRO

# Windows 11 Insider Preview 25120+
# Add a new user account
net user username /add
# Администраторы
net localgroup Administrators username /add
# "Пользователи удаленного рабочего стола"
net localgroup "Remote Desktop Users" username /add
cd OOBE
msoobe.exe && shutdown.exe -r

# Download the latest russia-blacklist.txt version
# https://github.com/ValdikSS/GoodbyeDPI
$Parameters = @{
	Uri              = "https://antizapret.prostovpn.org/domains-export.txt"
	UseBasicParsing  = $true
}
Invoke-RestMethod @Parameters | Set-Content -Encoding UTF8 -Path "$PSScriptRoot\russia-blacklist.txt" -Force
Set-Content -Value (New-Object -TypeName System.Text.UTF8Encoding -ArgumentList $false).GetBytes($(Get-Content -Path "$PSScriptRoot\russia-blacklist.txt" -Raw)) -Encoding Byte -Path "$PSScriptRoot\russia-blacklist.txt" -Force

# Get the NVIdia driver version
$driver = (Get-CimInstance -ClassName CIM_VideoController | Where-Object -FilterScript {$_.Name -match "NVIDIA"}).DriverVersion | Select-Object -Index 0
([regex]"[0-9.]{6}$").Match($driver_version).Value.Replace(".","").Insert(3,".")

# Prevent Windows to restart automatically after a system failure
# The parameter EnableAllPrivileges allows us to manipulate the properties of this WMI object if the current Powershell host runs as Administrator
Get-CimInstance -ClassName Win32_OSRecoveryConfiguration | Set-CIMInstance -Arguments @{AutoReboot = $false}

# Send firmware to HP MFU to upgrade
copy /b D:\firmware.rfu \\print_server\MFU

# Create a table with WSL installed distros
$Extensions = @{
	Ubuntu         = "Ubuntu"
	Debian         = "Debian GNU/Linux"
	"kali-linux"   = "Kali Linux Rolling"
	"openSUSE-42"  = "openSUSE Leap 42"
	"SLES-12"      = "SUSE Linux Enterprise Server v12"
	"Ubuntu-16.04" = "Ubuntu 16.04 LTS"
	"Ubuntu-18.04" = "Ubuntu 18.04 LTS"
	"Ubuntu-20.04" = "Ubuntu 20.04 LTS"
}
$Extensions.Keys | ForEach-Object -Process {(wsl --list --quiet) -contains $_}

# Create a table with WSL supported distros (not Internet connection required)
wsl --list --online | Where-Object -FilterScript {$_.Length -gt 1} | Select-Object -Skip 3 | ForEach-Object -Process {
	[PSCustomObject]@{
		"Key"   = $_.Substring(0, 24)
		"Value" = $_.Substring(30)
	}
}

# Decode blob URL and download file
# -y: overwrite output files
# -bsf bitstream_filters: a comma-separated list of bitstream filters
# -vcodec codec: force video codec ('copy' to copy stream)
ffmpeg -y "URL.m3u88" -bsf:a aac_adtstoasc -vcodec copy -c copy -crf 50 D:\video.mkv

# Create table with scheduled tasks info that were created a week before the current day
Get-ScheduledTask | Where-Object -FilterScript {$null -ne $_.Date} | ForEach-Object -Process {
	$Task = $_

	$_.Date.Split("T") | Where-Object -FilterScript {$_ -notmatch ":"} | ForEach-Object -Process {
		# Convert dates into the yyyy-MM-dd format
		$Date = [datetime]::ParseExact($_, "yyyy-MM-dd", $Null).ToString("dd.MM.yyyy")

		# If task creation date is between the date that less than week ago and the current day
		if ((Get-Date -Date $Date) -gt (Get-Date).AddDays(-8) -and ((Get-Date -Date $Date) -lt (Get-Date)))
		{
			[PSCustomObject]@{
				"Task Name"     = $Task.TaskName
				Path            = $Task.TaskPath
				"Date Creation" = $Task.Date
			}
		}
	}
}

# Change brightness to 100%
(Get-WmiObject -Namespace root/WMI -ClassName WmiMonitorBrightnessMethods).WmiSetBrightness(1,100)
