Clear-Host

Start-Process $PSScriptRoot\..\TeamViewer.exe

do
{
	$Process = Get-Process | Where-Object -FilterScript {$_.Name -eq "TeamViewer"}
	if ($Process)
	{
		# "Still running: TeamViewer"
		Start-Sleep 1
	}
}
until (-not ($Process))

Start-Sleep -Seconds 3
TAKEOWN /F $PSScriptRoot\..\rolloutfile.tv13
ICACLS $PSScriptRoot\..\rolloutfile.tv13 --% /grant:r %USERNAME%:F
Remove-Item -Path $PSScriptRoot\..\rolloutfile.tv13 -Force
Remove-Item -Path HKCU:\Software\TeamViewer -Recurse -Force -ErrorAction Ignore
Remove-Item $env:LOCALAPPDATA\TeamViewer -Recurse -Force
Remove-Item $env:APPDATA\TeamViewer -Recurse -Force
exit