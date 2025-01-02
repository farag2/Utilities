# https://the.earth.li/~sgtatham/putty/0.58/htmldoc/Chapter4.html#config-file
if (-not (Test-Path -Path HKCU:\Software\SimonTatham\PuTTY\Sessions\V2Ray))
{
	New-Item -Path HKCU:\Software\SimonTatham\PuTTY\Sessions\V2Ray -Force
}
New-ItemProperty -Path HKCU:\Software\SimonTatham\PuTTY\Sessions\V2Ray -Name HostName -PropertyType String -Value "root@IP address" -Force
New-ItemProperty -Path HKCU:\Software\SimonTatham\PuTTY\Sessions\V2Ray -Name "ID@22:IP address" -PropertyType String -Value "value" -Force

Start-Process -FilePath $PSScriptRoot\putty.exe -Wait

Remove-Item -Path "$env:LOCALAPPDATA\PUTTY.RND", "$env:APPDATA\PUTTY.RND", HKCU:\Software\SimonTatham -Recurse -Force -ErrorAction Ignore
