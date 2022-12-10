# A reminder to print a photo to keep your deskjet printer working good
# A pop-up appears every 10 days

# Persist Sophia notifications to prevent to immediately disappear from Action Center
if (-not (Test-Path -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Sophia))
{
	New-Item -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Sophia -Force
}
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Sophia -Name ShowInActionCenter -PropertyType DWord -Value 1 -Force

if (-not (Test-Path -Path Registry::HKEY_CLASSES_ROOT\AppUserModelId\Sophia))
{
	New-Item -Path Registry::HKEY_CLASSES_ROOT\AppUserModelId\Sophia -Force
}
# Register app
New-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\AppUserModelId\Sophia -Name DisplayName -Value Sophia -PropertyType String -Force
# Determines whether the app can be seen in Settings where the user can turn notifications on or off
New-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\AppUserModelId\Sophia -Name ShowInSettings -Value 0 -PropertyType DWord -Force

# Register the "PrintPhoto" protocol to be able to run the scheduled task by clicking the "Run" button in a toast
if (-not (Test-Path -Path Registry::HKEY_CLASSES_ROOT\PrintPhoto\shell\open\command))
{
	New-Item -Path Registry::HKEY_CLASSES_ROOT\PrintPhoto\shell\open\command -Force
}
New-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\PrintPhoto -Name "(default)" -PropertyType String -Value "URL:PrintPhoto" -Force
New-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\PrintPhoto -Name "URL Protocol" -PropertyType String -Value "" -Force
New-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\PrintPhoto -Name EditFlags -PropertyType DWord -Value 2162688 -Force

# Start the "Print a Photo" task if the "Run" button clicked
New-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\PrintPhoto\shell\open\command -Name "(default)" -PropertyType String -Value 'powershell.exe -Command "& {rundll32 C:\WINDOWS\system32\shimgvw.dll,ImageView_PrintTo C:\file.JPG ''Printer Name''}"' -Force

$ToastNotification = @"
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null

[xml]`$ToastTemplate = @"""
<toast duration="""Long""">
	<visual>
		<binding template="""ToastGeneric""">
			<text>Time to print a file. Check your printer first</text>
		</binding>
	</visual>
	<audio src="""ms-winsoundevent:notification.default""" />
	<actions>
		<action content="""Run""" arguments="""PrintPhoto:""" activationType="""protocol"""/>
		<action content="""""" arguments="""dismiss""" activationType="""system"""/>
	</actions>
</toast>
"""@

`$ToastXml = [Windows.Data.Xml.Dom.XmlDocument]::New()
`$ToastXml.LoadXml(`$ToastTemplate.OuterXml)

`$ToastMessage = [Windows.UI.Notifications.ToastNotification]::New(`$ToastXML)
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("""Sophia""").Show(`$ToastMessage)
"@

# Create the "Windows Cleanup Notification" task
$Action    = New-ScheduledTaskAction -Execute powershell.exe -Argument "-WindowStyle Hidden -Command $ToastNotification"
$Settings  = New-ScheduledTaskSettingsSet -Compatibility Win8 -StartWhenAvailable
$Principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest
$Trigger   = New-ScheduledTaskTrigger -Daily -DaysInterval 10 -At 9pm
$Parameters = @{
	TaskName    = "Print a Photo"
	Action      = $Action
	Settings    = $Settings
	Principal   = $Principal
	Trigger     = $Trigger
}
Register-ScheduledTask @Parameters -Force

# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/start-process?view=powershell-7.3#example-6-using-different-verbs-to-start-a-process
# Start-Process -FilePath C:\file.JPG -Verb PrintTo("Printer Name")
