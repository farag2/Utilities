# Downloading Acrobat_DC_Web_WWMUI.exe
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

# Extracting Acrobat_DC_Web_WWMUI.exe to the "Downloads folder\AcrobatTemp" folder
# Do not change window focus while extracting Acrobat_DC_Web_WWMUI.exe, unless the process will be running forever
$ExtractPath = "$DownloadsFolder\AcrobatTemp"
Start-Process -FilePath "$DownloadsFolder\Acrobat_DC_Web_WWMUI.exe" -ArgumentList "/o /s /x /d $ExtractPath" -PassThru -Wait

# Extracting AcroPro.msi to the "AcroPro.msi extracted" folder
$Arguments = @(
	"/a `"$ExtractPath\Adobe Acrobat\AcroPro.msi`""
	"TARGETDIR=`"$ExtractPath\Adobe Acrobat\AcroPro.msi extracted`""
	"/qb"
)
Start-Process "msiexec" -ArgumentList $Arguments -Wait

# Removing unnecessary files and folders
Get-ChildItem -Path $ExtractPath -Filter *.htm | ForEach-Object -Process {Remove-Item -Path $_.FullName}
Remove-Item -Path "$ExtractPath\GB18030" -Recurse -Force

Get-ChildItem -Path "$ExtractPath\Adobe Acrobat\Transforms" -Exclude 1049.mst | ForEach-Object -Process {Remove-Item -Path $_.FullName}
Remove-Item -Path "$ExtractPath\Adobe Acrobat\VCRT_x64" -Recurse -Force
Remove-Item -Path "$ExtractPath\Adobe Acrobat\AcrobatDCUpd*.msp" -Force
Remove-Item -Path "$ExtractPath\Adobe Acrobat\WindowsInstaller-KB893803-v2-x86.exe" -Force

Remove-Item -Path "$ExtractPath\Adobe Acrobat\AcroPro.msi" -Force
Remove-Item -Path "$ExtractPath\Adobe Acrobat\Data1.cab" -Force
Get-ChildItem -Path "$ExtractPath\Adobe Acrobat\AcroPro.msi extracted" -Recurse -Force | Move-Item -Destination "$ExtractPath\Adobe Acrobat" -Force
Remove-Item -Path "$ExtractPath\Adobe Acrobat\AcroPro.msi extracted" -Force

# Downloading the latest patch
$URL = "ftp://ftp.adobe.com/pub/adobe/acrobat/win/AcrobatDC/2000920067/AcrobatDCUpd2000920067.msp"
$PatchFile = Split-Path -Path $URL -Leaf
$Parameters = @{
	Uri = $URL
	OutFile = "$ExtractPath\Adobe Acrobat\$PatchFile"
	Verbose = [switch]::Present
}
Invoke-WebRequest @Parameters

# Creating edited setup.ini
$setupini = @"
[Product]
PATCH=$PatchFile
msi=AcroPro.msi
Languages=1049
1049=Russian
"@
Set-Content -Path "$ExtractPath\Adobe Acrobat\setup.ini" -Value $setupini -Encoding Unicode -Force

# Converting setup.ini to the UTF-8 encoding
$Content = Get-Content -Path "$ExtractPath\Adobe Acrobat\setup.ini" -Raw
Set-Content -Value (New-Object System.Text.UTF8Encoding).GetBytes($Content) -Encoding Byte -Path "$ExtractPath\Adobe Acrobat\setup.ini" -Force
