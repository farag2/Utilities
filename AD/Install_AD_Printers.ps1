$Printers = @{
	Accounting     = @("Printer1")
	Contractor     = @("Printer2")
	Finance        = @("Printer3")
	Legal          = @("Printer4", "Printer5")
	Marketing      = @("Printer5")
	Sales          = @("Printer6", "Printer7")
	"Supply Chain" = @("Printer8", "Printer9")
	Warehouse      = @("Printer10", "Printer11")
}
$InstallingPrinters = @(Get-Printer -ComputerName server -Name $Printers[$OU] | Where-Object -FilterScript {$_.DeviceType -eq "Print"})

foreach ($InstallingPrinter in $InstallingPrinters.Name)
{
	Add-Printer -ConnectionName "\\server\$InstallingPrinter"
}

Start-Process -FilePath ms-settings:printers

# Set default printer
$DefaultPrinter = Get-CimInstance -ClassName CIM_Printer | Where-Object -FilterScript {$_.ShareName -eq "$($InstallingPrinter | Select-Object -Index 0)"}
Invoke-CimMethod -InputObject $DefaultPrinter -MethodName SetDefaultPrinter
