# https://www.deviantart.com/jepricreations/art/Windows-11-Cursors-Concept-v2-886489356
# Install cursor

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($Host.Version.Major -eq 5)
{
	# Progress bar can significantly impact cmdlet performance
	# https://github.com/PowerShell/PowerShell/issues/2138
	$Script:ProgressPreference = "SilentlyContinue"
}

$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$Parameters = @{
	Uri             = "https://github.com/farag2/Sophia-Script-for-Windows/raw/master/Misc/Cursors.zip"
	OutFile         = "$DownloadsFolder\Cursors.zip"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-WebRequest @Parameters

if (-not (Test-Path -Path "$env:SystemRoot\Cursors\W11_dark_v2.2"))
{
	New-Item -Path "$env:SystemRoot\Cursors\W11_dark_v2.2" -ItemType Directory -Force
}

Add-Type -Assembly System.IO.Compression.FileSystem
$ZIP = [IO.Compression.ZipFile]::OpenRead("$DownloadsFolder\Cursors.zip")
$ZIP.Entries | Where-Object -FilterScript {$_.FullName -like "dark/*.*"} | ForEach-Object -Process {
	[IO.Compression.ZipFileExtensions]::ExtractToFile($_, "$env:SystemRoot\Cursors\W11_dark_v2.2\$($_.Name)", $true)
}
$ZIP.Dispose()

Remove-Item -Path "$DownloadsFolder\Cursors.zip" -Force

New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name "(default)" -PropertyType String -Value "W11 Cursors Dark Free v2.2 by Jepri Creations" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name AppStarting -PropertyType ExpandString -Value "%SystemRoot%\Cursors\W11_dark_v2.2\working.ani" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name Arrow -PropertyType ExpandString -Value "%SystemRoot%\Cursors\W11_dark_v2.2\pointer.cur" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name ContactVisualization -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name Crosshair -PropertyType ExpandString -Value "%SystemRoot%\Cursors\W11_dark_v2.2\precision.cur" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name CursorBaseSize -PropertyType DWord -Value 32 -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name GestureVisualization -PropertyType DWord -Value 31 -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name Hand -PropertyType ExpandString -Value "%SystemRoot%\Cursors\W11_dark_v2.2\link.cur" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name Help -PropertyType ExpandString -Value "%SystemRoot%\Cursors\W11_dark_v2.2\help.cur" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name IBeam -PropertyType ExpandString -Value "%SystemRoot%\Cursors\W11_dark_v2.2\beam.cur" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name No -PropertyType ExpandString -Value "%SystemRoot%\Cursors\W11_dark_v2.2\unavailable.cur" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name NWPen -PropertyType ExpandString -Value "%SystemRoot%\Cursors\W11_dark_v2.2\handwriting.cur" -Force
# This is not a typo
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name Person -PropertyType ExpandString -Value "%SystemRoot%\Cursors\W11_dark_v2.2\pin.cur" -Force
# This is not a typo
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name Pin -PropertyType ExpandString -Value "%SystemRoot%\Cursors\W11_dark_v2.2\person.cur" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name precisionhair -PropertyType ExpandString -Value "%SystemRoot%\Cursors\W11_dark_v2.2\precision.cur" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name "Scheme Source" -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name SizeAll -PropertyType ExpandString -Value "%SystemRoot%\Cursors\W11_dark_v2.2\move.cur" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name SizeNESW -PropertyType ExpandString -Value "%SystemRoot%\Cursors\W11_dark_v2.2\dgn2.cur" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name SizeNS -PropertyType ExpandString -Value "%SystemRoot%\Cursors\W11_dark_v2.2\vert.cur" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name SizeNWSE -PropertyType ExpandString -Value "%SystemRoot%\Cursors\W11_dark_v2.2\dgn1.cur" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name SizeWE -PropertyType ExpandString -Value "%SystemRoot%\Cursors\W11_dark_v2.2\horz.cur" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name UpArrow -PropertyType ExpandString -Value "%SystemRoot%\Cursors\W11_dark_v2.2\alternate.cur" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name Wait -PropertyType ExpandString -Value "%SystemRoot%\Cursors\W11_dark_v2.2\busy.ani" -Force

if (-not (Test-Path -Path "HKCU:\Control Panel\Cursors\Schemes"))
{
	New-Item -Path "HKCU:\Control Panel\Cursors\Schemes" -Force
}
[string[]]$Schemes = (
	"%SystemRoot%\Cursors\W11_dark_v2.2\pointer.cur",
	"%SystemRoot%\Cursors\W11_dark_v2.2\help.cur",
	"%SystemRoot%\Cursors\W11_dark_v2.2\working.ani",
	"%SystemRoot%\Cursors\W11_dark_v2.2\busy.ani",
	"%SystemRoot%\Cursors\W11_dark_v2.2\precision.cur",
	"%SystemRoot%\Cursors\W11_dark_v2.2\beam.cur",
	"%SystemRoot%\Cursors\W11_dark_v2.2\handwriting.cur",
	"%SystemRoot%\Cursors\W11_dark_v2.2\unavailable.cur",
	"%SystemRoot%\Cursors\W11_dark_v2.2\vert.cur",
	"%SystemRoot%\Cursors\W11_dark_v2.2\horz.cur",
	"%SystemRoot%\Cursors\W11_dark_v2.2\dgn1.cur",
	"%SystemRoot%\Cursors\W11_dark_v2.2\dgn2.cur",
	"%SystemRoot%\Cursors\W11_dark_v2.2\move.cur",
	"%SystemRoot%\Cursors\W11_dark_v2.2\alternate.cur",
	"%SystemRoot%\Cursors\W11_dark_v2.2\link.cur",
	"%SystemRoot%\Cursors\W11_dark_v2.2\person.cur",
	"%SystemRoot%\Cursors\W11_dark_v2.2\pin.cur"
) -join ","
New-ItemProperty -Path "HKCU:\Control Panel\Cursors\Schemes" -Name "W11 Cursors Dark Free v2.2 by Jepri Creations" -PropertyType String -Value $Schemes -Force

# Reload cursor on-the-fly
$Signature = @{
	Namespace        = "WinAPI"
	Name             = "Cursor"
	Language         = "CSharp"
	MemberDefinition = @"
[DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, uint pvParam, uint fWinIni);
"@
}
if (-not ("WinAPI.Cursor" -as [type]))
{
	Add-Type @Signature
}
[WinAPI.Cursor]::SystemParametersInfo(0x0057, 0, $null, 0)

