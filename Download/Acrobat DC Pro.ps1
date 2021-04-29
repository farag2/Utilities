# Download Acrobat_DC_Web_WWMUI.exe
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$Parameters = @{
	Uri = "http://trials.adobe.com/AdobeProducts/APRO/20/win32/Acrobat_DC_Web_WWMUI.exe"
	OutFile = "$DownloadsFolder\Acrobat_DC_Web_WWMUI.exe"
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
$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$Parameters = @{
	Uri = "https://trials3.adobe.com/AdobeProducts/APRO/Acrobat_HelpX/win32/Acrobat_DC_Web_WWMUI.zip"
	OutFile = "$DownloadsFolder\Acrobat_DC_Web_WWMUI.zip"
	Verbose = [switch]::present
	WebSession = $Session
}
Invoke-WebRequest @Parameters
#>

# Extract Acrobat_DC_Web_WWMUI.exe to the "Downloads folder\AcrobatTemp" folder
# Do not change window focus while extracting Acrobat_DC_Web_WWMUI.exe, unless the process will be running forever
$ExtractPath = "$DownloadsFolder\AcrobatTemp"
Start-Process -FilePath "$DownloadsFolder\Acrobat_DC_Web_WWMUI.exe" -ArgumentList "/o /s /x /d $ExtractPath" -PassThru -Wait

# Extract AcroPro.msi to the "AcroPro.msi extracted" folder
$Arguments = @(
	"/a `"$ExtractPath\Adobe Acrobat\AcroPro.msi`""
	"TARGETDIR=`"$ExtractPath\Adobe Acrobat\AcroPro.msi extracted`""
	"/qb"
)
Start-Process "msiexec" -ArgumentList $Arguments -Wait

# Remove unnecessary files and folders
Get-ChildItem -Path $ExtractPath -Filter *.htm | ForEach-Object -Process {Remove-Item -Path $_.FullName}
Remove-Item -Path "$ExtractPath\GB18030" -Recurse -Force

Remove-Item -Path "$ExtractPath\Adobe Acrobat\VCRT_x64" -Recurse -Force
Remove-Item -Path "$ExtractPath\Adobe Acrobat\AcrobatDCUpd*.msp" -Force
Remove-Item -Path "$ExtractPath\Adobe Acrobat\WindowsInstaller-KB893803-v2-x86.exe" -Force

Remove-Item -Path "$ExtractPath\Adobe Acrobat\AcroPro.msi" -Force
Remove-Item -Path "$ExtractPath\Adobe Acrobat\Data1.cab" -Force
Get-ChildItem -Path "$ExtractPath\Adobe Acrobat\AcroPro.msi extracted" -Recurse -Force | Move-Item -Destination "$ExtractPath\Adobe Acrobat" -Force
Remove-Item -Path "$ExtractPath\Adobe Acrobat\AcroPro.msi extracted" -Force

# Download the latest patch
# https://www.adobe.com/devnet-docs/acrobatetk/tools/ReleaseNotesDC/index.html
$LatestVersion = Invoke-RestMethod -Uri https://armmf.adobe.com/arm-manifests/mac/AcrobatDC/acrobat/current_version.txt
$LatestVersion = $LatestVersion.Replace(".","")

$Parameters = @{
	Uri = "https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/$($LatestVersion)/AcrobatDCUpd$($LatestVersion).msp"
	OutFile = "$DownloadsFolder\AcrobatDCUpd$($LatestVersion).msp"
	Verbose = [switch]::Present
}
Invoke-WebRequest @Parameters

# Create the edited setup.ini
$PatchFile = Split-Path -Path "$DownloadsFolder\AcrobatDCUpd$($LatestVersion).msp" -Leaf

$setupini = @"
[Product]
PATCH=$PatchFile
msi=AcroPro.msi
Languages=1049
1049=Russian
"@
Set-Content -Path "$ExtractPath\Adobe Acrobat\setup.ini" -Value $setupini -Encoding Default -Force
