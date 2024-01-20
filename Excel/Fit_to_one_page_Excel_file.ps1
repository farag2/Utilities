# Print an Excel file and fit to one page
$Excel = New-Object -ComObject Excel.Application
$Excel.Visible = $false
$Workbooks = $Excel.Workbooks.Open("D:\file.xlsx")
# Grab the first worksheet
$Worksheets = $Workbooks.Worksheets.Item(1)
$Worksheets.PageSetup.Zoom = $false
$Worksheets.PageSetup.FitToPagesWide = 1
$Worksheets.PageSetup.FitToPagesTall = 1
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
