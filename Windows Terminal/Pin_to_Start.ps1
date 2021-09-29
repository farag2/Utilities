<#
	Make Windows Terminal run as Administrator by default and pin it to Start
	Run the script after every Windows Terminal update

	Inspired by https://lennybacon.com/posts/create-an-link-to-a-uwp-app-to-run-as-administrator/
#>

Clear-Host

if (-not (Get-AppxPackage -Name Microsoft.WindowsTerminal))
{
	exit
}

Remove-Item -Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Windows Terminal*.lnk" -Force -ErrorAction Ignore

$PackageFullName = (Get-AppxPackage -Name Microsoft.WindowsTerminal).PackageFullName

# Create a Windows Terminal shortcut
$Shell = New-Object -ComObject Wscript.Shell
$Shortcut = $Shell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\Windows Terminal.lnk")
$Shortcut.TargetPath = "$env:LOCALAPPDATA\Microsoft\WindowsApps\Microsoft.WindowsTerminal_8wekyb3d8bbwe\wt.exe"
$ShortCut.IconLocation = "$env:ProgramFiles\WindowsApps\$PackageFullName\WindowsTerminal.exe"
$Shortcut.Save()

# Run the Windows Terminal shortcut as Administrator
[byte[]]$bytes = Get-Content -Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\Windows Terminal.lnk" -Encoding Byte -Raw
$bytes[0x15] = $bytes[0x15] -bor 0x20
Set-Content -Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\Windows Terminal.lnk" -Value $bytes -Encoding Byte -Force

Start-Sleep -Seconds 3

#region Variables
$Parameters = @{
	Size   = "2x2"
	Column = 2
	Row    = 0
	AppID  = $Shortcut.TargetPath
}

# Valid columns to place tiles in
$ValidColumns = @(0, 2, 4)
[string]$StartLayoutNS = "http://schemas.microsoft.com/Start/2014/StartLayout"

$StartLayout = "$PSScriptRoot\StartLayout.xml"
#endregion Variables

# Add pre-configured hastable to XML
function Add-Tile
{
	param
	(
		[string]
		$Size,

		[int]
		$Column,

		[int]
		$Row,

		[string]
		$AppID
	)

	[string]$elementName = "start:DesktopApplicationTile"
	[Xml.XmlElement]$Table = $xml.CreateElement($elementName, $StartLayoutNS)
	$Table.SetAttribute("Size", $Size)
	$Table.SetAttribute("Column", $Column)
	$Table.SetAttribute("Row", $Row)
	$Table.SetAttribute("DesktopApplicationID", $AppID)

	return $Table
}

# Export the current Start layout
Export-StartLayout -Path $StartLayout -UseDesktopApplicationID
[xml]$XML = Get-Content -Path $StartLayout -Encoding UTF8 -Force

# Create a new group
[Xml.XmlElement]$Groups = $XML.CreateElement("start:Group", $StartLayoutNS)
$Groups.SetAttribute("Name","")
$Groups.AppendChild((Add-Tile @Parameters)) | Out-Null
$XML.LayoutModificationTemplate.DefaultLayoutOverride.StartLayoutCollection.StartLayout.AppendChild($Groups) | Out-Null

$XML.Save($StartLayout)

# Temporarily disable changing the Start menu layout
if (-not (Test-Path -Path HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer))
{
	New-Item -Path HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer -Force
}
New-ItemProperty -Path HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer -Name LockedStartLayout -Value 1 -Force
New-ItemProperty -Path HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer -Name StartLayoutFile -Value $StartLayout -Force

Start-Sleep -Seconds 3

# Restart the Start menu
Stop-Process -Name StartMenuExperienceHost -Force -ErrorAction Ignore

# Open the Start menu to load the new layout
$wshell = New-Object -ComObject WScript.Shell
$wshell.SendKeys("^{ESC}")

Start-Sleep -Seconds 3

# Enable changing the Start menu layout
Remove-ItemProperty -Path HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer -Name LockedStartLayout -Force -ErrorAction Ignore
Remove-ItemProperty -Path HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer -Name StartLayoutFile -Force -ErrorAction Ignore

Remove-Item -Path $StartLayout -Force

Stop-Process -Name StartMenuExperienceHost -Force -ErrorAction Ignore

Start-Sleep -Seconds 3

# Open the Start menu to load the new layout
$wshell = New-Object -ComObject WScript.Shell
$wshell.SendKeys("^{ESC}")
