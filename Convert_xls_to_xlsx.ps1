Add-Type -AssemblyName Microsoft.Office.Interop.Excel

$Excel = New-Object -ComObject Excel.Application
# Hide Excel pop-up
$Excel.Visible = $false
# Hide overwrite pop-up
$Excel.DisplayAlerts = $false
Get-ChildItem -Path $PSScriptRoot -Include *.xls -Recurse | ForEach-Object {
	Write-Warning -Message "$($_.FullName) file converting"

	$Workbook = $Excel.Workbooks.Open($_.FullName)
	$Workbook.SaveAs($_.FullName.Replace("xls", "xlsx"), [Microsoft.Office.Interop.Excel.XlFileFormat]::xlWorkbookDefault)
	$Workbook.Close()
}
$Excel.Quit()

# Garbage collection
$null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Workbook)
$null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Excel)
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()

Write-Warning -Message "Researching done"

Pause
