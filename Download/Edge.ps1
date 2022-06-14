# Download Microsoft Edge Stable x64
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Parameters = @{
	Uri             = "https://edgeupdates.microsoft.com/api/products"
	UseBasicParsing = $true
	Verbose         = $true
}
$LatestStableRelease = ((Invoke-RestMethod @Parameters | Where-Object -FilterScript {$_.Product -eq "Stable"}).Releases | Where-Object -FilterScript {
	$_.Platform -eq "Windows"
} | Where-Object -FilterScript {$_.Architecture -eq "x64"} | Select-Object -Index 0).Artifacts.Location

$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$Parameters = @{
	Uri             = $LatestStableRelease
	OutFile         = "$DownloadsFolder\MicrosoftEdgeEnterpriseX64.msi"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-Webrequest @Parameters

Start-Process -FilePath "$DownloadsFolder\MicrosoftEdgeEnterpriseX64.msi" -ArgumentList "/passive /norestart DONOTCREATEDESKTOPSHORTCUT=true"
