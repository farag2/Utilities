# https://github.com/farag2/Utilities/blob/master/Configure_Apps_And_The_Start_Menu_Shortcuts.ps1#L255
New-ItemProperty -LiteralPath Registry::HKEY_CLASSES_ROOT\*\shell\Paint.NET -Name "(Default)" -PropertyType String -Value "Открыть с помощью Paint.NET" -Force
