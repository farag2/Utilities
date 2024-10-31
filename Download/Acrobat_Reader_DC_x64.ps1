# Download the latest Adobe Acrobat Reader DC x64
# https://armmf.adobe.com/arm-manifests/mac/AcrobatDC/reader/current_version.txt

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($Host.Version.Major -eq 5)
{
	# Progress bar can significantly impact cmdlet performance
	# https://github.com/PowerShell/PowerShell/issues/2138
	$Script:ProgressPreference = "SilentlyContinue"
}

# Get the link to the latest Adobe Acrobat Reader DC x64 installer
$TwoLetterISOLanguageName = (Get-WinSystemLocale).TwoLetterISOLanguageName
$Parameters = @{
	Uri = "https://rdc.adobe.io/reader/products?lang=$($TwoLetterISOLanguageName)&site=enterprise&os=Windows%2011&api_key=dc-get-adobereader-cdn"
	UseBasicParsing = $true
}
$displayName = (Invoke-RestMethod @Parameters).products.reader.displayName
$Version = (Invoke-RestMethod @Parameters).products.reader.version.Replace(".", "")

$Parameters = @{
	Uri             = "https://rdc.adobe.io/reader/downloadUrl?name=$($displayName)&os=Windows%2011&site=enterprise&lang=$($TwoLetterISOLanguageName)&api_key=dc-get-adobereader-cdn"
	UseBasicParsing = $true
}
$downloadURL = (Invoke-RestMethod @Parameters).downloadURL
$saveName = (Invoke-RestMethod @Parameters).saveName

# if URl contains "reader", we need to fix the URl to download the latest version. Applicable for the Russian version
if ($downloadURL -match "reader")
{
	$Parameters = @{
		Uri = "https://rdc.adobe.io/reader/products?lang=en&site=enterprise&os=Windows%2011&api_key=dc-get-adobereader-cdn"
		UseBasicParsing = $true
	}
	$Version = (Invoke-RestMethod @Parameters).products.reader.version.Replace(".", "")

	$IetfLanguageTag = (Get-WinSystemLocale).IetfLanguageTag.Replace("-", "_")
	$downloadURL = "https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/$($Version)/AcroRdrDCx64$($Version)_$($IetfLanguageTag).exe"
	$saveName = Split-Path -Path $downloadURL -Leaf
}

# Download the installer
$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$Parameters = @{
	Uri             = $downloadURL
	OutFile         = "$DownloadsFolder\$saveName"
	UseBasicParsing = $true
}
Invoke-RestMethod @Parameters

# Extract to the "AcroRdrDCx64" folder
$Arguments = @(
	# Specifies the name of folder where the expanded package is placed
	"-sfx_o{0}" -f "$DownloadsFolder\AcroRdrDCx64"
	# Do not execute any file after installation (overrides the '-e' switch)
	"-sfx_ne"
)
Start-Process -FilePath "$DownloadsFolder\AcroRdrDCx64$($Version)_$($IetfLanguageTag).exe" -ArgumentList $Arguments -Wait

$Items = @(
	"$DownloadsFolder\AcroRdrDCx64\WindowsInstaller-KB893803-v2-x86.exe",
	"$DownloadsFolder\AcroRdrDCx64\VCRT_x64"
)
Remove-Item -Path $Items -Recurse -Force -ErrorAction Ignore

# Get the latest Adobe Acrobat Pro DC patch version (lang=mui)
$Parameters = @{
	Uri = "https://rdc.adobe.io/reader/products?lang=mui&site=enterprise&os=Windows%2011&api_key=dc-get-adobereader-cdn"
	UseBasicParsing = $true
}
$Version = ((Invoke-RestMethod @Parameters).products.reader | Where-Object -FilterScript {$_.displayName -match "64bit"}).version.Replace(".", "")

# If latest version is greater than one from archive
if ((Get-Item -Path "$DownloadsFolder\AcroRdrDCx64\AcroRdrDCx64Upd*.msp").FullName -notmatch $Version)
{
	Remove-Item -Path "$DownloadsFolder\AcroRdrDCx64\AcroRdrDCx64Upd*.msp" -Force

	$Parameters = @{
		Uri             = "https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/$($Version)/AcroRdrDCx64Upd$($Version).msp"
		OutFile         = "$DownloadsFolder\AcroRdrDCx64\AcroRdrDCx64Upd$($Version).msp"
		UseBasicParsing = $true
		Verbose         = $true
	}
	Invoke-WebRequest @Parameters
}
$PatchFile = Split-Path -Path (Get-Item -Path "$DownloadsFolder\AcroRdrDCx64\AcroRdrDCx64Upd*.msp").FullName -Leaf

# setup.ini
# https://www.adobe.com/devnet-docs/acrobatetk/tools/AdminGuide/properties.html
$CmdLine = @(
	"ENABLE_CHROMEEXT=0",
	"DISABLE_BROWSER_INTEGRATION=YES",
	"DISABLE_DISTILLER=YES",
	"REMOVE_PREVIOUS=YES",
	"IGNOREVCRT64=1",
	"EULA_ACCEPT=YES",
	"DISABLE_PDFMAKER=YES",
	"DISABLEDESKTOPSHORTCUT=2",
	# Install updates automatically
	"UPDATE_MODE=3"
)

# Create the edited setup.ini
$setupini = @"
[Product]
msi=AcroPro.msi
PATCH=$PatchFile
CmdLine=$CmdLine
"@
Set-Content -Path "$DownloadsFolder\AcroRdrDCx64\setup.ini" -Value $setupini -Encoding Default -Force
