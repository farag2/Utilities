#Requires -RunAsAdministrator

# https://docs.microsoft.com/en-us/windows/terminal/
# https://github.com/microsoft/terminal/releases

Clear-Host

if ($psISE)
{
	exit
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Installing the latest NuGet
if (-not (Test-Path -Path "$env:ProgramFiles\PackageManagement\ProviderAssemblies\nuget\*\Microsoft.PackageManagement.NuGetProvider.dll"))
{
	Write-Verbose -Message "Installing NuGet" -Verbose

	Install-PackageProvider -Name NuGet -Force
}
if ($null -eq (Get-PackageProvider -ListAvailable | Where-Object -FilterScript {$_.Name -ceq "NuGet"} -ErrorAction Ignore))
{
	Write-Verbose -Message "Installing NuGet" -Verbose

	Install-PackageProvider -Name NuGet -Force
}

# Installing the latest PowerShellGet & PackageManagement
# https://www.powershellgallery.com/packages/PowerShellGet
# https://github.com/PowerShell/PowerShellGet
# https://www.powershellgallery.com/packages/PackageManagement
# https://devblogs.microsoft.com/powershell/powershellget-3-0-preview-1/
$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$Parameters = @{
	Uri             = "https://raw.githubusercontent.com/PowerShell/PowerShellGet/master/src/PowerShellGet.psd1"
	OutFile         = "$DownloadsFolder\PowerShellGet.psd1"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-WebRequest @Parameters

# Get the latest PowerShellGet version
$LatestPowerShellGetVersion = (Import-PowerShellDataFile -Path "$DownloadsFolder\PowerShellGet.psd1").ModuleVersion
Remove-Item -Path "$DownloadsFolder\PowerShellGet.psd1" -Force

if ($null -eq (Get-Module -Name PowerShellGet -ErrorAction Ignore))
{
	try
	{
		Import-Module -Name PowerShellGet -Force -ErrorAction Stop
		$CurrentPowerShellGetVersion = (Get-Module -Name PowerShellGet | Select-Object -Index 0).Version.ToString()
	}
	catch
	{
		Write-Verbose -Message "PowerShellGet module doesn't exist" -Verbose
		Write-Verbose -Message "Installing PowerShellGet 2.2.5 & PackageManagement 1.4.7" -Verbose

		Install-Module -Name PowerShellGet -Force
		Remove-Module -Name PowerShellGet -Force

		# Removing all PowerShellGet folders except the latest and the default ones
		Get-Childitem -Path "$env:ProgramFiles\WindowsPowerShell\Modules\PowerShellGet" -Force | Where-Object -FilterScript {$_.Name -ne "2.2.5"} | Remove-Item -Recurse -Force

		Import-Module -Name PowerShellGet -RequiredVersion 2.2.5 -Force
		Import-Module -Name PackageManagement -RequiredVersion 1.4.7 -Force

		Write-Verbose -Message "PowerShellGet 2.2.5 & PackageManagement 1.4.7 installed. Restart the PowerShell session, and re-run the script" -Verbose

		exit
	}
}
else
{
	$CurrentPowerShellGetVersion = (Get-Module -Name PowerShellGet | Select-Object -Index 0).Version.ToString()
}

if ([System.Version]$CurrentPowerShellGetVersion -lt [System.Version]"2.2.5")
{
		Write-Verbose -Message "Installing PowerShellGet & PackageManagement" -Verbose

		Install-Module -Name PowerShellGet -Force
		Remove-Module -Name PowerShellGet -Force

		# Removing all PowerShellGet folders except the latest and the default ones
		Get-Childitem -Path "$env:ProgramFiles\WindowsPowerShell\Modules\PowerShellGet" -Force | Where-Object -FilterScript {$_.Name -ne "2.2.5"} | Remove-Item -Recurse -Force

		Import-Module -Name PowerShellGet -RequiredVersion 2.2.5 -Force
		Import-Module -Name PackageManagement -RequiredVersion 1.4.7 -Force

		Write-Verbose -Message "PowerShellGet 2.2.5 & PackageManagement 1.4.7 installed. Restart the PowerShell session, and re-run the script" -Verbose

		exit
}

if ([System.Version]$CurrentPowerShellGetVersion -lt [System.Version]$LatestPowerShellGetVersion)
{
		Write-Verbose -Message "Installing PowerShellGet $($LatestPowerShellGetVersion)" -Verbose

		# We cannot install the preview build immediately due to the default 1.0.0.1 build doesn't support -AllowPrerelease
		Install-Module -Name PowerShellGet -AllowPrerelease -Force

		Write-Verbose -Message "PowerShellGet $($LatestPowerShellGetVersion) installed. Restart the PowerShell session, and re-run the script" -Verbose

		exit
}

# Installing the latest PSReadLine
# https://github.com/PowerShell/PSReadLine/releases
# https://www.powershellgallery.com/packages/PSReadLine
$Parameters = @{
	Uri            = "https://api.github.com/repos/PowerShell/PSReadLine/releases"
	UseBasicParsing = $true
}
$LatestPSReadLineVersion = (Invoke-RestMethod @Parameters | Where-Object -FilterScript {$_.prerelease -eq $true}).tag_name.Replace("v", "") | Select-Object -First 1
# Remove "-beta" in the release version

if ($null -eq (Get-Module -Name PSReadline -ListAvailable -ErrorAction Ignore))
{
	Write-Verbose -Message "PSReadline module doesn't exist" -Verbose
	Write-Verbose -Message "Installing PSReadline" -Verbose

	Install-Module -Name PSReadline -AllowPrerelease -Force
	Remove-Module -Name PowerShellGet -Force

	Write-Verbose -Message "PSReadline installed. Restart the PowerShell session, and re-run the script" -Verbose

	exit
}
else
{
	$CurrentPSReadlineVersion = (Get-Module -Name PSReadline).Version.ToString()
}

# Installing the latest PSReadLine
if ([System.Version]$CurrentPSReadlineVersion -lt [System.Version]$LatestPSReadLineVersion)
{
	Write-Verbose -Message "Installing PSReadLine $($LatestPSReadLineVersion)" -Verbose

	Install-Module -Name PSReadline -AllowPrerelease -Force

	Write-Verbose -Message "PSReadLine installed. Restart the PowerShell session and re-run the script" -Verbose

	exit
}

if ([System.Version]$CurrentPSReadlineVersion -eq [System.Version]$LatestPSReadLineVersion)
{
	# Removing all PSReadLine folders except the latest and the default ones
	Get-Childitem -Path "$env:ProgramFiles\WindowsPowerShell\Modules\PSReadLine" -Force | Where-Object -FilterScript {$_.Name -ne $LatestPSReadLineVersion} | Remove-Item -Recurse -Force
}

# Downloading Windows95.gif
# https://github.com/farag2/Utilities/tree/master/Windows%20Terminal
if (-not (Test-Path -Path "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\RoamingState\Windows95.gif"))
{
	$Parameters = @{
		Uri             = "https://github.com/farag2/Utilities/raw/master/Windows_Terminal/Windows95.gif"
		OutFile         = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\RoamingState\Windows95.gif"
		UseBasicParsing = $true
		Verbose         = $true
	}
	Invoke-WebRequest @Parameters
}

if (Test-Path -Path "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json")
{
	$settings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
}
else
{
	Start-Process -FilePath wt -Wait

	Write-Verbose -Message "Restart the PowerShell session and re-run the script" -Verbose

	exit
}

# Removing all comments to parse JSON file
if (Get-Content -Path $settings -Encoding UTF8 -Force | Select-String -Pattern "//" -SimpleMatch)
{
	Set-Content -Path $settings -Value (Get-Content -Path $settings -Encoding UTF8 -Force | Select-String -Pattern "//" -NotMatch) -Encoding UTF8 -Force
}

# Deleting all blank lines from JSON file
(Get-Content -Path $settings -Force) | Where-Object -FilterScript {$_.Trim(" `t")} | Set-Content -Path $settings -Encoding UTF8 -Force

try
{
	$Terminal = Get-Content -Path $settings -Encoding UTF8 -Force | ConvertFrom-Json
}
catch [System.Exception]
{
	Write-Verbose "JSON is not valid!" -Verbose

	Invoke-Item -Path "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"

	break
}

#region General
# Close tab
if (-not ($Terminal.actions | Where-Object -FilterScript {$_.command -eq "closeTab"} | Where-Object -FilterScript {$_.keys -eq "ctrl+w"}))
{
	$closeTab = [PSCustomObject]@{
		"command" = "closeTab"
		"keys" = "ctrl+w"
	}
	$Terminal.actions += $closeTab
}

# New tab
if (-not ($Terminal.actions | Where-Object -FilterScript {$_.command -eq "newTab"} | Where-Object -FilterScript {$_.keys -eq "ctrl+t"}))
{
	$newTab = [PSCustomObject]@{
		"command" = "newTab"
		"keys" = "ctrl+t"
	}
	$Terminal.actions += $newTab
}

# Find
if (-not ($Terminal.actions | Where-Object -FilterScript {$_.command -eq "find"} | Where-Object -FilterScript {$_.keys -eq "ctrl+f"}))
{
	$find = [PSCustomObject]@{
		"command" = "find"
		"keys" = "ctrl+f"
	}
	$Terminal.actions += $find
}

# Split pane
if (-not ($Terminal.actions | Where-Object -FilterScript {$_.command.action -eq "splitPane"} | Where-Object -FilterScript {$_.command.split -eq "auto"} | Where-Object -FilterScript {$_.command.splitMode -eq "duplicate"}))
{
	$split = [PSCustomObject]@{
		"action" = "splitPane"
		"split" = "auto"
		"splitMode" = "duplicate"
	}
	$splitPane = [PSCustomObject]@{
		"command" = $split
		"keys" = "ctrl+shift+d"
	}
	$Terminal.actions += $splitPane
}

# No confirmation when closing all tabs
if ($Terminal.confirmCloseAllTabs)
{
	$Terminal.confirmCloseAllTabs = $false
}
else
{
	$Terminal | Add-Member -Name confirmCloseAllTabs -MemberType NoteProperty -Value $false -Force
}

# Set default profile on PowerShell
if ($Terminal.defaultProfile)
{
	$Terminal.defaultProfile = "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}"
}
else
{
	$Terminal | Add-Member -Name defaultProfile -MemberType NoteProperty -Value "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}" -Force
}

# Show tabs in title bar
if ($Terminal.showTabsInTitlebar)
{
	$Terminal.showTabsInTitlebar = $false
}
else
{
	$Terminal | Add-Member -Name showTabsInTitlebar -MemberType NoteProperty -Value $false -Force
}

# Do not restore previous tabs and panes after relaunching
if ($Terminal.firstWindowPreference)
{
	$Terminal.firstWindowPreference = "defaultProfile"
}
else
{
	$Terminal | Add-Member -Name firstWindowPreference -MemberType NoteProperty -Value "defaultProfile" -Force
}
#endregion General

#region defaults
# Set Windows95.gif as a background image
if ($Terminal.profiles.defaults.backgroundImage)
{
	$Terminal.profiles.defaults.backgroundImage = "ms-appdata:///roaming/Windows95.gif"
}
else
{
	$Terminal.profiles.defaults | Add-Member -Name backgroundImage -MemberType NoteProperty -Value "ms-appdata:///roaming/Windows95.gif" -Force
}

# Background image alignment
if ($Terminal.profiles.defaults.backgroundImageAlignment)
{
	$Terminal.profiles.defaults.backgroundImageAlignment = "bottomRight"
}
else
{
	$Terminal.profiles.defaults | Add-Member -Name backgroundImageAlignment -MemberType NoteProperty -Value bottomRight -Force
}

# Background image opacity
$Value = 0.3
if ($Terminal.profiles.defaults.backgroundImageOpacity)
{
	$Terminal.profiles.defaults.backgroundImageOpacity = $Value
}
else
{
	$Terminal.profiles.defaults | Add-Member -Name backgroundImageOpacity -MemberType NoteProperty -Value 0.3 -Force
}

# Background image stretch mode
if ($Terminal.profiles.defaults.backgroundImageStretchMode)
{
	$Terminal.profiles.defaults.backgroundImageStretchMode = "none"
}
else
{
	$Terminal.profiles.defaults | Add-Member -Name backgroundImageStretchMode -MemberType NoteProperty -Value none -Force
}

# Starting directory
$DesktopFolder = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name Desktop
if ($Terminal.profiles.defaults.startingDirectory)
{
	$Terminal.profiles.defaults.startingDirectory = $DesktopFolder
}
else
{
	$Terminal.profiles.defaults | Add-Member -Name startingDirectory -MemberType NoteProperty -Value $DesktopFolder -Force
}

# Use acrylic
if ($Terminal.profiles.defaults.useAcrylic)
{
	$Terminal.profiles.defaults.useAcrylic = $true
}
else
{
	$Terminal.profiles.defaults | Add-Member -Name useAcrylic -MemberType NoteProperty -Value $true -Force
}

# Acrylic opacity
if ($Terminal.useAcrylicInTabRow)
{
	$Terminal.useAcrylicInTabRow = $true
}
else
{
	$Terminal | Add-Member -Name useAcrylicInTabRow -MemberType NoteProperty -Value $true -Force
}

# Show acrylic in tab row
if ($Terminal.profiles.defaults.useAcrylic)
{
	$Terminal.profiles.defaults.useAcrylic = $true
}
else
{
	$Terminal.profiles.defaults | Add-Member -Name useAcrylic -MemberType NoteProperty -Value $true -Force
}


# Run profile as Administrator by default
if ($Terminal.profiles.defaults.elevate)
{
	$Terminal.profiles.defaults.elevate = $true
}
else
{
	$Terminal.profiles.defaults | Add-Member -MemberType NoteProperty -Name elevate -Value $true -Force
}

# Set "Cascadia Mono" as a default font
[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null

if ((New-Object -TypeName System.Drawing.Text.InstalledFontCollection).Families.Name -contains "Cascadia Mono")
{
	if ($Terminal.profiles.defaults.fontFace)
	{
		$Terminal.profiles.defaults.fontFace = "Cascadia Mono"
	}
	else
	{
		$Terminal.profiles.defaults | Add-Member -Name fontFace -MemberType NoteProperty -Value "Cascadia Mono" -Force
	}
}

# Remove trailing white-space in rectangular selection
if ($Terminal.trimBlockSelection)
{
	$Terminal.trimBlockSelection = $true
}
else
{
	$Terminal | Add-Member -Name trimBlockSelection -MemberType NoteProperty -Value $true -Force
}

# Create new tabs in the most recently used window on this desktop. If there's not an existing window on this virtual desktop, then create a new terminal window
if ($Terminal.windowingBehavior)
{
	$Terminal.windowingBehavior = "useExisting"
}
else
{
	$Terminal | Add-Member -Name windowingBehavior -MemberType NoteProperty -Value "useExisting" -Force
}
#endregion defaults

#region Azure
# Hide Azure
if (($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{b453ae62-4e3d-5e58-b989-0a998ec441b8}"}).hidden)
{
	($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{b453ae62-4e3d-5e58-b989-0a998ec441b8}"}).hidden = $true
}
else
{
	$Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{b453ae62-4e3d-5e58-b989-0a998ec441b8}"} | Add-Member -MemberType NoteProperty -Name hidden -Value $true -Force
}
#endregion Azure

#region Powershell Core
if (Test-Path -Path "$env:ProgramFiles\PowerShell\7")
{
	# Set the PowerShell 7 tab name
	if (($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"}).name)
	{
		($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"}).name = "🏆 PowerShell 7"
	}
	else
	{
		$Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"} | Add-Member -MemberType NoteProperty -Name name -Value "🏆 PowerShell 7" -Force
	}

	# Run this profile as Administrator by default
	if (($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"}).elevate)
	{
		($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"}).elevate = $true
	}
	else
	{
		$Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"} | Add-Member -MemberType NoteProperty -Name elevate -Value $true -Force
	}
}

if (Test-Path -Path "$env:ProgramFiles\PowerShell\7-preview")
{
	# Background image stretch mode
	if (($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{a3a2e83a-884a-5379-baa8-16f193a13b21}"}).name)
	{
		($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{a3a2e83a-884a-5379-baa8-16f193a13b21}"}).name = "🐷 PowerShell 7 Preview"
	}
	else
	{
		$Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{a3a2e83a-884a-5379-baa8-16f193a13b21}"} | Add-Member -MemberType NoteProperty -Name name -Value "🐷 PowerShell 7 Preview" -Force
	}
}
#endregion Powershell Core

ConvertTo-Json -InputObject $Terminal -Depth 4 | Set-Content -Path $settings -Encoding UTF8 -Force
# Re-save in the UTF-8 without BOM encoding due to JSON must not has the BOM: https://datatracker.ietf.org/doc/html/rfc8259#section-8.1
Set-Content -Value (New-Object -TypeName System.Text.UTF8Encoding -ArgumentList $false).GetBytes($(Get-Content -Path $settings -Raw)) -Encoding Byte -Path $settings -Force

# Remove the "Open in Windows Terminal" context menu item
if (-not (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked"))
{
	New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" -Force
}
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" -Name "{9F156763-7844-4DC4-B2B1-901F640F5155}" -PropertyType String -Value "WindowsTerminal" -Force

# Set Windows Terminal as default terminal app to host the user interface for command-line applications
$TerminalVersion = (Get-AppxPackage -Name Microsoft.WindowsTerminal).Version
if ([System.Version]$TerminalVersion -ge [System.Version]"1.11")
{
	if (-not (Test-Path -Path "HKCU:\Console\%%Startup"))
	{
		New-Item -Path "HKCU:\Console\%%Startup" -Force
	}

	# Find the current GUID of Windows Terminal
	$PackageFullName = (Get-AppxPackage -Name Microsoft.WindowsTerminal).PackageFullName
		Get-ChildItem -Path "HKLM:\SOFTWARE\Classes\PackagedCom\Package\$PackageFullName\Class" | ForEach-Object -Process {
		if ((Get-ItemPropertyValue -Path $_.PSPath -Name ServerId) -eq 0)
		{
			New-ItemProperty -Path "HKCU:\Console\%%Startup" -Name DelegationConsole -PropertyType String -Value $_.PSChildName -Force
		}

		if ((Get-ItemPropertyValue -Path $_.PSPath -Name ServerId) -eq 1)
		{
			New-ItemProperty -Path "HKCU:\Console\%%Startup" -Name DelegationTerminal -PropertyType String -Value $_.PSChildName -Force
		}
	}
}
