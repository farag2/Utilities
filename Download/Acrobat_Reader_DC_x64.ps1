# Download the latest Adobe Acrobat Reader DC x64

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# https://www.adobe.com/devnet-docs/acrobatetk/tools/ReleaseNotesDC/index.html
$LatestVersion = (Invoke-RestMethod -Uri "https://armmf.adobe.com/arm-manifests/mac/AcrobatDC/reader/current_version.txt").Replace(".","")
$Locale = $PSUICulture.Replace("-", "_")
$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$Parameters = @{
	Uri = "https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/$LatestVersion/AcroRdrDCx64$($LatestVersion)_$($Locale).exe"
	OutFile = "$DownloadsFolder\AcroRdrDCx64$($LatestVersion)_$($Locale).exe"
	Verbose = [switch]::Present
}
Invoke-WebRequest @Parameters

# Extract AcroRdrDCx64xxxx_xx_xx.exe to the "AcroRdrDCx64xxxx_xx_xx" folder
$Arguments = @(
	# Specifies the name of folder where the expanded package is placed. The folder name should be enclosed in quotation marks. It is best if you do not use an existing folder
	"-sfx_o{0}" -f "$DownloadsFolder\AcroRdrDCx64$($LatestVersion)_$($Locale)"
	# Do not execute any file after installation (overrides the -e switch) This switch should be used if user only wants to extract the installer contents and not run the installer
	"-sfx_ne"
)
Start-Process -FilePath "$DownloadsFolder\AcroRdrDCx64$($LatestVersion)_$($Locale)" -ArgumentList $Arguments -Wait

# Extract AcroPro.msi to the "AcroPro.msi extracted" folder
$Arguments = @(
	"/a `"$DownloadsFolder\AcroRdrDCx64$($LatestVersion)_$($Locale)\AcroPro.msi`""
	"TARGETDIR=`"$DownloadsFolder\AcroRdrDCx64$($LatestVersion)_$($Locale)\AcroPro.msi extracted`""
	"/qb"
)
Start-Process "msiexec" -ArgumentList $Arguments -Wait

Remove-Item -Path "$DownloadsFolder\AcroRdrDCx64$($LatestVersion)_$($Locale)\Core.cab", "$DownloadsFolder\AcroRdrDCx64$($LatestVersion)_$($Locale)\Languages.cab", "$DownloadsFolder\AcroRdrDCx64$($LatestVersion)_$($Locale)\WindowsInstaller-KB893803-v2-x86.exe" -Force -ErrorAction Ignore
Remove-Item -Path "$DownloadsFolder\AcroRdrDCx64$($LatestVersion)_$($Locale)\VCRT_x64" -Recurse -Force
Get-ChildItem -Path "$DownloadsFolder\AcroRdrDCx64$($LatestVersion)_$($Locale)\AcroPro.msi extracted" -Recurse -Force | Move-Item -Destination "$DownloadsFolder\AcroRdrDCx64$($LatestVersion)_$($Locale)" -Force
Remove-Item -Path "$DownloadsFolder\AcroRdrDCx64$($LatestVersion)_$($Locale)\AcroPro.msi extracted" -Force

# Create the edited setup.ini
$PatchFile = Split-Path -Path "$DownloadsFolder\AcroRdrDCx64Upd$($LatestVersion).msp" -Leaf

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
	# This is the only valid value for Reader
	"DISABLEDESKTOPSHORTCUT=1",
	# Install updates automatically
	"UPDATE_MODE=3"
)

$setupini = @"
[Product]
msi=AcroPro.msi
PATCH=$PatchFile
CmdLine=$CmdLine
"@
Set-Content -Path "$DownloadsFolder\AcroRdrDCx64$($LatestVersion)_$($Locale)\setup.ini" -Value $setupini -Encoding Default -Force
