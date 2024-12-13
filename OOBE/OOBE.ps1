# powershell -c "iwr https://raw.githubusercontent.com/farag2/Utilities/refs/heads/master/OOBE/OOBE.ps1 -useb | iex"
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

try
{
	$Parameters = @{
		Uri             = "https://raw.githubusercontent.com/farag2/Utilities/refs/heads/master/OOBE/OOBE.xml"
		OutFile         = "$env:TEMP\UnattendOOBE.xml"
		Verbose         = $true
		UseBasicParsing = $true
	}
	Invoke-RestMethod @Parameters
}
catch [System.Net.WebException]
{
	Write-Warning -Message "Cannot establish Internet connection."
	exit
}

foreach ($Letter in (Get-Volume).DriveLetter)
{
	if (Test-Path -Path "$($Letter):\Windows\System32\Sysprep\sysprep.exe")
	{
		& "$($Letter):\Windows\System32\Sysprep\sysprep.exe" /reboot /oobe /unattend:"$env:TEMP\UnattendOOBE.xml"
		break
	}
}
