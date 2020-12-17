# https://docs.microsoft.com/en-us/windows/terminal/
# https://github.com/microsoft/terminal/issues/1555#issuecomment-505157311

# Get the latest PSReadLine version number
# ((Invoke-WebRequest -Uri "https://api.github.com/repos/PowerShell/PSReadLine/releases" -UseBasicParsing | ConvertFrom-Json) | Where-Object -FilterScript {$_.prerelease -eq $false})[0].tag_name.Replace("v","")
$LatestRelease = ((Invoke-RestMethod -Uri "https://api.github.com/repos/PowerShell/PSReadLine/releases") | Where-Object -FilterScript {$_.prerelease -eq $false}).tag_name.Replace("v","")[0]

$CurrentVersion = (Get-Module -Name PSReadline).Version.ToString()
if ($CurrentVersion -ne $LatestRelease)
{
	# Intalling the latest PSReadLine
	# https://github.com/PowerShell/PSReadLine/releases
	if (-not (Get-Package -Name NuGet -Force -ErrorAction Ignore))
	{
		Install-Package -Name NuGet -Force
	}
	Install-Module -Name PSReadLine -RequiredVersion $LatestRelease -Force

	# Removing the old PSReadLine
	$PSReadLine = @{
		ModuleName = "PSReadLine"
		ModuleVersion = $CurrentVersion
	}
	Remove-Module -FullyQualifiedName $PSReadLine -Force
	Get-InstalledModule -Name PSReadline -AllVersions | Where-Object -FilterScript {$_.Version -eq $CurrentVersion} | Uninstall-Module -Force
	Remove-Item -Path $env:ProgramFiles\WindowsPowerShell\Modules\PSReadline\$CurrentVersion -Recurse -Force -ErrorAction Ignore

	Get-InstalledModule -Name PSReadline -AllVersions
	Write-Verbose -Message "Restart the session" -Verbose
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

$settings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

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

#region PowerShell
# Set Windows95.gif as a background image
if ($Terminal.profiles.list[0].backgroundImage)
{
	$Terminal.profiles.list[0].backgroundImage = "ms-appdata:///roaming/Windows95.gif"
}
else
{
	$Terminal.profiles.list[0] | Add-Member -Name backgroundImage -MemberType NoteProperty -Value "ms-appdata:///roaming/Windows95.gif" -Force
}

# Background image alignment
if ($Terminal.profiles.list[0].backgroundImageAlignment)
{
	$Terminal.profiles.list[0].backgroundImageAlignment = "bottomRight"
}
else
{
	$Terminal.profiles.list[0] | Add-Member -Name backgroundImageAlignment -MemberType NoteProperty -Value bottomRight -Force
}

# Background image opacity
$Value = 0.3
if ($Terminal.profiles.list[0].backgroundImageOpacity)
{
	$Terminal.profiles.list[0].backgroundImageOpacity = $Value
}
else
{
	$Terminal.profiles.list[0] | Add-Member -Name backgroundImageOpacity -MemberType NoteProperty -Value 0.3 -Force
}

# Background image stretch mode
if ($Terminal.profiles.list[0].backgroundImageStretchMode)
{
	$Terminal.profiles.list[0].backgroundImageStretchMode = "none"
}
else
{
	$Terminal.profiles.list[0] | Add-Member -Name backgroundImageStretchMode -MemberType NoteProperty -Value none -Force
}

# Starting directory
$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name Desktop
if ($Terminal.profiles.list[0].startingDirectory)
{
	$Terminal.profiles.list[0].startingDirectory = $DownloadsFolder
}
else
{
	$Terminal.profiles.list[0] | Add-Member -Name startingDirectory -MemberType NoteProperty -Value $DownloadsFolder -Force
}

# Use acrylic
if ($Terminal.profiles.list[0].useAcrylic)
{
	$Terminal.profiles.list[0].useAcrylic = $true
}
else
{
	$Terminal.profiles.list[0] | Add-Member -Name useAcrylic -MemberType NoteProperty -Value $true -Force
}

# Acrylic opacity
$Value = 0.75
if ($Terminal.profiles.list[0].acrylicOpacity)
{
	$Terminal.profiles.list[0].acrylicOpacity = $Value
}
else
{
	$Terminal.profiles.list[0] | Add-Member -Name acrylicOpacity -MemberType NoteProperty -Value 0.75 -Force
}
#endregion PowerShell

#region CMD
# Set Windows95.gif as a background image
if ($Terminal.profiles.list[1].backgroundImage)
{
	$Terminal.profiles.list[1].backgroundImage = "ms-appdata:///roaming/Windows95.gif"
}
else
{
	$Terminal.profiles.list[1] | Add-Member -Name backgroundImage -MemberType NoteProperty -Value "ms-appdata:///roaming/Windows95.gif" -Force
}

# Background image alignment
if ($Terminal.profiles.list[1].backgroundImageAlignment)
{
	$Terminal.profiles.list[1].backgroundImageAlignment = "bottomRight"
}
else
{
	$Terminal.profiles.list[1] | Add-Member -Name backgroundImageAlignment -MemberType NoteProperty -Value bottomRight -Force
}

# Background image opacity
$Value = 0.3
if ($Terminal.profiles.list[1].backgroundImageOpacity)
{
	$Terminal.profiles.list[1].backgroundImageOpacity = $Value
}
else
{
	$Terminal.profiles.list[1] | Add-Member -Name backgroundImageOpacity -MemberType NoteProperty -Value 0.3 -Force
}

# Background image stretch mode
if ($Terminal.profiles.list[1].backgroundImageStretchMode)
{
	$Terminal.profiles.list[1].backgroundImageStretchMode = "none"
}
else
{
	$Terminal.profiles.list[1] | Add-Member -Name backgroundImageStretchMode -MemberType NoteProperty -Value none -Force
}

# Starting directory
$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name Desktop
if ($Terminal.profiles.list[1].startingDirectory)
{
	$Terminal.profiles.list[1].startingDirectory = $DownloadsFolder
}
else
{
	$Terminal.profiles.list[1] | Add-Member -Name startingDirectory -MemberType NoteProperty -Value $DownloadsFolder -Force
}

# Use acrylic
if ($Terminal.profiles.list[1].useAcrylic)
{
	$Terminal.profiles.list[1].useAcrylic = $true
}
else
{
	$Terminal.profiles.list[1] | Add-Member -Name useAcrylic -MemberType NoteProperty -Value $true -Force
}

# Acrylic opacity
$Value = 0.75
if ($Terminal.profiles.list[1].acrylicOpacity)
{
	$Terminal.profiles.list[1].acrylicOpacity = $Value
}
else
{
	$Terminal.profiles.list[1] | Add-Member -Name acrylicOpacity -MemberType NoteProperty -Value 0.75 -Force
}
#endregion CMD

#region Azure
# Hide
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
	# Background image stretch mode
	if (($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"}).namet)
	{
		($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"}).name = "PowerShell 7"
	}
	else
	{
		$Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"} | Add-Member -MemberType NoteProperty -Name name -Value "PowerShell 7" -Force
	}

	# Background image stretch mode
	if (($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"}).backgroundImageAlignment)
	{
		($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"}).backgroundImageAlignment = "bottomRight"
	}
	else
	{
		$Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"} | Add-Member -MemberType NoteProperty -Name backgroundImageAlignment -Value bottomRight -Force
	}

	# Background image opacity
	$Value = 0.3
	if (($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"}).backgroundImageOpacity)
	{
		($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"}).backgroundImageOpacity = $Value
	}
	else
	{
		$Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"} | Add-Member -MemberType NoteProperty -Name backgroundImageOpacity -Value 0.3 -Force
	}

	# Background image stretch mode
	if (($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"}).backgroundImageStretchMode)
	{
		($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"}).backgroundImageStretchMode = "none"
	}
	else
	{
		$Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"} | Add-Member -MemberType NoteProperty -Name backgroundImageStretchMode -Value none -Force
	}

	# Starting directory
	$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name Desktop
	if (($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"}).startingDirectory)
	{
		($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"}).startingDirectory = $DownloadsFolder
	}
	else
	{
		$Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"} | Add-Member -MemberType NoteProperty -Name startingDirectory -Value $DownloadsFolder -Force
	}

	# Use acrylic
	if (($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"}).useAcrylic)
	{
		($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"}).useAcrylic = $true
	}
	else
	{
		$Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"} | Add-Member -MemberType NoteProperty -Name useAcrylic -Value $true -Force
	}

	# Acrylic opacity
	$Value = 0.75
	if (($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"}).acrylicOpacity)
	{
		($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"}).acrylicOpacity = $Value
	}
	else
	{
		$Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"} | Add-Member -MemberType NoteProperty -Name acrylicOpacity -Value 0.75 -Force
	}

	# Set Windows95.gif as a background image
	if (($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"}).backgroundImage)
	{
		($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"}).backgroundImage = "ms-appdata:///roaming/Windows95.gif"
	}
	else
	{
		$Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{574e775e-4f2a-5b96-ac1e-a2962a402336}"} | Add-Member -MemberType NoteProperty -Name backgroundImage -Value "ms-appdata:///roaming/Windows95.gif" -Force
	}
}

if (Test-Path -Path "$env:ProgramFiles\PowerShell\7-preview")
{
	# Background image stretch mode
	if (($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{a3a2e83a-884a-5379-baa8-16f193a13b21}"}).backgroundImageAlignment)
	{
		($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{a3a2e83a-884a-5379-baa8-16f193a13b21}"}).backgroundImageAlignment = "bottomRight"
	}
	else
	{
		$Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{a3a2e83a-884a-5379-baa8-16f193a13b21}"} | Add-Member -MemberType NoteProperty -Name backgroundImageAlignment -Value bottomRight -Force
	}

	# Background image opacity
	$Value = 0.3
	if (($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{a3a2e83a-884a-5379-baa8-16f193a13b21}"}).backgroundImageOpacity)
	{
		($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{a3a2e83a-884a-5379-baa8-16f193a13b21}"}).backgroundImageOpacity = $Value
	}
	else
	{
		$Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{a3a2e83a-884a-5379-baa8-16f193a13b21}"} | Add-Member -MemberType NoteProperty -Name backgroundImageOpacity -Value 0.3 -Force
	}

	# Background image stretch mode
	if (($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{a3a2e83a-884a-5379-baa8-16f193a13b21}"}).backgroundImageStretchMode)
	{
		($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{a3a2e83a-884a-5379-baa8-16f193a13b21}"}).backgroundImageStretchMode = "none"
	}
	else
	{
		$Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{a3a2e83a-884a-5379-baa8-16f193a13b21}"} | Add-Member -MemberType NoteProperty -Name backgroundImageStretchMode -Value none -Force
	}

	# Starting directory
	$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name Desktop
	if (($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{a3a2e83a-884a-5379-baa8-16f193a13b21}"}).startingDirectory)
	{
		($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{a3a2e83a-884a-5379-baa8-16f193a13b21}"}).startingDirectory = $DownloadsFolder
	}
	else
	{
		$Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{a3a2e83a-884a-5379-baa8-16f193a13b21}"} | Add-Member -MemberType NoteProperty -Name startingDirectory -Value $DownloadsFolder -Force
	}

	# Use acrylic
	if (($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{a3a2e83a-884a-5379-baa8-16f193a13b21}"}).useAcrylic)
	{
		($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{a3a2e83a-884a-5379-baa8-16f193a13b21}"}).useAcrylic = $true
	}
	else
	{
		$Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{a3a2e83a-884a-5379-baa8-16f193a13b21}"} | Add-Member -MemberType NoteProperty -Name useAcrylic -Value $true -Force
	}

	# Acrylic opacity
	$Value = 0.75
	if (($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{a3a2e83a-884a-5379-baa8-16f193a13b21}"}).acrylicOpacity)
	{
		($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{a3a2e83a-884a-5379-baa8-16f193a13b21}"}).acrylicOpacity = $Value
	}
	else
	{
		$Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{a3a2e83a-884a-5379-baa8-16f193a13b21}"} | Add-Member -MemberType NoteProperty -Name acrylicOpacity -Value 0.75 -Force
	}

	# Set Windows95.gif as a background image
	if (($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{a3a2e83a-884a-5379-baa8-16f193a13b21}"}).backgroundImage)
	{
		($Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{a3a2e83a-884a-5379-baa8-16f193a13b21}"}).backgroundImage = "ms-appdata:///roaming/Windows95.gif"
	}
	else
	{
		$Terminal.profiles.list | Where-Object -FilterScript {$_.guid -eq "{a3a2e83a-884a-5379-baa8-16f193a13b21}"} | Add-Member -MemberType NoteProperty -Name backgroundImage -Value "ms-appdata:///roaming/Windows95.gif" -Force
	}
}
#endregion Powershell Core

ConvertTo-Json -InputObject $Terminal -Depth 4 | Set-Content -Path $settings -Force
