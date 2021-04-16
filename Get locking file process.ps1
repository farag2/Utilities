# https://github.com/pldmgg/misc-powershell/blob/master/MyFunctions/PowerShellCore_Compatible/Get-FileLockProcess.ps1
function Get-FileLockProcess
{
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory = $true)]
		[string[]]
		$FilePath
	)
	$AssembliesFullInfo = [System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object {
		$_.GetName().Name -eq "Microsoft.CSharp" -or
		$_.GetName().Name -eq "mscorlib" -or
		$_.GetName().Name -eq "System" -or
		$_.GetName().Name -eq "System.Collections" -or
		$_.GetName().Name -eq "System.Core" -or
		$_.GetName().Name -eq "System.IO" -or
		$_.GetName().Name -eq "System.Linq" -or
		$_.GetName().Name -eq "System.Runtime" -or
		$_.GetName().Name -eq "System.Runtime.Extensions" -or
		$_.GetName().Name -eq "System.Runtime.InteropServices"
	} | Where-Object {$_.IsDynamic -eq $False}
	$ReferencedAssemblies = $AssembliesFullInfo.FullName | Sort-Object | Get-Unique
	$TypeDefinition = @"
		using Microsoft.CSharp;
		using System.Collections.Generic;
		using System.Collections;
		using System.IO;
		using System.Linq;
		using System.Runtime.InteropServices;
		using System.Runtime;
		using System;
		using System.Diagnostics;
		namespace MyCore.Utils
		{
			static public class FileLockUtil
			{
				[StructLayout(LayoutKind.Sequential)]
				struct RM_UNIQUE_PROCESS
				{
					public int dwProcessId;
					public System.Runtime.InteropServices.ComTypes.FILETIME ProcessStartTime;
				}
				const int RmRebootReasonNone = 0;
				const int CCH_RM_MAX_APP_NAME = 255;
				const int CCH_RM_MAX_SVC_NAME = 63;
				enum RM_APP_TYPE
				{
					RmUnknownApp = 0,
					RmMainWindow = 1,
					RmOtherWindow = 2,
					RmService = 3,
					RmExplorer = 4,
					RmConsole = 5,
					RmCritical = 1000
				}
				[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
				struct RM_PROCESS_INFO
				{
					public RM_UNIQUE_PROCESS Process;
					[MarshalAs(UnmanagedType.ByValTStr, SizeConst = CCH_RM_MAX_APP_NAME + 1)]
					public string strAppName;
					[MarshalAs(UnmanagedType.ByValTStr, SizeConst = CCH_RM_MAX_SVC_NAME + 1)]
					public string strServiceShortName;
					public RM_APP_TYPE ApplicationType;
					public uint AppStatus;
					public uint TSSessionId;
					[MarshalAs(UnmanagedType.Bool)]
					 public bool bRestartable;
				}
				[DllImport("rstrtmgr.dll", CharSet = CharSet.Unicode)]
				static extern int RmRegisterResources(uint pSessionHandle,
					UInt32 nFiles,
					string[] rgsFilenames,
					UInt32 nApplications,
					[In] RM_UNIQUE_PROCESS[] rgApplications,
					UInt32 nServices,
					string[] rgsServiceNames);
				[DllImport("rstrtmgr.dll", CharSet = CharSet.Auto)]
				static extern int RmStartSession(out uint pSessionHandle, int dwSessionFlags, string strSessionKey);
				[DllImport("rstrtmgr.dll")]
				static extern int RmEndSession(uint pSessionHandle);
				[DllImport("rstrtmgr.dll")]
				static extern int RmGetList(uint dwSessionHandle,
					out uint pnProcInfoNeeded,
					ref uint pnProcInfo,
					[In, Out] RM_PROCESS_INFO[] rgAffectedApps,
					ref uint lpdwRebootReasons);
				/// Find out what process(es) have a lock on the specified file.
				/// <param name="path">Path of the file.</param>
				/// <returns>Processes locking the file</returns>
				/// http://msdn.microsoft.com/en-us/library/windows/desktop/aa373661(v=vs.85).aspx
				/// http://wyupdate.googlecode.com/svn-history/r401/trunk/frmFilesInUse.cs (no copyright in code at time of viewing)
				static public List<Process> WhoIsLocking(string path)
				{
					uint handle;
					string key = Guid.NewGuid().ToString();
					List<Process> processes = new List<Process>();
					int res = RmStartSession(out handle, 0, key);
					if (res != 0) throw new Exception("Could not begin restart session. Unable to determine file locker.");
					try
					{
						const int ERROR_MORE_DATA = 234;
						uint pnProcInfoNeeded = 0,
						pnProcInfo = 0,
						lpdwRebootReasons = RmRebootReasonNone;
						// Just checking on one resource
						string[] resources = new string[] { path };
						res = RmRegisterResources(handle, (uint)resources.Length, resources, 0, null, 0, null);
						if (res != 0) throw new Exception("Could not register resource.");
						//Note: there's a race condition here -- the first call to RmGetList() returns
						// the total number of process. However, when we call RmGetList() again to get
						// the actual processes this number may have increased.
						res = RmGetList(handle, out pnProcInfoNeeded, ref pnProcInfo, null, ref lpdwRebootReasons);
						if (res == ERROR_MORE_DATA)
						{
							// Create an array to store the process results
							RM_PROCESS_INFO[] processInfo = new RM_PROCESS_INFO[pnProcInfoNeeded];
							pnProcInfo = pnProcInfoNeeded;
							// Get the list
							res = RmGetList(handle, out pnProcInfoNeeded, ref pnProcInfo, processInfo, ref lpdwRebootReasons);
							if (res == 0)
							{
								processes = new List<Process>((int)pnProcInfo);
								// Enumerate all of the results and add them to the 
								// list to be returned
								for (int i = 0; i < pnProcInfo; i++)
								{
									try
									{
										processes.Add(Process.GetProcessById(processInfo[i].Process.dwProcessId));
									}
									// catch the error -- in case the process is no longer running
									catch (ArgumentException) { }
								}
							}
							else throw new Exception("Could not list processes locking resource.");
						}							else if (res != 0) throw new Exception("Could not list processes locking resource. Failed to get size of result.");
					}
					finally
					{
						RmEndSession(handle);
					}
						return processes;
					}
			}
		}
"@
	if (-not ("MyCore.Utils.FileLockUtil" -as [type]))
	{
		Add-Type -ReferencedAssemblies $ReferencedAssemblies -TypeDefinition $TypeDefinition
	}
	[MyCore.Utils.FileLockUtil]::WhoIsLocking($FilePath)
}
# Get-FileLockProcess -FilePath "D:\file.ext"
