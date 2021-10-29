[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# https://github.com/tonsky/FiraCode
$Tag = (Invoke-RestMethod -Uri "https://api.github.com/repos/tonsky/FiraCode/releases/latest").tag_name
$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$Parameters = @{
	Uri     = "https://github.com/tonsky/FiraCode/releases/download/$Tag/Fira_Code_v$Tag.zip"
	OutFile = "$DownloadsFolder\Fira_Code_v$Tag.zip"
	Verbose = $true
}
Invoke-WebRequest @Parameters

$Parameters = @{
	Path            = "$DownloadsFolder\Fira_Code_v$Tag.zip"
	DestinationPath = "$DownloadsFolder\Fira_Code"
	Force           = $true
	Verbose         = $true
}
Expand-Archive @Parameters

Get-ChildItem -Path "$DownloadsFolder\Fira_Code" -Recurse -Force | Unblock-File

# Installing fonts
# https://docs.microsoft.com/en-us/windows/desktop/api/Shldisp/ne-shldisp-shellspecialfolderconstants
# https://docs.microsoft.com/en-us/windows/win32/shell/folder-copyhere
$ssfFONTS = 20

# https://docs.microsoft.com/en-us/windows/win32/api/shellapi/ns-shellapi-shfileopstructa
$FOF_SILENT = 4
$FOF_NOCONFIRMATION = 16
$FOF_NOERRORUI = 1024
$FOF_NOCOPYSECURITYATTRIBS = 2048

$CopyOptions = $FOF_SILENT + $FOF_NOCONFIRMATION + $FOF_NOERRORUI + $FOF_NOCOPYSECURITYATTRIBS

$Fonts = Get-ChildItem -Path "$DownloadsFolder\Fira_Code\ttf\*.ttf"
foreach ($Font in $Fonts)
{
	(New-Object -ComObject Shell.Application).NameSpace($ssfFONTS).CopyHere($Font.FullName, $CopyOptions)
}

Remove-Item -Path "$DownloadsFolder\Fira_Code_v$Tag.zip", "$DownloadsFolder\Fira_Code" -Recurse -Force
