if (-not (Test-Path -Path Registry::HKEY_CLASSES_ROOT\.ps1))
{
	New-Item -Path Registry::HKEY_CLASSES_ROOT\.ps1 -Force
}

if (-not (Test-Path -Path Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1))
{
	New-Item -Path Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1 -Force
}
New-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1 -Name EditFlags -Type DWord -Value 131072 -Force
New-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1 -Name FriendlyTypeName -Type ExpandString -Value "@`"%systemroot%\system32\windowspowershell\v1.0\powershell.exe`",-103" -Force

if (-not (Test-Path -Path Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\DefaultIcon))
{
	New-Item -Path Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\DefaultIcon -Force
}
New-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\DefaultIcon -Name "(Default)" -Type String -Value "`"C:\Windows\System32\WindowsPowerShell\v1.0\powershell_ise.exe`",1" -Force

if (-not (Test-Path -Path Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\RunAs\Command))
{
	New-Item -Path Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\RunAs\Command -Force
}
New-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\RunAs -Name HasLUAShield -Type String -Value "" -Force
New-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\RunAs\Command -Name "(Default)" -Type String -Value "powershell.exe -NoExit -ExecutionPolicy Bypass -Command & '%1'"
