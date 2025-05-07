# wevtutil.exe sl Microsoft-Windows-PrintService/Operational /enabled:true

$Security = @{
	LogName   = "Microsoft-Windows-PrintService/Operational"
	Id        = "307"
	# Last 1 day. Not yesterday
	StartTime = (Get-Date).AddDays(-1)
}
$UserName = @{
	Name       = "UserName"
	Expression = {$_.Properties[2].Value}
}
$Document = @{
	Name       = "Document"
	Expression = {$_.Properties[1].Value}
}
$PrinterName = @{
	Name       = "PrinterName"
	Expression = {$_.Properties[4].Value}
}
$PrintSize = @{
	Name       = "Print Size, KB"
	Expression = {$_.Properties[4].Value}
}
Get-WinEvent -FilterHashtable $Security | Select-Object -Property TimeCreated, $UserName, $Document, $PrinterName, $PrintSize | Format-Table -AutoSize -Wrap
