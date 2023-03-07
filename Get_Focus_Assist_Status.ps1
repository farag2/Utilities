# Get Focus Assist Status via PowerShell
# https://redplait.blogspot.com/2018/07/wnf-ids-from-perfntcdll-adk-version.html
# https://github.com/DCourtel/Windows_10_Focus_Assist/blob/master/FocusAssistLibrary/FocusAssistLib.cs

$Focus = @{
	Namespace        = "WinAPI"
	Name             = "Focus"
	Language         = "CSharp"
	MemberDefinition = @"
[DllImport("NtDll.dll", SetLastError = true)]
private static extern uint NtQueryWnfStateData(IntPtr pStateName, IntPtr pTypeId, IntPtr pExplicitScope, out uint nChangeStamp, out IntPtr pBuffer, ref uint nBufferSize);

[StructLayout(LayoutKind.Sequential)]
public struct WNF_TYPE_ID
{
	public Guid TypeId;
}

[StructLayout(LayoutKind.Sequential)]
public struct WNF_STATE_NAME
{
	[MarshalAs(UnmanagedType.ByValArray, SizeConst = 2)]
	public uint[] Data;

	public WNF_STATE_NAME(uint Data1, uint Data2) : this()
	{
		uint[] newData = new uint[2];
		newData[0] = Data1;
		newData[1] = Data2;
		Data = newData;
	}
}

public enum FocusAssistState
{
	NOT_SUPPORTED = -2,
	FAILED = -1,
	OFF = 0,
	PRIORITY_ONLY = 1,
	ALARMS_ONLY = 2
};

// Returns the state of Focus Assist if available on this computer
public static FocusAssistState GetFocusAssistState()
{
	try
	{
		WNF_STATE_NAME WNF_SHEL_QUIETHOURS_ACTIVE_PROFILE_CHANGED = new WNF_STATE_NAME(0xA3BF1C75, 0xD83063E);
		uint nBufferSize = (uint)Marshal.SizeOf(typeof(IntPtr));
		IntPtr pStateName = Marshal.AllocHGlobal(Marshal.SizeOf(typeof(WNF_STATE_NAME)));
		Marshal.StructureToPtr(WNF_SHEL_QUIETHOURS_ACTIVE_PROFILE_CHANGED, pStateName, false);

		uint nChangeStamp = 0;
		IntPtr pBuffer = IntPtr.Zero;
		bool success = NtQueryWnfStateData(pStateName, IntPtr.Zero, IntPtr.Zero, out nChangeStamp, out pBuffer, ref nBufferSize) == 0;
		Marshal.FreeHGlobal(pStateName);

		if (success)
		{
			return (FocusAssistState)pBuffer;
		}
	}
	catch { }

	return FocusAssistState.FAILED;
}
"@
}

if (-not ("WinAPI.Focus" -as [type]))
{
	Add-Type @Focus
}
[WinAPI.Focus]::GetFocusAssistState()
