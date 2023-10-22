# https://github.com/farag2/Sophia-Script-for-Windows/blob/master/src/Sophia_Script_for_Windows_11/Module/Sophia.psm1
$Parameters = @{
	Uri             = "https://raw.githubusercontent.com/farag2/Sophia-Script-for-Windows/master/src/Sophia_Script_for_Windows_11/Module/Sophia.psm1"
	Outfile         = "$env:TEMP\Sophia.ps1"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-WebRequest @Parameters

# Change the line endings from UNIX LF to Windows (CR LF) for downloaded file to be able to dot-source it
# https://en.wikipedia.org/wiki/Newline#Representation
(Get-Content -Path "$env:TEMP\Sophia.ps1" -Force) | Set-Content -Path "$env:TEMP\Sophia.ps1" -Encoding UTF8 -Force

# Dot source the Sophia module to make the function available in the current session
. "$env:TEMP\Sophia.ps1"

# Register Notepad++, calculate hash, and associate with an extension with the "How do you want to open this" pop-up hidden
$Extensions = @(
	".cfg", ".ini", ".log",
	".nfo", ".ps1", ".psm1",
	".psd1", ".xml", ".yml",
	".md", ".txt"
)
foreach ($Extension in $Extensions)
{
	Set-Association -ProgramPath "%ProgramFiles%\Notepad++\notepad++.exe" -Extension $Extension -Icon "%ProgramFiles%\Notepad++\notepad++.exe,0"
}

Remove-Item -Path "$env:TEMP\Sophia.ps1" -Force
