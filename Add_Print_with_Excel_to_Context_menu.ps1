# Print an Excel file and fit to one page instatly from context menu 
if (-not (Test-Path -LiteralPath "HKCU:\Software\Classes\*\shell\fit_to_page\command"))
{
	New-Item -Path "HKCU:\Software\Classes\*\shell\fit_to_page\command" -Force
}
New-ItemProperty -LiteralPath "HKCU:\Software\Classes\*\shell\fit_to_page" -Name "(default)" -PropertyType String -Value "Распечатать, вписав в страницу" -Force
New-ItemProperty -LiteralPath "HKCU:\Software\Classes\*\shell\fit_to_page" -Name Icon -PropertyType String -Value "%SystemRoot%\\System32\\shell32.dll,71" -Force
New-ItemProperty -LiteralPath "HKCU:\Software\Classes\*\shell\fit_to_page\command" -Name "(default)" -PropertyType String -Value "powershell.exe -ExecutionPolicy Bypass -NoProfile -NoLogo -Command `"& {`"D:\\Excel.ps1`" `"%1`"}`"" -Force

# Remove context menu item
# Remove-Item -LiteralPath "HKCU:\Software\Classes\*\shell\fit_to_page" -Recurse -Force



# Create D:\Excel.ps1
# Print an Excel file and fit to one page
$Excel = New-Object -ComObject Excel.Application
$Excel.Visible = $false
$Workbooks = $Excel.Workbooks.Open($args)
# Grab the first worksheet
$Worksheets = $Workbooks.Worksheets.Item(1)
$Worksheets.PageSetup.Zoom = $false
$Worksheets.PageSetup.FitToPagesWide = 1
$Worksheets.PageSetup.FitToPagesTall = 1
$Worksheets.PageSetup.Orientation = 1
# $xl.ActivePrinter = "Printer name"
# Print
$Workbooks.PrintOut()
$Excel.Workbooks.Close()
$Excel.Quit()

# Garbage collection
$null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Excel)
$null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Workbooks)
$null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Worksheets)
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()
