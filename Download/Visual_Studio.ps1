# https://docs.microsoft.com/en-us/visualstudio/install/create-an-offline-installation-of-visual-studio?view=vs-2022

$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$Parameters = @{
    Uri             = "https://aka.ms/vs/16/release/channel"
    OutFile         = "$DownloadsFolder\VisualStudio.16.Release.chman"
    UseBasicParsing = $true
    Verbose         = $true
}
Invoke-WebRequest @Parameters

$VS = Get-Content -Path "$DownloadsFolder\VisualStudio.16.Release.chman" -Encoding UTF8 -Force | ConvertFrom-Json
($VS.channelItems | Where-Object -FilterScript {$_.id -eq "VisualStudio.16.Release.Bootstrappers.Setup"}).payloads.url
