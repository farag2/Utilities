# https://docs.microsoft.com/en-us/windows/terminal/
# https://github.com/microsoft/terminal/issues/1555#issuecomment-505157311

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$param = @{
	Uri = "https://github.com/farag2/Utilities/raw/master/Windows%20Terminal/Windows95.gif"
	OutFile = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\RoamingState\Windows95.gif"
	Verbose = [switch]::Present
}
Invoke-WebRequest @param

$JsonPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\profiles.json"

# Remove all comments to parse JSON file
# Удалить все комментарии, чтобы пропарсить JSON-файл
if (Get-Content -Path $JsonPath | Select-String -Pattern "//" -SimpleMatch)
{
	Set-Content -Path $JsonPath -Value (Get-Content -Path $JsonPath | Select-String -Pattern "//" -NotMatch)
}

# Delete all blank lines from JSON file
# Удалить все пустые строки в JSON-файле
(Get-Content -Path $JsonPath) | Where-Object -FilterScript {$_.Trim(" `t")} | Set-Content -Path $JsonPath

$Terminal = Get-Content -Path $JsonPath | ConvertFrom-Json

if (-not ($Terminal.keybindings | Where-Object -FilterScript {$_.command -eq "closeTab"} | Where-Object -FilterScript {$_.keys -eq "ctrl+w"}))
{
	$closeTab = [PSCustomObject]@{
		"command" = "closeTab"
		"keys" = "ctrl+w"
	}
	$Terminal.keybindings += $closeTab
}

if (-not ($Terminal.keybindings | Where-Object -FilterScript {$_.command -eq "newTab"} | Where-Object -FilterScript {$_.keys -eq "ctrl+t"}))
{
	$newTab = [PSCustomObject]@{
		"command" = "newTab"
		"keys" = "ctrl+t"
	}
	$Terminal.keybindings += $newTab
}

if (-not ($Terminal.keybindings | Where-Object -FilterScript {$_.command -eq "find"} | Where-Object -FilterScript {$_.keys -eq "ctrl+f"}))
{
	$find = [PSCustomObject]@{
		"command" = "find"
		"keys" = "ctrl+f"
	}
	$Terminal.keybindings += $find
}

if (-not ($Terminal.keybindings | Where-Object -FilterScript {$_.command.action -eq "splitPane"} | Where-Object -FilterScript {$_.command.split -eq "auto"} | Where-Object -FilterScript {$_.command.splitMode -eq "duplicate"}))
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
	$Terminal.keybindings += $splitPane
}

if ($Terminal.confirmCloseAllTabs)
{
	$Terminal.confirmCloseAllTabs = $false
}
else
{
	$Terminal | Add-Member -MemberType NoteProperty -Name confirmCloseAllTabs -Value $false -Force
}

if ($Terminal.showTabsInTitlebar)
{
	$Terminal.showTabsInTitlebar = $false
}
else
{
	$Terminal | Add-Member -MemberType NoteProperty -Name showTabsInTitlebar -Value $false -Force
}

# PowerShell
if ($Terminal.profiles.list[0].backgroundImage)
{
	$Terminal.profiles.list[0].backgroundImage = "ms-appdata:///roaming/Windows95.gif"
}
else
{
	$Terminal.profiles.list[0] | Add-Member -MemberType NoteProperty -Name backgroundImage -Value "ms-appdata:///roaming/Windows95.gif" -Force
}

if ($Terminal.profiles.list[0].backgroundImageAlignment)
{
	$Terminal.profiles.list[0].backgroundImageAlignment = "bottomRight"
}
else
{
	$Terminal.profiles.list[0] | Add-Member -MemberType NoteProperty -Name backgroundImageAlignment -Value bottomRight -Force
}

$Value = 0.3
if ($Terminal.profiles.list[0].backgroundImageOpacity)
{
	$Terminal.profiles.list[0].backgroundImageOpacity = $Value
}
else
{
	$Terminal.profiles.list[0] | Add-Member -MemberType NoteProperty -Name backgroundImageOpacity -Value 0.3 -Force
}

if ($Terminal.profiles.list[0].backgroundImageStretchMode)
{
	$Terminal.profiles.list[0].backgroundImageStretchMode = "none"
}
else
{
	$Terminal.profiles.list[0] | Add-Member -MemberType NoteProperty -Name backgroundImageStretchMode -Value none -Force
}

$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name Desktop
if ($Terminal.profiles.list[0].startingDirectory)
{
	$Terminal.profiles.list[0].startingDirectory = $DownloadsFolder
}
else
{
	$Terminal.profiles.list[0] | Add-Member -MemberType NoteProperty -Name startingDirectory -Value $DownloadsFolder -Force
}

if ($Terminal.profiles.list[0].useAcrylic)
{
	$Terminal.profiles.list[0].useAcrylic = $true
}
else
{
	$Terminal.profiles.list[0] | Add-Member -MemberType NoteProperty -Name useAcrylic -Value $true -Force
}

$Value = 0.75
if ($Terminal.profiles.list[0].acrylicOpacity)
{
	$Terminal.profiles.list[0].acrylicOpacity = $Value
}
else
{
	$Terminal.profiles.list[0] | Add-Member -MemberType NoteProperty -Name acrylicOpacity -Value 0.75 -Force
}

# cmd
if ($Terminal.profiles.list[1].backgroundImage)
{
	$Terminal.profiles.list[1].backgroundImage = "ms-appdata:///roaming/Windows95.gif"
}
else
{
	$Terminal.profiles.list[1] | Add-Member -MemberType NoteProperty -Name backgroundImage -Value "ms-appdata:///roaming/Windows95.gif" -Force
}

if ($Terminal.profiles.list[1].backgroundImageAlignment)
{
	$Terminal.profiles.list[1].backgroundImageAlignment = "bottomRight"
}
else
{
	$Terminal.profiles.list[1] | Add-Member -MemberType NoteProperty -Name backgroundImageAlignment -Value bottomRight -Force
}

$Value = 0.3
if ($Terminal.profiles.list[1].backgroundImageOpacity)
{
	$Terminal.profiles.list[1].backgroundImageOpacity = $Value
}
else
{
	$Terminal.profiles.list[1] | Add-Member -MemberType NoteProperty -Name backgroundImageOpacity -Value 0.3 -Force
}

if ($Terminal.profiles.list[1].backgroundImageStretchMode)
{
	$Terminal.profiles.list[1].backgroundImageStretchMode = "none"
}
else
{
	$Terminal.profiles.list[1] | Add-Member -MemberType NoteProperty -Name backgroundImageStretchMode -Value none -Force
}

$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name Desktop
if ($Terminal.profiles.list[1].startingDirectory)
{
	$Terminal.profiles.list[1].startingDirectory = $DownloadsFolder
}
else
{
	$Terminal.profiles.list[1] | Add-Member -MemberType NoteProperty -Name startingDirectory -Value $DownloadsFolder -Force
}

if ($Terminal.profiles.list[1].useAcrylic)
{
	$Terminal.profiles.list[1].useAcrylic = $true
}
else
{
	$Terminal.profiles.list[1] | Add-Member -MemberType NoteProperty -Name useAcrylic -Value $true -Force
}

$Value = 0.75
if ($Terminal.profiles.list[1].acrylicOpacity)
{
	$Terminal.profiles.list[1].acrylicOpacity = $Value
}
else
{
	$Terminal.profiles.list[1] | Add-Member -MemberType NoteProperty -Name acrylicOpacity -Value 0.75 -Force
}

if ($Terminal.profiles.list[2].hidden)
{
	$Terminal.profiles.list[2].hidden = $true
}
else
{
	$Terminal.profiles.list[2] | Add-Member -MemberType NoteProperty -Name hidden -Value $true -Force
}

ConvertTo-Json -InputObject $Terminal -Depth 4 | Set-Content -Path $JsonPath -Force