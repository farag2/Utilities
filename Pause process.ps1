# https://github.com/besimorhino/Pause-Process

$Signature = @{
	Namespace = "WinAPI"
	Name = "Kernel"
	Language = "CSharp"
	MemberDefinition = @"
		[DllImport("kernel32.dll")]
		public static extern bool CheckRemoteDebuggerPresent(IntPtr hProcess, out bool pbDebuggerPresent);

		[DllImport("kernel32.dll")]
		public static extern int DebugActiveProcess(int PID);

		[DllImport("kernel32.dll")]
		public static extern int DebugActiveProcessStop(int PID);
"@
}
if (-not ("WinAPI.Kernel" -as [type]))
{
	Add-Type @Signature
}

function Pause-Process
{
	[CmdletBinding()]
	param
	(
		[Parameter(
			Mandatory = $true,
			ValueFromPipelineByPropertyName = $true
		)]
		[int]
		$ID
	)

	$ProcHandle = (Get-Process -Id $ID).Handle
	$DebuggerPresent = [IntPtr]::Zero
	$CallResult = [WinAPI.Kernel]::CheckRemoteDebuggerPresent($ProcHandle,[ref]$DebuggerPresent)

	$PauseResult = [WinAPI.Kernel]::DebugActiveProcess($ID)
}
Pause-Process -ID (Get-Process -Name notepad).Id
# Get-Process -Name notepad | UnPause-Process

function UnPause-Process
{
	[CmdletBinding()]
	param
	(
		[Parameter(
			Mandatory = $true,
			ValueFromPipelineByPropertyName = $true
		)]
		[int]
		$ID
	)

	$UnPauseResult = [WinAPI.Kernel]::DebugActiveProcessStop($ID)
}
UnPause-Process -ID (Get-Process -Name notepad).Id
# Get-Process -Name notepad | Pause-Process