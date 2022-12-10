# https://ponderthebits.com/2018/02/windows-rdp-related-event-logs-identification-tracking-and-investigation/
# https://xplantefeve.io/posts/SchdTskOnEvent

$RDPLogOffTask = @"
if (-not (Test-Path -Path `$env:SystemDrive\tmp))
{
	New-Item -Path `$env:SystemDrive\tmp -ItemType Directory -Force
}

New-Item -Path `$env:SystemDrive\tmp -ItemType File -Name `$env:USERNAME -Force
New-Item -Path `$env:SystemDrive\tmp -ItemType File -Name user.txt -Value `$env:USERNAME -Force
"@

$Action = New-ScheduledTaskAction -Execute powershell.exe -Argument "-WindowStyle Hidden -Command $RDPLogOffTask"
$Principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType ServiceAccount
$Settings = New-ScheduledTaskSettingsSet -Compatibility Win8
$Trigger = Get-CimClass -ClassName MSFT_TaskEventTrigger -Namespace root/Microsoft/Windows/TaskScheduler | New-CimInstance -ClientOnly
$Trigger.Enabled = $true
$Trigger.Subscription = '<QueryList><Query Id="0" Path="Microsoft-Windows-Security-Auditing"><Select Path="Microsoft-Windows-Security-Auditing">*[System[EventID=4634]]</Select></Query></QueryList>'
$Parameters = @{
	TaskName    = "Name"
	Description = "Description"
	TaskPath    = "Folder"
	Action      = $Action
	Principal   = $Principal
	Settings    = $Settings
	Trigger     = $Trigger
}
Register-ScheduledTask @Parameters -Force
