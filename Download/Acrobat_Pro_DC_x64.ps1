# Download the latest Adobe Acrobat Pro DC x64
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$Parameters = @{
	Uri             = "https://trials.adobe.com/AdobeProducts/APRO/Acrobat_HelpX/win32/Acrobat_DC_Web_x64_WWMUI.zip"
	OutFile         = "$DownloadsFolder\Acrobat_DC_Web_WWMUI.zip"
	UseBasicParsing = $true
	Verbose         = $true
}
#Invoke-WebRequest @Parameters

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
	ExcludedFiles   = @("WindowsInstaller-KB893803-v2-x86.exe")
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

$CABs = @(
	"$DownloadsFolder\Adobe Acrobat\AlfSdPack.cab",
	"$DownloadsFolder\Adobe Acrobat\Core.cab",
	"$DownloadsFolder\Adobe Acrobat\Extras.cab",
	"$DownloadsFolder\Adobe Acrobat\Intermediate.cab",
	"$DownloadsFolder\Adobe Acrobat\Languages.cab",
	"$DownloadsFolder\Adobe Acrobat\Optional.cab"
)
Remove-Item -Path $CABs -Force

Get-ChildItem -Path "$DownloadsFolder\Adobe Acrobat\AcroPro.msi extracted" -Recurse -Force | Move-Item -Destination "$DownloadsFolder\Adobe Acrobat" -Recurse -Force
Remove-Item -Path "$DownloadsFolder\Adobe Acrobat\AcroPro.msi extracted" -Force

# Get the latest Adobe Acrobat Pro DC patch version (lang=mui)
$Parameters = @{
	Uri = "https://rdc.adobe.io/reader/products?lang=mui&site=enterprise&os=Windows%2011&api_key=dc-get-adobereader-cdn"
	UseBasicParsing = $true
}
$Version = ((Invoke-RestMethod @Parameters).products.reader | Where-Object -FilterScript {$_.displayName -match "64bit"}).version.Replace(".", "")

# If latest version is greater than one from archive
if ((Get-Item -Path "$DownloadsFolder\Adobe Acrobat\AcrobatDCx64Upd*.msp").FullName -notmatch $Version)
{
	Remove-Item -Path "$DownloadsFolder\Adobe Acrobat\AcrobatDCx64Upd*.msp" -Force

	$Parameters = @{
		Uri             = "https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/$($Version)/AcrobatDCx64Upd$($Version).msp"
		OutFile         = "$DownloadsFolder\Adobe Acrobat\AcrobatDCx64Upd$($Version).msp"
		UseBasicParsing = $true
		Verbose         = $true
	}
	Invoke-WebRequest @Parameters
}
$PatchFile = Split-Path -Path (Get-Item -Path "$DownloadsFolder\Adobe Acrobat\AcrobatDCx64Upd*.msp").FullName -Leaf

# setup.ini
# https://www.adobe.com/devnet-docs/acrobatetk/tools/AdminGuide/properties.html
$CmdLine = @(
	"ENABLE_CHROMEEXT=0",
	"DISABLE_BROWSER_INTEGRATION=YES",
	# "DISABLE_DISTILLER=YES",
	"REMOVE_PREVIOUS=YES",
	"IGNOREVCRT64=1",
	"EULA_ACCEPT=YES",
	# "DISABLE_PDFMAKER=YES",
	"DISABLEDESKTOPSHORTCUT=2",
	# Install updates automatically
	"UPDATE_MODE=3"
)

$LCID = (Get-WinSystemLocale).LCID
$DisplayLanguage = (Get-WinUserLanguageList).EnglishName | Select-Object -First 1

# Create the edited setup.ini
$setupini = @"
[Product]
msi=AcroPro.msi
PATCH=$PatchFile
CmdLine=$CmdLine
Languages=$LCID
$LCID=$DisplayLanguage
"@
Set-Content -Path "$DownloadsFolder\Adobe Acrobat\setup.ini" -Value $setupini -Encoding Default -Force
