# Download the latest Adobe Acrobat Pro DC x64
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($Host.Version.Major -eq 5)
{
	# Progress bar can significantly impact cmdlet performance
	# https://github.com/PowerShell/PowerShell/issues/2138
	$Script:ProgressPreference = "SilentlyContinue"
}

$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$Parameters = @{
	Uri             = "https://trials.adobe.com/AdobeProducts/APRO/Acrobat_HelpX/win32/Acrobat_DC_Web_x64_WWMUI.zip"
	OutFile         = "$DownloadsFolder\Acrobat_DC_Web_x64_WWMUI.zip"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-WebRequest @Parameters

# Extract archive
& tar.exe -x -f "$DownloadsFolder\Acrobat_DC_Web_x64_WWMUI.zip" -C $DownloadsFolder --exclude "WindowsInstaller-KB893803-v2-x86.exe" --exclude "VCRT_x64" -v

# Extract AcroPro.msi to the "AcroPro.msi extracted" folder
$Arguments = @(
	"/a `"$DownloadsFolder\Adobe Acrobat\AcroPro.msi`""
	"TARGETDIR=`"$DownloadsFolder\Adobe Acrobat\AcroPro.msi extracted`""
	"/qb"
)
Start-Process "msiexec" -ArgumentList $Arguments -Wait

Get-ChildItem -Path "$DownloadsFolder\Adobe Acrobat\AcroPro.msi extracted" -Recurse -Force | Move-Item -Destination "$DownloadsFolder\Adobe Acrobat" -Force
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
