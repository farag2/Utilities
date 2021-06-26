# Download the latest Acrobat_DC_Web_WWMUI.exe
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$Parameters = @{
	Uri = "http://trials.adobe.com/AdobeProducts/APRO/Acrobat_HelpX/win32/Acrobat_DC_Web_WWMUI.zip"
	OutFile = "$DownloadsFolder\Acrobat_DC_Web_WWMUI.zip"
	Verbose = [switch]::Present
}
Invoke-WebRequest @Parameters

<#
$Session = New-Object -TypeName Microsoft.PowerShell.Commands.WebRequestSession
$Cookie = New-Object -TypeName System.Net.Cookie
$Cookie.Name = "MM_TRIALS"
$Cookie.Value = "1234"
$Cookie.Domain = ".adobe.com"
$Session.Cookies.Add($Cookie)

$Parameters = @{
	Uri =      "https://trials3.adobe.com/AdobeProducts/APRO/Acrobat_HelpX/win32/Acrobat_DC_Web_WWMUI.zip"
	OutFile    = "$DownloadsFolder\Acrobat_DC_Web_WWMUI.zip"
	WebSession = $Session
	Verbose    = [switch]::present
}
Invoke-WebRequest @Parameters
#>

<#
# Extract Acrobat_DC_Web_WWMUI.exe to the "Downloads folder\AcrobatTemp" folder
# Do not change window focus while extracting Acrobat_DC_Web_WWMUI.exe, unless the process will be running forever
Start-Process -FilePath "$DownloadsFolder\Acrobat_DC_Web_WWMUI.exe" -ArgumentList "/o /s /x /d `"$DownloadsFolder\AcrobatTemp`"" -PassThru -Wait
#>

<#
	.SYNOPSIS
	Extracting the specific folder from ZIP archive. Folder structure will be created recursively

	.Parameter Source
	The source ZIP archive

	.Parameter Destination
	Where to extracting folder

	.Parameter Folder
	Assign the folder to extracting to

	.Parameter ExcludedFiles
	Exclude files from extracting

	.Parameter ExcludedFolders
	Exclude folders from extracting

	.Example
	ExtractZIPFolder -Source "D:\Folder\File.zip" -Destination "D:\Folder" -Folder "Folder1/Folder2" -ExcludedFiles @("file1.ext", "file2.ext") -ExcludedFolders @("folder1", "folder2")
#>
function ExtractZIPFolder
{
	[CmdletBinding()]
	param
	(
		[string]
		$Source,

		[string]
		$Destination,

		[string]
		$Folder,

		[string[]]
		$ExcludedFiles,

		[string[]]
		$ExcludedFolders
	)

	Add-Type -Assembly System.IO.Compression.FileSystem

	$ZIP = [IO.Compression.ZipFile]::OpenRead($Source)

	$ExcludedFolders = ($ExcludedFolders | ForEach-Object -Process {$_ + "/.*?"}) -join '|'

	$ZIP.Entries | Where-Object -FilterScript {($_.FullName -like "$($Folder)/*.*") -and ($ExcludedFiles -notcontains $_.Name) -and ($_.FullName -notmatch $ExcludedFolders)} | ForEach-Object -Process {
		$File   = Join-Path -Path $Destination -ChildPath $_.FullName
		$Parent = Split-Path -Path $File -Parent

		if (-not (Test-Path -Path $Parent))
		{
			New-Item -Path $Parent -Type Directory -Force
		}

		[IO.Compression.ZipFileExtensions]::ExtractToFile($_, $File, $true)
	}

	$ZIP.Dispose()
}

$Parameters = @{
	Source          = "$DownloadsFolder\Acrobat_DC_Web_WWMUI.zip"
	Destination     = "$DownloadsFolder"
	Folder          = "Adobe Acrobat"
	ExcludedFiles   = @("AcrobatDCUpd$($LatestVersion).msp", "WindowsInstaller-KB893803-v2-x86.exe")
	ExcludedFolders = @("Adobe Acrobat/VCRT_x64")
}
ExtractZIPFolder @Parameters

# Extract AcroPro.msi to the "AcroPro.msi extracted" folder
$Arguments = @(
	"/a `"$DownloadsFolder\Adobe Acrobat\AcroPro.msi`""
	"TARGETDIR=`"$DownloadsFolder\Adobe Acrobat\AcroPro.msi extracted`""
	"/qb"
)
Start-Process "msiexec" -ArgumentList $Arguments -Wait

Remove-Item -Path "$DownloadsFolder\Adobe Acrobat\Data1.cab" -Force
Get-ChildItem -Path "$DownloadsFolder\Adobe Acrobat\AcroPro.msi extracted" -Recurse -Force | Move-Item -Destination "$DownloadsFolder\Adobe Acrobat" -Force
Remove-Item -Path "$DownloadsFolder\Adobe Acrobat\AcroPro.msi extracted" -Force

# Download the latest patch
# https://www.adobe.com/devnet-docs/acrobatetk/tools/ReleaseNotesDC/index.html
$LatestVersion = (Invoke-RestMethod -Uri "https://armmf.adobe.com/arm-manifests/mac/AcrobatDC/acrobat/current_version.txt").Replace(".","")
$Parameters = @{
	Uri = "https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/$($LatestVersion)/AcrobatDCUpd$($LatestVersion).msp"
	OutFile = "$DownloadsFolder\Adobe Acrobat\AcrobatDCUpd$($LatestVersion).msp"
	Verbose = [switch]::Present
}
Invoke-WebRequest @Parameters

# Create the edited setup.ini
$PatchFile = Split-Path -Path "$DownloadsFolder\AcrobatDCUpd$($LatestVersion).msp" -Leaf

# setup.ini
# https://www.adobe.com/devnet-docs/acrobatetk/tools/AdminGuide/properties.html
$CmdLine = @(
	"LANG_LIST=ru_RU",
	"DISABLE_BROWSER_INTEGRATION=YES",
	"ENABLE_CHROMEEXT=0",
	"DISABLE_DISTILLER=YES",
	"IGNOREVCRT64=1",
	"EULA_ACCEPT=YES",
	"REMOVE_PREVIOUS=YES",
	"REMOVE_PREVIOUS_READER=YES",
	"IW_DEFAULT_VERB=Open",
	"DISABLE_PDFMAKER=YES",
	"DISABLE_ARM_SERVICE_INSTALL=1"
)

$setupini = @"
[Product]
msi=AcroPro.msi
PATCH=$PatchFile
CmdLine=$CmdLine
Languages=1049
1049=Russian
"@
Set-Content -Path "$DownloadsFolder\Adobe Acrobat\setup.ini" -Value $setupini -Encoding Default -Force
