$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$Parameters = @{
	Uri     = "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64"
	OutFile = "$DownloadsFolder\VSCodeSetup-x64.exe"
	Verbose = $true
}
Invoke-WebRequest @Parameters

# https://code.visualstudio.com/docs/setup/windows#_common-questions
Start-Process -FilePath "$DownloadsFolder\VSCodeSetup-x64.exe" -ArgumentList "/mergetasks=`"!runcode,!addcontextmenufiles,!addcontextmenufolders,!associatewithfiles,addtopath`"" -Wait
