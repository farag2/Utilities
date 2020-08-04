New-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Adobe\Adobe Acrobat\DC\Activation" -Name IsAMTEnforced -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Adobe\Adobe Acrobat\DC\Activation" -Name DisabledActivation -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Adobe\Adobe Acrobat\DC\Activation" -Name IsAMTEnforced -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Adobe\Adobe Acrobat\DC\Activation" -Name DisabledActivation -PropertyType DWord -Value 1 -Force