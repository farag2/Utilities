# Create Scheduled Task triggered by enabling and disabling USB-mode while tethering

# https://newtechaudit.ru/analiz-logov-windows-sredstvami-powershell/
# https://docs.nxlog.co/userguide/integrate/windows-usb-auditing.html
# https://www.netscylla.com/blog/2020/02/03/Windows-Event-Logs-and-USB-Tracking.html
# https://www.techrepublic.com/article/how-to-track-down-usb-flash-drive-usage-in-windows-10s-event-viewer/
# https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-6416

# Set UTF-8 encoding to console
# ping.exe | Out-Null
# $OutputEncoding = [System.Console]::OutputEncoding = [System.Console]::InputEncoding = [System.Text.Encoding]::UTF8

# https://gist.github.com/kyle-dempsey/95246276b04f20c90a2b5f5502ecf6b3
# auditpol /get /category:*
# "Plug and Play Events", "Removable Storage", "Handle Manipulation"
# "Самонастраиваемые события", "Съемные носители", "Работа с дескриптором"
# Do not put a space when listing
# auditpol /set /subcategory:"{0CCE9248-69AE-11D9-BED3-505054503030}","{0CCE9245-69AE-11D9-BED3-505054503030}","{0CCE9223-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable

<#
(Get-EventLog –LogName Security -InstanceId 6416 -Newest 1).Message

Get-WinEvent -FilterHashTable @{
	LogName   = "Microsoft-Windows-NetworkProfile/Operational"
	ID        = 20002
	StartTime = (Get-Date).Date
}

(Get-NetAdapter -Physical | Where-Object -FilterScript {$_.ComponentID -match "USB"}).InterfaceGuid
#>


<#
# Reset all metrics
Get-NetIPinterface -AddressFamily IPv4 | ForEach-Object -Process {
	Set-NetIPInterface -ifIndex $_.ifIndex -AutomaticMetric Enabled 
}

Get-NetAdapter -Physical | Get-NetIPinterface | Where-Object -FilterScript {$_.AddressFamily -eq "IPv4"}
Get-NetIPinterface -AddressFamily IPv4
#>

# Set USB connection as a primary one
Get-NetAdapter -Physical | Where-Object -FilterScript {$_.ComponentID -match "USB"} | Get-NetIPinterface | Where-Object -FilterScript {$_.AddressFamily -eq "IPv4"} | ForEach-Object -Process {
	Set-NetIPInterface -ifIndex $_.ifIndex -InterfaceMetric 1
}

# Plug in
$Code = @"
# Set TTL. The default value is 128
Set-NetIPv4Protocol -DefaultHopLimit 65
"@
$Action = New-ScheduledTaskAction -Execute powershell.exe -Argument "-WindowStyle Hidden -Command $Code"
$Principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest
$Settings = New-ScheduledTaskSettingsSet -Compatibility Win8
$Trigger = Get-CimClass -ClassName MSFT_TaskEventTrigger -Namespace root/Microsoft/Windows/TaskScheduler | New-CimInstance -ClientOnly
$Trigger.Enabled = $true
$Trigger.Subscription = '<QueryList><Query Id="0" Path="Microsoft-Windows-NetworkProfile/Operational"><Select Path="Microsoft-Windows-NetworkProfile/Operational">*[System[(Level=4 or Level=0) and (EventID=20002)]]</Select></Query></QueryList>'
$Parameters = @{
	TaskName    = "Enable"
	Description = ""
	# TaskPath    = ""
	Action      = $Action
	Principal   = $Principal
	Settings    = $Settings
	Trigger     = $Trigger
}
Register-ScheduledTask @Parameters -Force

# Plug out
$Code = @"
# Set TTL. The default value is 128
Set-NetIPv4Protocol -DefaultHopLimit 64
"@
$Action = New-ScheduledTaskAction -Execute powershell.exe -Argument "-WindowStyle Hidden -Command $Code"
$Principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME  -RunLevel Highest
$Settings = New-ScheduledTaskSettingsSet -Compatibility Win8
$Trigger = Get-CimClass -ClassName MSFT_TaskEventTrigger -Namespace root/Microsoft/Windows/TaskScheduler | New-CimInstance -ClientOnly
$Trigger.Enabled = $true
$Trigger.Subscription = '<QueryList><Query Id="0" Path="Microsoft-Windows-NetworkProfile/Operational"><Select Path="Microsoft-Windows-NetworkProfile/Operational">*[System[(Level=4 or Level=0) and (EventID=10001)]]</Select></Query></QueryList>'
$Parameters = @{
	TaskName    = "Disable"
	Description = ""
	# TaskPath    = ""
	Action      = $Action
	Principal   = $Principal
	Settings    = $Settings
	Trigger     = $Trigger
}
Register-ScheduledTask @Parameters -Force
