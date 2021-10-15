# Download the latest Adobe Acrobat Reader DC x64
# https://www.adobe.com/devnet-docs/acrobatetk/tools/ReleaseNotesDC/index.html
# https://armmf.adobe.com/arm-manifests/mac/AcrobatDC/reader/current_version.txt

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Get the link to the latest Adobe Acrobat Reader DC x64 installer
$Headers = @{
	"Sec-Fetch-Dest"   = "empty"
	"Sec-Fetch-Site"   = "same-origin"
	"X-Requested-With" = "XMLHttpRequest"
	Accept             = "*/*"
	"User-Agent"       = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36 Edg/88.0.705.81"
	Referer            = "https://get.adobe.com/reader/otherversions/"
	DNT                = "1"
	"Accept-Language"  = "en-AU,en-US;q=0.9,en;q=0.8"
	"Sec-Fetch-Mode"   = "cors"
	"Accept-Encoding"  = "gzip, deflate, br"
}
$Language = (Get-WinSystemLocale).EnglishName -split " " | Select-Object -Index 0
$TwoLetterISOLanguageName = (Get-WinSystemLocale).TwoLetterISOLanguageName
$Parameters = @{
	Uri             = "https://get.adobe.com/reader/webservices/json/standalone/?platform_type=Windows&platform_dist=Windows%2010&platform_arch=&language=$Language&eventname=readerotherversions"
	Headers         = $Headers
	UseBasicParsing = $true
}
$URL = ((Invoke-RestMethod @Parameters) | Where-Object -FilterScript {$_.aih_installer_abbr -eq "readerdc64_$TwoLetterISOLanguageName"}).download_url

# Download the installer
$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$Parameters = @{
	Uri             = $URL
	OutFile         = "$DownloadsFolder\AcroRdrDCx64.exe"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-WebRequest @Parameters

# Extract to the "AcroRdrDCx64" folder
$Arguments = @(
	# Specifies the name of folder where the expanded package is placed
	"-sfx_o{0}" -f "$DownloadsFolder\AcroRdrDCx64"
	# Do not execute any file after installation (overrides the '-e' switch)
	"-sfx_ne"
)
Start-Process -FilePath "$DownloadsFolder\AcroRdrDCx64.exe" -ArgumentList $Arguments -Wait

# Extract AcroPro.msi to the "AcroPro.msi extracted" folder
$Arguments = @(
	"/a `"$DownloadsFolder\AcroRdrDCx64\AcroPro.msi`""
	"TARGETDIR=`"$DownloadsFolder\AcroRdrDCx64\AcroPro.msi extracted`""
	"/qb"
)
Start-Process "msiexec" -ArgumentList $Arguments -Wait

$Items = @(
	"$DownloadsFolder\AcroRdrDCx64\Core.cab",
	"$DownloadsFolder\AcroRdrDCx64\Languages.cab",
	"$DownloadsFolder\AcroRdrDCx64\WindowsInstaller-KB893803-v2-x86.exe",
	"$DownloadsFolder\AcroRdrDCx64\VCRT_x64"
)
Remove-Item -Path $Items -Recurse -Force -ErrorAction Ignore
Get-ChildItem -Path "$DownloadsFolder\AcroRdrDCx64\AcroPro.msi extracted" -Recurse -Force | Move-Item -Destination "$DownloadsFolder\AcroRdrDCx64" -Force
Remove-Item -Path "$DownloadsFolder\AcroRdrDCx64\AcroPro.msi extracted" -Force

# Download the latest patch
# https://www.adobe.com/devnet-docs/acrobatetk/tools/ReleaseNotesDC/index.html
<#
	(Invoke-RestMethod -Uri "https://armmf.adobe.com/arm-manifests/win/AcrobatDC/acrobat/current_version.txt" -UseBasicParsing).Replace(".","").Trim()
	won't help due to that fact it outputs the Mac patch version instead of Windows one that is always has a higher version number
#>
if (Test-Path -Path "$DownloadsFolder\AcroRdrDCx64\AcroRdrDCx64Upd*.msp")
{
	# Get the bare patch number to compare with the latest one
	$CurrentPatchVersion = (Split-Path -Path (Get-Item -Path "$DownloadsFolder\AcroRdrDCx64\AcroRdrDCx64*.msp").FullName -Leaf).Replace(".msp","").Replace("AcroRdrDCx64Upd","")

	$Parameters = @{
		Uri             = "https://armmf.adobe.com/arm-manifests/mac/AcrobatDC/reader/current_version.txt"
		UseBasicParsing = $true
	}
	$LatestPatchVersion = (Invoke-RestMethod @Parameters).Replace(".","").Trim()

	$Parameters = @{
		Uri             = "https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/$LatestPatchVersion/AcroRdrDCx64Upd$LatestPatchVersion.msp"
		OutFile         = "$DownloadsFolder\AcroRdrDCx64\AcroRdrDCx64Upd$LatestPatchVersion.msp"
		UseBasicParsing = $true
		Verbose         = $true
	}
	Invoke-WebRequest @Parameters

	if ($CurrentPatchVersion -lt $LatestPatchVersion)
	{
		Remove-Item -Path "$DownloadsFolder\AcroRdrDCx64\AcroRdrDCx64Upd$CurrentPatchVersion.msp" -Force
	}
}
else
{
	$Parameters = @{
		Uri             = "https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/$LatestPatchVersion/AcroRdrDCx64Upd$LatestPatchVersion.msp"
		OutFile         = "$DownloadsFolder\AcroRdrDCx64\AcroRdrDCx64Upd$LatestPatchVersion.msp"
		UseBasicParsing = $true
		Verbose         = $true
	}
	Invoke-WebRequest @Parameters
}

# Create the edited setup.ini
$PatchFile = Split-Path -Path "$DownloadsFolder\AcroRdrDCx64\AcroRdrDCx64Upd$LatestPatchVersion.msp" -Leaf

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

$setupini = @"
[Product]
msi=AcroPro.msi
PATCH=$PatchFile
CmdLine=$CmdLine
"@
Set-Content -Path "$DownloadsFolder\AcroRdrDCx64\setup.ini" -Value $setupini -Encoding Default -Force
