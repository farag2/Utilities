[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
if (-not (Test-Path -Path "$DownloadsFolder\Batman"))
{
	New-Item -Path "$DownloadsFolder\Batman" -ItemType Directory -Force
}

$Parameters = @{
	Uri             = "https://com-x.life/reader/4856/68222"
	UseBasicParsing = $false # Disabled
	Verbose         = $true
}
$Request = Invoke-Webrequest @Parameters
$JSON = ($Request.ParsedHtml.getElementsByTagName("script") | ForEach-Object -Process {$_.innerHTML} | Select-String -Pattern "is_logged" -SimpleMatch).ToString().replace(";", "").replace("window.__DATA__ = ", "") | ConvertFrom-Json

for ($i = 0; $i -lt $JSON.images.Count; $i++)
{
	$Parameters = @{
		Uri             = "https://img.com-x.life/comix/$($JSON.images[$i])"
		OutFile         = "$DownloadsFolder\Batman\$($i+1).jpg"
		UseBasicParsing = $true
		Verbose         = $true
	}
	Invoke-WebRequest @Parameters
}

Invoke-Item -Path "$DownloadsFolder\Batman"
