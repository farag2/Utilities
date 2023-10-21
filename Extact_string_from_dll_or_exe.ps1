# Extract string from .dll or .exe knowing its' string number
# Expands a Microsoft @-prefixed indirect string
# https://github.com/SamuelArnold/StarKill3r/blob/master/Star Killer/Star Killer/bin/Debug/Scripts/SANS-SEC505-master/scripts/Day1-PowerShell/Expand-IndirectString.ps1

$Signature = @{
	Namespace        = "WinAPI"
	Name             = "IndirectStrings"
	Language         = "CSharp"
	UsingNamespace   = "System.Text"
	MemberDefinition = @"
[DllImport("shlwapi.dll", CharSet=CharSet.Unicode)]
private static extern int SHLoadIndirectString(string pszSource, StringBuilder pszOutBuf, int cchOutBuf, string ppvReserved);

public static string GetIndirectString(string indirectString)
{
	try
	{
		int returnValue;
		StringBuilder lptStr = new StringBuilder(1024);
		returnValue = SHLoadIndirectString(indirectString, lptStr, 1024, null);

		if (returnValue == 0)
		{
			return lptStr.ToString();
		}
		else
		{
			return null;
			// return "SHLoadIndirectString Failure: " + returnValue;
		}
	}
	catch // (Exception ex)
	{
		return null;
		// return "Exception Message: " + ex.Message;
	}
}
"@
}
if (-not ("WinAPI.IndirectStrings" -as [type]))
{
	Add-Type @Signature
}

[WinAPI.IndirectStrings]::GetIndirectString("@%SystemRoot%\system32\user32.dll,-702") 
