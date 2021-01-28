[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Tag = ((Invoke-RestMethod -Uri "https://api.github.com/repos/ChrisAnd1998/TaskbarX/releases" -UseBasicParsing) | Where-Object -FilterScript {$_.prerelease -eq $false}).tag_name[0]
$URL = (((Invoke-WebRequest -Uri "https://api.github.com/repos/ChrisAnd1998/TaskbarX/releases" -UseBasicParsing | ConvertFrom-Json) | Where-Object -FilterScript {$_.prerelease -eq $false} | Where-Object -FilterScript {$_.tag_name -eq $Tag}).assets | Where-Object -FilterScript {$_.browser_download_url -like "*x64.zip"}).browser_download_url

$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$Parameters = @{
	Uri = $URL
	OutFile = "$DownloadsFolder\TaskbarX_v$Tag.zip"
	Verbose = [switch]::Present
}
Invoke-WebRequest @Parameters

$Parameters = @{
	Path = "$DownloadsFolder\TaskbarX_v$Tag.zip"
	DestinationPath = "$DownloadsFolder\TaskbarX"
	Force = [switch]::Present
	Verbose = [switch]::Present
}
if (Test-Path "$DownloadsFolder\TaskbarX_v$Tag.zip")
{
    Expand-Archive @Parameters
}

Remove-Item -Path "$DownloadsFolder\TaskbarX_v$Tag.zip" -Force

Move-Item -Path "$DownloadsFolder\TaskbarX" -Destination $env:ProgramFiles -Force

Start-Process -FilePath "$env:ProgramFiles\TaskbarX\TaskbarX Configurator.exe"
