#Requires -RunAsAdministrator

# Create table with scheduled tasks info that were created a week before the current day
Get-ScheduledTask | Where-Object -FilterScript {$null -ne $_.Date} | ForEach-Object -Process {
	$Task = $_

	$_.Date.Split("T") | Where-Object -FilterScript {$_ -notmatch ":"} | ForEach-Object -Process {
		# Convert dates into the yyyy-MM-dd format
		$Date = [datetime]::ParseExact($_, "yyyy-MM-dd", $Null).ToString("dd.MM.yyyy")

		# If task creation date is between the date that less than week ago and the current day
		if ((Get-Date -Date $Date) -gt (Get-Date).AddDays(-8) -and ((Get-Date -Date $Date) -lt (Get-Date)))
		{
			[PSCustomObject]@{
				"Task Name"     = $Task.TaskName
				Path            = $Task.TaskPath
				"Date Creation" = $Task.Date
			}
		}
	}
}
