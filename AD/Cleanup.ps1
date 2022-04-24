$VolumeCaches = @(
	# Delivery Optimization Files
	"Delivery Optimization Files",

	# Device driver packages
	"Device Driver Packages",

	# Previous Windows Installation(s)
	"Previous Installations",

	# Setup log files
	"Setup Log Files",

	# Temporary Setup Files
	"Temporary Setup Files",

	# Windows Update Cleanup
	"Update Cleanup",

	# Microsoft Defender
	"Windows Defender",

	# Windows upgrade log files
	"Windows Upgrade Log Files"
)
foreach ($VolumeCache in $VolumeCaches)
{
	New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\$VolumeCache" -Name StateFlags1337 -PropertyType DWord -Value 2 -Force
}

Start-Process -FilePath "$env:SystemRoot\system32\cleanmgr.exe" -ArgumentList "/sagerun:1337"
Start-Process -FilePath "$env:SystemRoot\system32\dism.exe" -ArgumentList "/Online /English /Cleanup-Image /StartComponentCleanup /NoRestart"

# Clear SCCM cache without removing persisted files
# Get-ChildItem -Path $env:SystemRoot\ccmcache -Recurse -Force | Remove-Item -Recurse -Force
(New-Object -ComObject UIResource.UIResourceMgr).GetCacheInfo().GetCacheElements() | ForEach-Object -Process {
	(New-Object -ComObject UIResource.UIResourceMgr).GetCacheInfo().DeleteCacheElementEx($_.CacheElementID, $false)
}

Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches | ForEach-Object -Process {
	Remove-ItemProperty -Path $_.PsPath -Name StateFlags1337 -Force -ErrorAction Ignore
}
