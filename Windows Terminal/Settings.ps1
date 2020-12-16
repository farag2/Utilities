# https://docs.microsoft.com/en-us/windows/terminal/
# https://github.com/microsoft/terminal/issues/1555#issuecomment-505157311

# Remove the old PSReadLine 2.0.0
if ((Get-Module -Name PSReadline).Version -eq "2.0.0")
{
	$PSReadLine = @{
		ModuleName = "PSReadLine"
		ModuleVersion = "2.0.0"
	}
	Remove-Module -FullyQualifiedName $PSReadLine -Force
	Get-InstalledModule -Name PSReadline -AllVersions | Where-Object -FilterScript {$_.Version -eq "2.0.0"} | Uninstall-Module -Force
	Remove-Item -Path $env:ProgramFiles\WindowsPowerShell\Modules\PSReadline\2.0.0 -Recurse -Force -ErrorAction Ignore
}

# Intall PSReadLine 2.1.0
# https://github.com/PowerShell/PSReadLine/releases
if (-not (Get-Package -Name NuGet -Force -ErrorAction Ignore))
{
	Install-Package -Name NuGet -Force
}
if ((Get-Module -Name PSReadline).Version -ge "2.1.0")
{
	Install-Module -Name PSReadLine -RequiredVersion 2.1.0 -Force
}

# Download Windows95.gif
# https://github.com/farag2/Utilities/tree/master/Windows%20Terminal
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Parameters = @{
	Uri = "https://github.com/farag2/Utilities/raw/master/Windows%20Terminal/Windows95.gif"
	OutFile = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\RoamingState\Windows95.gif"
	Verbose = [switch]::Present
}
Invoke-WebRequest @Parameters

$JsonPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

# Remove all comments to parse JSON file
if (Get-Content -Path $JsonPath | Select-String -Pattern "//" -SimpleMatch)
{
	Set-Content -Path $JsonPath -Value (Get-Content -Path $JsonPath | Select-String -Pattern "//" -NotMatch) -Force
}

# Delete all blank lines from JSON file
(Get-Content -Path $JsonPath) | Where-Object -FilterScript {$_.Trim(" `t")} | Set-Content -Path $JsonPath -Force

try
{
	$Terminal = Get-Content -Path $JsonPath | ConvertFrom-Json
}
catch [System.Exception]
{
	Write-Verbose "JSON is not valid!" -Verbose
	break
}

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
	$Terminal | Add-Member -MemberType NoteProperty -Name confirmCloseAllTabs -Value $false -Force
}

# Show tabs in title bar
if ($Terminal.showTabsInTitlebar)
{
	$Terminal.showTabsInTitlebar = $false
}
else
{
	$Terminal | Add-Member -MemberType NoteProperty -Name showTabsInTitlebar -Value $false -Force
}

# The PowerShell profile settings
# Set Windows95.gif as a background image
if ($Terminal.profiles.list[0].backgroundImage)
{
	$Terminal.profiles.list[0].backgroundImage = "ms-appdata:///roaming/Windows95.gif"
}
else
{
	$Terminal.profiles.list[0] | Add-Member -MemberType NoteProperty -Name backgroundImage -Value "ms-appdata:///roaming/Windows95.gif" -Force
}

# Background image alignment
if ($Terminal.profiles.list[0].backgroundImageAlignment)
{
	$Terminal.profiles.list[0].backgroundImageAlignment = "bottomRight"
}
else
{
	$Terminal.profiles.list[0] | Add-Member -MemberType NoteProperty -Name backgroundImageAlignment -Value bottomRight -Force
}

# Background image opacity
$Value = 0.3
if ($Terminal.profiles.list[0].backgroundImageOpacity)
{
	$Terminal.profiles.list[0].backgroundImageOpacity = $Value
}
else
{
	$Terminal.profiles.list[0] | Add-Member -MemberType NoteProperty -Name backgroundImageOpacity -Value 0.3 -Force
}

# Background image stretch mode
if ($Terminal.profiles.list[0].backgroundImageStretchMode)
{
	$Terminal.profiles.list[0].backgroundImageStretchMode = "none"
}
else
{
	$Terminal.profiles.list[0] | Add-Member -MemberType NoteProperty -Name backgroundImageStretchMode -Value none -Force
}

# Starting directory
$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name Desktop
if ($Terminal.profiles.list[0].startingDirectory)
{
	$Terminal.profiles.list[0].startingDirectory = $DownloadsFolder
}
else
{
	$Terminal.profiles.list[0] | Add-Member -MemberType NoteProperty -Name startingDirectory -Value $DownloadsFolder -Force
}

# Use acrylic
if ($Terminal.profiles.list[0].useAcrylic)
{
	$Terminal.profiles.list[0].useAcrylic = $true
}
else
{
	$Terminal.profiles.list[0] | Add-Member -MemberType NoteProperty -Name useAcrylic -Value $true -Force
}

# Acrylic opacity
$Value = 0.75
if ($Terminal.profiles.list[0].acrylicOpacity)
{
	$Terminal.profiles.list[0].acrylicOpacity = $Value
}
else
{
	$Terminal.profiles.list[0] | Add-Member -MemberType NoteProperty -Name acrylicOpacity -Value 0.75 -Force
}

# The CMD profile settings
# Set Windows95.gif as a background image
if ($Terminal.profiles.list[1].backgroundImage)
{
	$Terminal.profiles.list[1].backgroundImage = "ms-appdata:///roaming/Windows95.gif"
}
else
{
	$Terminal.profiles.list[1] | Add-Member -MemberType NoteProperty -Name backgroundImage -Value "ms-appdata:///roaming/Windows95.gif" -Force
}

# Background image alignment
if ($Terminal.profiles.list[1].backgroundImageAlignment)
{
	$Terminal.profiles.list[1].backgroundImageAlignment = "bottomRight"
}
else
{
	$Terminal.profiles.list[1] | Add-Member -MemberType NoteProperty -Name backgroundImageAlignment -Value bottomRight -Force
}

# Background image opacity
$Value = 0.3
if ($Terminal.profiles.list[1].backgroundImageOpacity)
{
	$Terminal.profiles.list[1].backgroundImageOpacity = $Value
}
else
{
	$Terminal.profiles.list[1] | Add-Member -MemberType NoteProperty -Name backgroundImageOpacity -Value 0.3 -Force
}

# Background image stretch mode
if ($Terminal.profiles.list[1].backgroundImageStretchMode)
{
	$Terminal.profiles.list[1].backgroundImageStretchMode = "none"
}
else
{
	$Terminal.profiles.list[1] | Add-Member -MemberType NoteProperty -Name backgroundImageStretchMode -Value none -Force
}

# Starting directory
$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name Desktop
if ($Terminal.profiles.list[1].startingDirectory)
{
	$Terminal.profiles.list[1].startingDirectory = $DownloadsFolder
}
else
{
	$Terminal.profiles.list[1] | Add-Member -MemberType NoteProperty -Name startingDirectory -Value $DownloadsFolder -Force
}

# Use acrylic
if ($Terminal.profiles.list[1].useAcrylic)
{
	$Terminal.profiles.list[1].useAcrylic = $true
}
else
{
	$Terminal.profiles.list[1] | Add-Member -MemberType NoteProperty -Name useAcrylic -Value $true -Force
}

# Acrylic opacity
$Value = 0.75
if ($Terminal.profiles.list[1].acrylicOpacity)
{
	$Terminal.profiles.list[1].acrylicOpacity = $Value
}
else
{
	$Terminal.profiles.list[1] | Add-Member -MemberType NoteProperty -Name acrylicOpacity -Value 0.75 -Force
}

# Hide Azure Cloud Shell profile
if ($Terminal.profiles.list[2].hidden)
{
	$Terminal.profiles.list[2].hidden = $true
}
else
{
	$Terminal.profiles.list[2] | Add-Member -MemberType NoteProperty -Name hidden -Value $true -Force
}

ConvertTo-Json -InputObject $Terminal -Depth 4 | Set-Content -Path $JsonPath -Force
