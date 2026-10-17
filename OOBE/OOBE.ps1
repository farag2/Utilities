# enter Powershell and run
# iwr https://raw.githubusercontent.com/farag2/Utilities/refs/heads/master/OOBE/OOBE.ps1 -useb | iex
# https://schneegans.de/windows/unattend-generator/
$Parameters = @{
	Uri             = "https://raw.githubusercontent.com/farag2/Utilities/refs/heads/master/OOBE/OOBE.xml"
	OutFile         = "$env:TEMP\UnattendOOBE.xml"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-WebRequest @Parameters

& "$env:SystemRoot\System32\Sysprep\sysprep.exe" /reboot /oobe /unattend:"$env:TEMP\UnattendOOBE.xml"
