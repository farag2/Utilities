cls
# https://docs.microsoft.com/en-us/windows/terminal/

if ($psISE)
{
	exit
}

# Get the latest PSReadLine version number
$LatestRelease = (Invoke-RestMethod -Uri "https://api.github.com/repos/PowerShell/PSReadLine/releases/latest").tag_name.Replace("v","")
if (Test-Path -Path "$env:ProgramFiles\WindowsPowerShell\Modules\PSReadline")
{
	$CurrentVersion = (Get-Module -Name PSReadline).Version.ToString()
}

# If PSReadline is installed
if ($null -ne (Get-Module -Name PSReadline))
{
	if ([System.Version]$LatestRelease -gt [System.Version]$CurrentRelease)
	{
		# Intalling the latest PSReadLine
		# https://github.com/PowerShell/PSReadLine/releases
		if (-not (Get-Package -Name NuGet -Force -ErrorAction Ignore))
		{
			Install-Package -Name NuGet -Force
		}
		Install-Module -Name PSReadLine -RequiredVersion $LatestRelease -Force

		Import-Module -Name PSReadLine

		# Removing the old PSReadLine
		$PSReadLine = @{
			ModuleName    = "PSReadLine"
			ModuleVersion = $CurrentVersion
		}
		Remove-Module -FullyQualifiedName $PSReadLine -Force
		Get-InstalledModule -Name PSReadline -AllVersions | Where-Object -FilterScript {$_.Version -eq $CurrentVersion} | Uninstall-Module -Force
		Remove-Item -Path $env:ProgramFiles\WindowsPowerShell\Modules\PSReadline\$CurrentVersion -Recurse -Force -ErrorAction Ignore

		Get-InstalledModule -Name PSReadline -AllVersions

		Write-Verbose -Message "Restart the PowerShell session, and re-run the script" -Verbose

		exit
	}
}
else
{
	# Intalling the latest PSReadLine
	# https://github.com/PowerShell/PSReadLine/releases
	if (-not (Get-Package -Name NuGet -Force -ErrorAction Ignore))
	{
		Install-Package -Name NuGet -Force
	}
	Install-Module -Name PSReadLine -RequiredVersion $LatestRelease -Force

	Import-Module -Name PSReadLine

	Write-Verbose -Message "Restart the PowerShell session, and re-run the script" -Verbose

	exit
}

# Downloading Windows95.gif
# https://github.com/farag2/Utilities/tree/master/Windows%20Terminal
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not (Test-Path -Path "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\RoamingState\Windows95.gif"))
{
	$Parameters = @{
		Uri = "https://github.com/farag2/Utilities/raw/master/Windows%20Terminal/Windows95.gif"
		OutFile = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\RoamingState\Windows95.gif"
		Verbose = [switch]::Present
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
	exit
}

# Removing all comments to parse JSON file
if (Get-Content -Path $settings | Select-String -Pattern "//" -SimpleMatch)
{
	Set-Content -Path $settings -Value (Get-Content -Path $settings | Select-String -Pattern "//" -NotMatch) -Force
}

# Deleting all blank lines from JSON file
(Get-Content -Path $settings) | Where-Object -FilterScript {$_.Trim(" `t")} | Set-Content -Path $settings -Force

try
{
	$Terminal = Get-Content -Path $settings -Force | ConvertFrom-Json
}
catch [System.Exception]
{
	Write-Verbose "JSON is not valid!" -Verbose

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

# Show tabs in title bar
if ($Terminal.showTabsInTitlebar)
{
	$Terminal.showTabsInTitlebar = $false
}
else
{
	$Terminal | Add-Member -Name showTabsInTitlebar -MemberType NoteProperty -Value $false -Force
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
$DesktopFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name Desktop
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
	$Terminal.trimBlockSelection = $tru
}
else
{
	$Terminal | Add-Member -Name trimBlockSelection -MemberType NoteProperty -Value $true -Force
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
		($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"}).name = "PowerShell 7"
	}
	else
	{
		$Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"} | Add-Member -MemberType NoteProperty -Name name -Value "PowerShell 7" -Force
	}

	# Set the PowerShell 7 tab icon
	if (($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"}).icon)
	{
		($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"}).icon = "🏆"
	}
	else
	{
		$Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"} | Add-Member -MemberType NoteProperty -Name icon -Value "🏆" -Force
	}
}

if (Test-Path -Path "$env:ProgramFiles\PowerShell\7-preview")
{
	# Background image stretch mode
	if (($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{a3a2e83a-884a-5379-baa8-16f193a13b21}"}).name)
	{
		($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{a3a2e83a-884a-5379-baa8-16f193a13b21}"}).name = "PowerShell 7 Preview"
	}
	else
	{
		$Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{a3a2e83a-884a-5379-baa8-16f193a13b21}"} | Add-Member -MemberType NoteProperty -Name name -Value "PowerShell 7" -Force
	}

	# Set the icon that displays within the tab, dropdown menu, jumplist, and tab switcher
	if (($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{a3a2e83a-884a-5379-baa8-16f193a13b21}"}).icon)
	{
		($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{a3a2e83a-884a-5379-baa8-16f193a13b21}"}).icon = "🐷"
	}
	else
	{
		$Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{a3a2e83a-884a-5379-baa8-16f193a13b21}"} | Add-Member -MemberType NoteProperty -Name icon -Value "🐷" -Force
	}
}

#endregion Powershell Core

ConvertTo-Json -InputObject $Terminal -Depth 4 | Set-Content -Path $settings -Force

# Remove the "Open in Windows Terminal" context menu item
if (-not (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked"))
{
	New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" -Force
}
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" -Name "{9F156763-7844-4DC4-B2B1-901F640F5155}" -PropertyType String -Value "WindowsTerminal" -Force

# Refresh desktop icons, environment variables, taskbar
$UpdateExplorer = @{
	Namespace = "WinAPI"
	Name = "UpdateExplorer"
	Language = "CSharp"
	MemberDefinition = @"
private static readonly IntPtr HWND_BROADCAST = new IntPtr(0xffff);
private const int WM_SETTINGCHANGE = 0x1a;
private const int SMTO_ABORTIFHUNG = 0x0002;

[DllImport("shell32.dll", CharSet = CharSet.Auto, SetLastError = false)]
private static extern int SHChangeNotify(int eventId, int flags, IntPtr item1, IntPtr item2);
[DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = false)]
private static extern IntPtr SendMessageTimeout(IntPtr hWnd, int Msg, IntPtr wParam, string lParam, int fuFlags, int uTimeout, IntPtr lpdwResult);

public static void Refresh()
{
	// Update desktop icons
	SHChangeNotify(0x8000000, 0x1000, IntPtr.Zero, IntPtr.Zero);

	// Update environment variables
	SendMessageTimeout(HWND_BROADCAST, WM_SETTINGCHANGE, IntPtr.Zero, null, SMTO_ABORTIFHUNG, 100, IntPtr.Zero);
}
"@
}

if (-not ("WinAPI.UpdateExplorer" -as [type]))
{
	Add-Type @UpdateExplorer
}

# Refresh desktop icons, environment variables, taskbar
[WinAPI.UpdateExplorer]::Refresh()
