# Needs UTF-8 with BOM encoding

# Generate a GUID
$GUID = [guid]::NewGuid().Guid
$Description = "Это мой бэкдор, и я дою его!"
$DefaultIcon = "%SystemRoot%\System32\imageres.dll,-4"
$TargetKnownFolder = "C:\Title"
$Title = Split-Path -Path $TargetKnownFolder -Leaf

if (-not (Test-Path -Path $TargetKnownFolder))
{
	New-Item -Path $TargetKnownFolder -ItemType Directory -Force
}

New-Item -Path "Registry::HKEY_CLASSES_ROOT\CLSID" -Name "{$GUID}" -Force
New-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\CLSID\{$GUID}" -Name "(Default)" -PropertyType String -Value "(value not set)" -Force
New-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\CLSID\{$GUID}" -Name DescriptionID -PropertyType DWord -Value 3 -Force
New-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\CLSID\{$GUID}" -Name Infotip -PropertyType ExpandString -Value $Description -Force
New-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\CLSID\{$GUID}" -Name System.IsPinnedToNameSpaceTree -PropertyType DWord -Value 1 -Force

New-Item -Path "Registry::HKEY_CLASSES_ROOT\CLSID\{$GUID}" -Name DefaultIcon -Force
New-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\CLSID\{$GUID}\DefaultIcon" -Name "(Default)" -PropertyType ExpandString -Value $DefaultIcon -Force

New-Item -Path "Registry::HKEY_CLASSES_ROOT\CLSID\{$GUID}" -Name InProcServer32 -Force
New-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\CLSID\{$GUID}\InProcServer32" -Name "(Default)" -PropertyType ExpandString -Value "%SystemRoot%\System32\shell32.dll" -Force
New-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\CLSID\{$GUID}\InProcServer32" -Name ThreadingModel -PropertyType String -Value Both -Force

New-Item -Path "Registry::HKEY_CLASSES_ROOT\CLSID\{$GUID}" -Name Instance -Force
New-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\CLSID\{$GUID}\Instance" -Name CLSID -PropertyType String -Value "{0E5AAE11-A475-4c5b-AB00-C66DE400274E}" -Force

New-Item -Path "Registry::HKEY_CLASSES_ROOT\CLSID\{$GUID}\Instance" -Name InitPropertyBag -Force
New-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\CLSID\{$GUID}\Instance\InitPropertyBag" -Name Attributes -PropertyType DWord -Value 17 -Force
New-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\CLSID\{$GUID}\Instance\InitPropertyBag" -Name TargetKnownFolder -PropertyType String -Value $TargetKnownFolder -Force

New-Item -Path "Registry::HKEY_CLASSES_ROOT\CLSID\{$GUID}" -Name ShellFolder -Force
New-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\CLSID\{$GUID}\ShellFolder" -Name Attributes -PropertyType DWord -Value 4034920525 -Force
New-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\CLSID\{$GUID}\ShellFolder" -Name FolderValueFlags -PropertyType DWord -Value 41 -Force
New-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\CLSID\{$GUID}\ShellFolder" -Name SortOrderIndex -PropertyType DWord -Value 0 -Force

New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace" -Name "{$GUID}" -Force

New-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\CLSID\{$GUID}" -Name "(Default)" -Value $Title -Force
# It's necessary to remove and then re-create the registry key
Remove-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\CLSID\{$GUID}\Instance\InitPropertyBag" -Name TargetKnownFolder -Force
New-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\CLSID\{$GUID}\Instance\InitPropertyBag" -Name TargetFolderPath -PropertyType String -Value $TargetKnownFolder -Force

# SAVE and invoke these commands to remove the created folder
Write-Verbose -Message "SAVE and invoke these commands to remove the created folder" -Verbose
Write-Verbose -Message "Remove-Item -Path `"Registry::HKEY_CLASSES_ROOT\CLSID\{$GUID}`" -Recurse -Force" -Verbose
Write-Verbose -Message "Remove-Item -Path `"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{$GUID}`" -Force" -Verbose
