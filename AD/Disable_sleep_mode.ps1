# Create a scheduled task to disable sleep mode
$Script = @"
POWERCFG /CHANGE standby-timeout-ac 0
POWERCFG /CHANGE standby-timeout-dc 0

POWERCFG /CHANGE monitor-timeout-ac 0
POWERCFG /CHANGE monitor-timeout-dc 0
"@
$Action    = New-ScheduledTaskAction -Execute powershell.exe -Argument "-WindowStyle Hidden -Command $Script"
$Trigger   = New-ScheduledTaskTrigger -Daily -At 10am
$Settings  = New-ScheduledTaskSettingsSet -Compatibility Win8 -StartWhenAvailable
$Principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME
$Parameters = @{
	TaskName  = "Kontur no sleep mode"
	Principal = $Principal
	Trigger   = $Trigger
	Action    = $Action
	Settings  = $Settings
}
$task = Register-ScheduledTask @Parameters -Force
$task.Triggers.Repetition.Duration = "P1D"
$task.Triggers.Repetition.Interval = "PT30M"
$task | Set-ScheduledTask