<#
	.SYNOPSIS
	Set action when lid is closed

	.PARAMETER Action
	Action to do

	.EXAMPLE Se "Do nothing"
	Set-CloseLidAction -Action DoNothing

	.NOTES
	https://docs.microsoft.com/en-us/windows-hardware/customize/power-settings/power-button-and-lid-settings-lid-switch-close-action
#>
function Set-CloseLidAction
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[ValidateSet(
			"DoNothing",
			"Sleep",
			"Hibernate",
			"ShutDown"
		)]
		[string]
		$Action
	)

	enum LidAction
	{
		DoNothing = 0
		Sleep     = 1
		Hibernate = 2
		ShutDown  = 3
	}

	# Get active plan
	# Get-CimInstance won't work due to Get-CimInstance -Namespace root\cimv2\power -ClassName Win32_PowerPlan doesn't have the "Activate" trigger as Get-WmiObject does
	$CurrentPlan = Get-WmiObject -Namespace root\cimv2\power -ClassName Win32_PowerPlan | Where-Object -FilterScript {$_.IsActive}

	# Get "Lid closed" setting
	$lidSetting = Get-CimInstance -Namespace root\cimv2\power -ClassName Win32_Powersetting | Where-Object -FilterScript {$_.InstanceID -match "5ca83367-6e45-459f-a27b-476b1d01c936"}

	# Get GUIDs
	$CurrentPlanGUID = [Regex]::Matches($CurrentPlan.InstanceId, "{.*}" ).Value
	$lidGUID = [Regex]::Matches($lidSetting.InstanceID, "{.*}" ).Value

	# Get and set "Plugged in lid" setting (AC/DC)
	Get-CimInstance -Namespace root\cimv2\power -ClassName Win32_PowerSettingDataIndex | Where-Object -FilterScript {
		($_.InstanceID -eq "Microsoft:PowerSettingDataIndex\$CurrentPlanGUID\AC\$lidGUID") -or ($_.InstanceID -eq "Microsoft:PowerSettingDataIndex\$CurrentPlanGUID\DC\$lidGUID")
	} | Set-CimInstance -Property @{SettingIndexValue = [int][LidAction]::$Action}

	# Refresh
	# $CurrentPlan | Invoke-CimMethod -MethodName Activate results in "This method is not implemented in any class"
	$CurrentPlan.Activate
}
Set-CloseLidAction -Action DoNothing
