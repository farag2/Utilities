$Username = [Security.Principal.WindowsIdentity]::GetCurrent().Name -split "\\" | Select-Object -Index 1

$OU = ((Get-ADUser -Identity $Username).DistinguishedName.Split(",") | Select-Object -Index 1).Split("=") | Select-Object -Index 1
$Printers = @{
	Accounting     = @("printer1")
	Contractor     = @("printer1")
	Finance        = @("printer1")
	Legal          = @("printer2", "printer3")
}
$InstallingPrinters = @(Get-Printer -ComputerName ukhadps003 -Name $Printers[$OU] | Where-Object -FilterScript {$_.DeviceType -eq "Print"})

foreach ($InstallingPrinter in $InstallingPrinters.Name)
{
	Add-Printer -ConnectionName "\\<printserver>\$InstallingPrinter"
}

Start-Process -FilePath ms-settings:printers

# Set default printer
$DefaultPrinter = Get-CimInstance -ClassName CIM_Printer | Where-Object -FilterScript {$_.ShareName -eq "$($InstallingPrinter | Select-Object -Index 0)"}
Invoke-CimMethod -InputObject $DefaultPrinter -MethodName SetDefaultPrinter
