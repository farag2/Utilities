Get-Service -name spooler | Stop-Service -Force
Remove-Item -Path "$env:SystemRoot\System32\spool\PRINTERS" -Recurse -Force
Get-Service -name spooler | Start-Service
