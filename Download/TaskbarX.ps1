cls
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Parameters = @{
	Uri             = "https://api.github.com/repos/ChrisAnd1998/TaskbarX/releases/latest"
	UseBasicParsing = $true
}
$URL = ((Invoke-RestMethod @Parameters).assets | Where-Object -FilterScript {$_.name -match "x64.zip"}).browser_download_url

$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$Parameters = @{
	Uri             = $URL
	OutFile         = "$DownloadsFolder\TaskbarX.zip"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-WebRequest @Parameters

Get-Process -Name "TaskbarX Configurator", "TaskbarX" -ErrorAction Ignore | Stop-Process -Force

$Parameters = @{
	Path            = "$DownloadsFolder\TaskbarX.zip"
	DestinationPath = "$env:ProgramFiles\TaskbarX"
	Force           = $true
	Verbose         = $true
}
Expand-Archive @Parameters

Remove-Item -Path "$DownloadsFolder\TaskbarX.zip" -Force

# TaskbarX advices not to run the Configurator as admin. Do it manually
# Start-Process -FilePath "$env:ProgramFiles\TaskbarX\TaskbarX Configurator.exe"

Invoke-Item -Path "$env:ProgramFiles\TaskbarX"
