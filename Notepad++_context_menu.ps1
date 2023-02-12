# https://github.com/farag2/Utilities/blob/dbd4963dab5af40c4980ecc9b80b39ec920081e2/Configure_Apps_And_The_Start_Menu_Shortcuts.ps1#L221
New-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\CLSID\{B298D29A-A6ED-11DE-BA8C-A68E55D89593}\Settings" -Name Title -PropertyType String -Value "Открыть с помощью &Notepad++" -Force
