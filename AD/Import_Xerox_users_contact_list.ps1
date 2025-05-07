Get-DistributionGroupMember -Identity <DL_Name> | Foreach-Object -Process {
	[PSCustomObject]@{
		"Friendly Name"        = $_.DisplayName
		"E-Mail Address"       = $_.PrimarySmtpAddress
		"Internet Fax Address" = ""
	}
} | Select-Object -Property "Friendly Name", "E-Mail Address", "Internet Fax Address" | Export-Csv -Path D:\Folder\1.csv -NoTypeInformation -Delimiter ',' -Append