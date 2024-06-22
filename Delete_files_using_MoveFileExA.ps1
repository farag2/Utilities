# Delete files using MoveFileExA
# https://devblogs.microsoft.com/scripting/weekend-scripter-use-powershell-and-pinvoke-to-remove-stubborn-files/
$Signature = @{
	Namespace          = "WinAPI"
	Name               = "DeleteFiles"
	Language           = "CSharp"
	#CompilerParameters = $CompilerParameters
	MemberDefinition   = @"
public enum MoveFileFlags
{
	MOVEFILE_DELAY_UNTIL_REBOOT = 0x00000004
}
[DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
static extern bool MoveFileEx(string lpExistingFileName, string lpNewFileName, MoveFileFlags dwFlags);
public static bool MarkFileDelete (string sourcefile)
{
	return MoveFileEx(sourcefile, null, MoveFileFlags.MOVEFILE_DELAY_UNTIL_REBOOT);
}
"@
}

if (-not ("WinAPI.DeleteFiles" -as [type]))
{
	Add-Type @Signature
}

try
{
	Get-ChildItem -Path D:\Folder -Recurse -Force -ErrorAction Ignore | Remove-Item -Recurse -Force -ErrorAction Stop
}
catch
{
	# If files are in use remove them at the next boot
	Get-ChildItem -Path D:\Folder -Recurse -Force -ErrorAction Ignore | ForEach-Object -Process {[WinAPI.DeleteFiles]::MarkFileDelete($_.FullName)}
}
