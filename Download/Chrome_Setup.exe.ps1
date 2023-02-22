# Download Chrome installer (.exe)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# https://chromium.googlesource.com/chromium/src/+/refs/heads/main/chrome/install_static/google_chrome_install_modes.cc#35
$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$XML = @"
<?xml version="1.0" encoding="UTF-8"?>
<request protocol="3.0" ismachine="1" installsource="ondemand" dedup="cr">
    <hw physmemory="4" sse3="1"/>
    <os platform="win" version="10.0" arch="x64"/>
    <app appid="{8A69D345-D564-463C-AFF1-A69D9E530F96}" release_channel="stable"><updatecheck/></app>
</request>
"@
Set-Content -Path "$DownloadsFolder\in.xml" -Value $XML -Encoding UTF8 -Force

$Parameters = @{
    Uri             = "https://tools.google.com/service/update2"
    Method          = "POST"
    ContentType     = "text/xml"
    InFile          = "$DownloadsFolder\in.xml"
    OutFile         = "$DownloadsFolder\out.xml"
    UseBasicParsing = $true
    Verbose         = $true
}
Invoke-WebRequest @Parameters

[xml]$XMLFile = Get-Content -Path "$DownloadsFolder\out.xml" -Encoding UTF8 -Force
$FirstPart = $XMLFile.response.app.updatecheck.urls.url.codebase | Where-Object -FilterScript {$_ -match "https"} | Select-Object -Index 1
$SecondPart = ($XMLFile.response.app.updatecheck.manifest.packages.package).name
$URL = "$($FirstPart)$($SecondPart)"

$Parameters = @{
	Uri     = $URL
	OutFile = "$DownloadsFolder\$SecondPart"
	Verbose = $true
}
Invoke-WebRequest @Parameters

Remove-Item -Path "$DownloadsFolder\in.xml", "$DownloadsFolder\out.xml" -Force

Start-Process -FilePath "$DownloadsFolder\$SecondPart" -Wait
