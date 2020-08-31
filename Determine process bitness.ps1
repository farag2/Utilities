# https://rkeithhill.wordpress.com/2014/04/28/how-to-determine-if-a-process-is-32-or-64-bit/

$Signature = @{
	Namespace = "Kernel32"
	Name = "Bitness"
	Language = "CSharp"
	MemberDefinition = @"
[DllImport("kernel32.dll", SetLastError = true, CallingConvention = CallingConvention.Winapi)]
[return: MarshalAs(UnmanagedType.Bool)]
public static extern bool IsWow64Process(
	[In] System.IntPtr hProcess,
	[Out, MarshalAs(UnmanagedType.Bool)] out bool wow64Process);
"@
}
if (-not ("Kernel32.Bitness" -as [type]))
{
	Add-Type @Signature
}

Get-Process -Id (Get-Process -Name Process).id | ForEach-Object -Process {
	$is32Bit = [int]0
	if ([Kernel32.Bitness]::IsWow64Process($_.Handle, [ref]$is32Bit))
	{
		if ($is32Bit)
		{
			"$($_.Name) is 32-bit"
		}
		else
		{
			"$($_.Name) is 64-bit"
		}
	}
}
