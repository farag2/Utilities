<#
	.SYNOPSIS
	Trigger SCCM Client actions

	.PARAMETER Schedules
	Trigger the scpecific SCCM Client actions

	.PARAMETER All
	Trigger all SCCM Client actions at once

	.EXAMPLE
	Trigger-Schedule -Schedules @("UserPolicyRetrievalEvalCycle", "SoftwareUpdates")

	.EXAMPLE
	Trigger-Schedule -All

	.NOTES
	https://docs.microsoft.com/en-us/mem/configmgr/develop/reference/core/clients/client-classes/triggerschedule-method-in-class-sms_client
	https://stackoverflow.com/a/63916401/8315671
#>
function Trigger-Schedule
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $false)]
		[ValidateSet(
			"AppDeployment",
			"DiscoveryData",
			"FileCollection",
			"HardwareInventory",
			"MachinePolicyRetrieval",
			"SoftwareInventory",
			"SoftwareMeteringUsage",
			"SoftwareUpdates",
			"SoftwareUpdatesScan",
			"UserPolicyRetrievalEvalCycle",
			"WindowsInstallerSourceListUpdate"
		)]
		[string[]]
		$Schedules,

		[Parameter(Mandatory = $false)]
		[switch]
		$All
	)

	$SupportedSchedules = @{
		"AppDeployment"                    = "{00000000-0000-0000-0000-000000000121}"
		"DiscoveryData"                    = "{00000000-0000-0000-0000-000000000003}"
		"FileCollection"                   = "{00000000-0000-0000-0000-000000000010}"
		"HardwareInventory"                = "{00000000-0000-0000-0000-000000000001}"
		"MachinePolicyRetrieval"           = "{00000000-0000-0000-0000-000000000021}"
		"SoftwareInventory"                = "{00000000-0000-0000-0000-000000000002}"
		"SoftwareMeteringUsage"            = "{00000000-0000-0000-0000-000000000031}"
		"SoftwareUpdates"                  = "{00000000-0000-0000-0000-000000000108}"
		"SoftwareUpdatesScan"              = "{00000000-0000-0000-0000-000000000113}"
		"UserPolicyRetrievalEvalCycle"     = "{00000000-0000-0000-0000-000000000027}"
		"WindowsInstallerSourceListUpdate" = "{00000000-0000-0000-0000-000000000032}"
	}

	foreach ($Schedule in $Schedules)
	{
		if ($Schedule -eq "UserPolicyRetrievalEvalCycle") # "Policy Agent Request Assignment" too
		{
			Write-Verbose -Message $SupportedSchedules[$Schedule] -Verbose

			$SID = (Get-CimInstance -Namespace root\ccm -ClassName CCM_UserLogonEvents | Where-Object -FilterScript {$null -eq $_.LogoffTime}).UserSID.Replace("-", "_")
			$ActualConfig = Get-WmiObject -ClassName CCM_Scheduler_ScheduledMessage -Namespace root\ccm\Policy\$SID\ActualConfig | Where-Object -FilterScript {$_.ScheduledMessageID -eq $SupportedSchedules[$Schedule]}
			$ActualConfig.Triggers = @('SimpleInterval;Minutes=1;MaxRandomDelayMinutes=0')
			$ActualConfig.Put()

			Start-Sleep -Seconds 10

			# $SID = (Get-CimInstance -namespace root\ccm -ClassName CCM_UserLogonEvents | Where-Object -FilterScript {$null -eq $_.LogoffTime}).UserSID.Replace("-", "_")
			# $ActualConfig = Get-CimInstance -Namespace root\ccm\Policy\$SID\ActualConfig -ClassName CCM_Scheduler_ScheduledMessage | Where-Object -FilterScript {$_.ScheduledMessageID -eq $Schedule}
			# $ActualConfig.Triggers = @('SimpleInterval;Minutes=1;MaxRandomDelayMinutes=0')
			# $ActualConfig | Set-CimInstance
		}
		else
		{
			Invoke-CimMethod -Namespace root\ccm -ClassName SMS_Client -MethodName TriggerSchedule -Arguments @{sScheduleID = $SupportedSchedules[$Schedule]}
		}
	}

	# Call all schedules at once
	if ($All)
	{
		foreach ($Schedule in $SupportedSchedules.Values)
		{
			Write-Verbose -Message $Schedule -Verbose

			if ($Schedule -eq "{00000000-0000-0000-0000-000000000027}") # "Policy Agent Request Assignment" too
			{
				$SID = (Get-CimInstance -Namespace root\ccm -ClassName CCM_UserLogonEvents | Where-Object -FilterScript {$null -eq $_.LogoffTime}).UserSID.Replace("-", "_")
				$ActualConfig = Get-WmiObject -ClassName CCM_Scheduler_ScheduledMessage -Namespace root\ccm\Policy\$SID\ActualConfig | Where-Object -FilterScript {$_.ScheduledMessageID -eq $Schedule}
				$ActualConfig.Triggers = @('SimpleInterval;Minutes=1;MaxRandomDelayMinutes=0')
				$ActualConfig.Put()

				Start-Sleep -Seconds 10

				# $SID = (Get-CimInstance -Namespace root\ccm -ClassName CCM_UserLogonEvents | Where-Object -FilterScript {$null -eq $_.LogoffTime}).UserSID.Replace("-", "_")
				# $ActualConfig = Get-CimInstance -ClassName CCM_Scheduler_ScheduledMessage -Namespace root\ccm\Policy\$SID\ActualConfig | Where-Object -FilterScript {$_.ScheduledMessageID -eq $Schedule}
				# $ActualConfig.Triggers = @('SimpleInterval;Minutes=1;MaxRandomDelayMinutes=0')
				# $ActualConfig | Set-CimInstance
			}
			else
			{
				Invoke-CimMethod -Namespace root\ccm -ClassName SMS_Client -MethodName TriggerSchedule -Arguments @{sScheduleID = $Schedule}

				Start-Sleep -Seconds 10
			}
		}
	}
}
