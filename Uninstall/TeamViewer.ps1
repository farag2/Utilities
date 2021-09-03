# Silently uninstall TeamViewer
# Get the TeamViewer uninstall string
[string]$TeamViewerUninstallString = Get-Package -Name TeamViewer -ErrorAction Ignore | ForEach-Object -Process {$_.Meta.Attributes["UninstallString"]}
if ($TeamViewerUninstallString)
{
	# Stop all TeamViewer processes
	Stop-Process -Name TeamViewer, TeamViewer_Service, tv_w32, tv_x64 -Force
	Get-Service -Name TeamViewer | Stop-Service -Force

	# Uninstall TeamViewer. Capital "S"
	Start-Process -FilePath $TeamViewerUninstallString -ArgumentList "/S" -Wait

	# Remove leftovers
	$TeamViewerTrails = @(
		"HKLM:\Software\TeamViewer",
		"HKCU:\Software\TeamViewer",
		"$env:LOCALAPPDATA\TeamViewer",
		"$env:APPDATA\TeamViewer"
	)
	Remove-Item -Path $TeamViewerTrails -Recurse -Force
}
