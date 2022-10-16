# https://www.deviantart.com/jepricreations/art/Windows-11-Cursors-Concept-v2-886489356
# Install cursor

$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$Parameters = @{
	Uri             = "https://github.com/farag2/Utilities/raw/master/Download/Cursor/dark.zip"
	OutFile         = "$DownloadsFolder\dark.zip"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-WebRequest @Parameters

if (-not (Test-Path -Path "$env:SystemRoot\Cursors\W11_dark_v2.2"))
{
	New-Item -Path "$env:SystemRoot\Cursors\W11_dark_v2.2" -ItemType Directory -Force
}

$Parameters = @{
	Path            = "$DownloadsFolder\dark.zip"
	DestinationPath = "$env:SystemRoot\Cursors\W11_dark_v2.2"
	Force           = $true
	Verbose         = $true
}
Expand-Archive @Parameters

Remove-Item -Path "$DownloadsFolder\dark.zip" -Force

New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name "(default)" -PropertyType String -Value "W11 Cursors Dark HD v2.2 by Jepri Creations" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name AppStarting -PropertyType ExpandString -Value "%SYSTEMROOT%\Cursors\W11_dark_v2.2\working.ani" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name Arrow -PropertyType ExpandString -Value "%SYSTEMROOT%\Cursors\W11_dark_v2.2\pointer.cur" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name ContactVisualization -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name Crosshair -PropertyType ExpandString -Value "%SYSTEMROOT%\Cursors\W11_dark_v2.2\precision.cur" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name CursorBaseSize -PropertyType DWord -Value 32 -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name GestureVisualization -PropertyType DWord -Value 31 -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name Hand -PropertyType ExpandString -Value "%SYSTEMROOT%\Cursors\W11_dark_v2.2\link.cur" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name Help -PropertyType ExpandString -Value "%SYSTEMROOT%\Cursors\W11_dark_v2.2\help.cur" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name IBeam -PropertyType ExpandString -Value "%SYSTEMROOT%\Cursors\W11_dark_v2.2\beam.cur" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name No -PropertyType ExpandString -Value "%SYSTEMROOT%\Cursors\W11_dark_v2.2\unavailable.cur" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name NWPen -PropertyType ExpandString -Value "%SYSTEMROOT%\Cursors\W11_dark_v2.2\handwriting.cur" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name Person -PropertyType ExpandString -Value "%SYSTEMROOT%\Cursors\W11_dark_v2.2\pin.cur" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name Pin -PropertyType ExpandString -Value "%SYSTEMROOT%\Cursors\W11_dark_v2.2\person.cur" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name precisionhair -PropertyType ExpandString -Value "%SYSTEMROOT%\Cursors\W11_dark_v2.2\precision.cur" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name "Scheme Source" -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name SizeAll -PropertyType ExpandString -Value "%SYSTEMROOT%\Cursors\W11_dark_v2.2\move.cur" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name SizeNESW -PropertyType ExpandString -Value "%SYSTEMROOT%\Cursors\W11_dark_v2.2\dgn2.cur" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name SizeNS -PropertyType ExpandString -Value "%SYSTEMROOT%\Cursors\W11_dark_v2.2\vert.cur" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name SizeNWSE -PropertyType ExpandString -Value "%SYSTEMROOT%\Cursors\W11_dark_v2.2\dgn1.cur" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name SizeWE -PropertyType ExpandString -Value "%SYSTEMROOT%\Cursors\W11_dark_v2.2\horz.cur" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name UpArrow -PropertyType ExpandString -Value "%SYSTEMROOT%\Cursors\W11_dark_v2.2\alternate.cur" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name Wait -PropertyType ExpandString -Value "%SYSTEMROOT%\Cursors\W11_dark_v2.2\busy.ani" -Force
if (-not (Test-Path -Path "HKCU:\Control Panel\Cursors\Schemes"))
{
	New-Item -Path "HKCU:\Control Panel\Cursors\Schemes" -Force
}
New-ItemProperty -Path "HKCU:\Control Panel\Cursors\Schemes" -Name "W11 Cursors Dark HD v2.2 by Jepri Creations" -PropertyType ExpandString -Value "%SYSTEMROOT%\Cursors\W11_dark_v2.2\pointer.cur,%SYSTEMROOT%\Cursors\W11_dark_v2.2\help.cur,%SYSTEMROOT%\Cursors\W11_dark_v2.2\working.ani,%SYSTEMROOT%\Cursors\W11_dark_v2.2\busy.ani,%SYSTEMROOT%\Cursors\W11_dark_v2.2\precision.cur,%SYSTEMROOT%\Cursors\W11_dark_v2.2\beam.cur,%SYSTEMROOT%\Cursors\W11_dark_v2.2\handwriting.cur,%SYSTEMROOT%\Cursors\W11_dark_v2.2\unavailable.cur,%SYSTEMROOT%\Cursors\W11_dark_v2.2\vert.cur,%SYSTEMROOT%\Cursors\W11_dark_v2.2\horz.cur,%SYSTEMROOT%\Cursors\W11_dark_v2.2\dgn1.cur,%SYSTEMROOT%\Cursors\W11_dark_v2.2\dgn2.cur,%SYSTEMROOT%\Cursors\W11_dark_v2.2\move.cur,%SYSTEMROOT%\Cursors\W11_dark_v2.2\alternate.cur,%SYSTEMROOT%\Cursors\W11_dark_v2.2\link.cur,%SYSTEMROOT%\Cursors\W11_dark_v2.2\person.cur,%SYSTEMROOT%\Cursors\W11_dark_v2.2\pin.cur" -Force

# Reload cursor on-the-fly
$Signature = @{
	Namespace        = "WinAPI"
	Name             = "SystemParamInfo"
	Language         = "CSharp"
	MemberDefinition = @"
[DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, uint pvParam, uint fWinIni);
"@
}
if (-not ("WinAPI.SystemParamInfo" -as [type]))
{
	Add-Type @Signature
}
[WinAPI.SystemParamInfo]::SystemParametersInfo(0x0057, 0, $null, 0)
