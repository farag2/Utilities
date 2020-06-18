[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$Parameters = @{
	Uri = "https://downloads.abbyy.com/fr/fr_win/current/ABBYY_FineReader_15_Multi.exe?secure=jcTcwx6ACmjnpmDBzu5AWA=="
	OutFile = "$DownloadsFolder\ABBYY_FineReader_15_Multi.exe"
	Verbose = [switch]::Present
}
Invoke-WebRequest @Parameters

$Arguments = @(
	"-d`"$DownloadsFolder\FineReaderTemp`""
	"-s2"
)
# -Wait argument doesn't help
Start-Process "$DownloadsFolder\ABBYY_FineReader_15_Multi.exe" -ArgumentList $Arguments

do
{
	$Process = Get-Process -Name AutoRun -ErrorAction Ignore
	if (-not ($Process))
	{
		Start-Sleep -Milliseconds 500
	}
}
until ($Process)
Start-Sleep -Seconds 1
Stop-Process -Name AutoRun -Force -ErrorAction Ignore

Get-ChildItem -Path "$DownloadsFolder\FineReaderTemp" -Exclude 1049.mst -Filter *.mst -Depth 0 -Force | Remove-Item -Force
Remove-Item -Path "$DownloadsFolder\FineReaderTemp\ABBYY FineReader 15.msi" -Force
Remove-Item -Path "$DownloadsFolder\FineReaderTemp\AutoRun*" -Recurse -Force
Remove-Item -Path "$DownloadsFolder\FineReaderTemp\License Server" -Recurse -Force
Remove-Item -Path "$DownloadsFolder\FineReaderTemp\ABBYY FineReader 15\Module86" -Recurse -Force