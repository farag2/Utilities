# Printers list
$PrinterIPs = @(
	IP_address1,
	IP_address2,
	IP_address3
)
foreach ($PrinterIP in $PrinterIPs)
{
	Get-Printer -ComputerName server | Where-Object -FilterScript {($_.PortName -eq $PrinterIP) -and ($_.DeviceType -eq "Print")} | Select-Object -Property Name, DriverName, PortName
}
