# Associate the following extensions with Notepad++ without generating a hash (as an example)
# Use the "Set-Association" function from https://github.com/farag2/Windows-10-Sophia-Script to
# register app, calculate hash, and associate with an extension with the "How do you want to open this" pop-up hidden

# Get the associations table
# https://www.pstips.net/assoc-ftype.html
<#
$ftypeMap = @{}
& cmd.exe /c ftype | ForEach-Object -Process {
	$FileType, $Executable = $_.split("=")
	$ftypeMap.Add($FileType,$Executable)
}

& cmd.exe /c assoc | ForEach-Object -Process {
	$Extension, $FileType = $_.split("=")
	[PSCustomObject]@{
		Extension  = $Extension
		FileType   = $FileType
		Executable = $ftypeMap[$FileType]
	}
}
#>

$Extensions = @(
	".cfg",
	".ini",
	".json",
	".log",
	".nfo",
	".txt",
	".xml"
)
foreach ($Extension in $Extensions)
{
	$FileType = $Extension.Split(".")[1] + "file"
	& cmd.exe /c assoc $Extension=$FileType
	& cmd.exe /c assoc $FileType\DefaultIcon=%ProgramFiles%\Notepad++\notepad++.exe,0
	& cmd.exe /c ftype $FileType="%ProgramFiles%\Notepad++\notepad++.exe" "%1"
}

# The following extensions cannot be associated within the same method like the previous ones
$Extensions = @{
	".ps1"  = "Microsoft.PowerShellScript.1"
	".psd1" = "Microsoft.PowerShellData.1"
	".psm1" = "Microsoft.PowerShellModule.1"
}
foreach ($Extension in $Extensions.Keys)
{
	$FileType = $Extensions[$Extension]
	& cmd.exe /c assoc $Extensions.Keys=$FileType
	& cmd.exe /c "assoc $FileType\DefaultIcon=%ProgramFiles%\Notepad++\notepad++.exe,0"
	& cmd.exe /c "ftype $FileType=`"%ProgramFiles%\Notepad++\notepad++.exe`" `"%1`""
}

# Rebuild icon cache. For Windows 10 only
& cmd.exe /c ie4uinit.exe -show
