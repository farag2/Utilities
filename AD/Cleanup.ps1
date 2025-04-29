#Requires -RunAsAdministrator

# Clear SCCM cache without removing persisted files
$CCMComObject = New-Object -ComObject UIResource.UIResourceMgr
$CacheInfo = $CCMComObject.GetCacheInfo().GetCacheElements()
foreach ($CacheItem in $CacheInfo)
{
	$CCMComObject.GetCacheInfo().DeleteCacheElement($CacheItem.CacheElementID)
}
Remove-Item -Path "${env:ProgramFiles(x86)}\Microsoft Intune Management Extension\Content" -Recurse -Force
Get-ChildItem -Path "$env:SystemRoot\ccmcache" -Recurse -Force | Remove-Item -Recurse -Force
# Clear Delivery optimization cache
Delete-DeliveryOptimizationCache -Force

# Remove created flags for cleanmgr task
Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches | ForEach-Object -Process {
	Remove-ItemProperty -Path $_.PsPath -Name StateFlags1337 -Force -ErrorAction Ignore
}

# Clear %SystemRoot%\SoftwareDistribution\Download folder
Get-ChildItem -Path "$env:SystemRoot\SoftwareDistribution\Download" -Recurse -Force | Remove-Item -Recurse -Force -ErrorAction Ignore

# Clear %SystemRoot%\Temp
Get-ChildItem -Path "$env:SystemRoot\Temp" -Recurse -Force -ErrorAction Ignore | Remove-Item -Recurse -Force -ErrorAction Ignore

# Clear %TEMP% folder
$userID = (Get-Process -IncludeUserName | Where-Object -FilterScript {$_.ProcessName -eq "explorer"}).UserName -split "\\" | Select-Object -Index 1
Get-ChildItem -Path "C:\Users\$userID\AppData\Local\Temp" -Recurse -Force -ErrorAction Ignore | Remove-Item -Recurse -Force -ErrorAction Ignore

# Run cleanmgr
$VolumeCaches = @(
	"Delivery Optimization Files",
	"Device Driver Packages",
	"Language Pack",
	"Previous Installations",
	"Setup Log Files",
	"System error memory dump files",
	"System error minidump files",
	"Temporary Setup Files",
	"Update Cleanup",
	"Windows Defender",
	"Windows ESD installation files",
	"Windows Upgrade Log Files"
)
foreach ($VolumeCache in $VolumeCaches)
{
	New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\$VolumeCache" -Name StateFlags1337 -PropertyType DWord -Value 2 -Force
}
Start-Process -FilePath "$env:SystemRoot\system32\cleanmgr.exe" -ArgumentList "/sagerun:1337" -Wait

Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches | ForEach-Object -Process {
	Remove-ItemProperty -Path $_.PsPath -Name StateFlags1337 -Force -ErrorAction Ignore
}

# Start-Process -FilePath "$env:SystemRoot\system32\dism.exe" -ArgumentList "/Online /English /Cleanup-Image /StartComponentCleanup /NoRestart" -Wait
