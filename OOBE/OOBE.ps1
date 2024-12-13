# powershell -c "iwr https://raw.githubusercontent.com/farag2/Utilities/refs/heads/master/OOBE/OOBE.ps1 | iex"
# https://schneegans.de/windows/unattend-generator/
$Signature = @{
	Namespace          = "WinAPI"
	Name               = "OOBE"
	Language           = "CSharp"
	MemberDefinition   = @"
[DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
public static extern int OOBEComplete(ref int bIsOOBEComplete);
"@
}
if (-not ("WinAPI.OOBE" -as [type]))
{
	Add-Type @Signature
}

$IsOOBEComplete = $false
[WinAPI.OOBE]::OOBEComplete([ref]$IsOOBEComplete)

if ($IsOOBEComplete) 
{
	Write-Warning -Message "Please run script in OOBE."
	exit
}

$Parameters = @{
	Uri             = "https://pastebin.com/raw/r2fwLARM"
	OutFile         = "$env:TEMP\UnattendOOBE.xml"
	Verbose         = $true
	UseBasicParsing = $true
}
Invoke-RestMethod @Parameters

foreach ($Letter in (Get-Volume).DriveLetter)
{
	if (Test-Path -Path "$($Letter):\Windows\System32\Sysprep\sysprep.exe")
	{
		& "$($Letter):\Windows\System32\Sysprep\sysprep.exe" /reboot /oobe /unattend:"$env:TEMP\UnattendOOBE.xml"
		break
	}
}
