# Create a table with userIDs and full path to profiles if profile contains file.ini that was modified more than half of year ago
Get-ChildItem -Path \\server\folder$ -Recurse -Force | ForEach-Object -Process {
        Write-Verbose -Message $_ -Verbose

        # Some profiles doesn't have file.ini
        if (Test-Path -Path "$($_.FullName)\file.ini")
        {
               # Get files if they are old than 180 days (~ half of a year)
               Get-Item -Path "$($_.FullName)\file.ini" -Force | Where-Object -FilterScript {$_.LastWriteTime -lt (Get-Date).AddDays(-180)} | ForEach-Object -Process {
                       [PSCustomObject]@{
                               FullName      = $_.FullName
                               userID        = Split-Path -Path $_.FullName | Split-Path -Leaf
                               LastWriteTime = $_.LastWriteTime.ToString("dd.MM.yyyy")
                       }
               } | Select-Object -Property FullName, userID, LastWriteTime | Export-Csv -Path "D:\list.csv" -Encoding UTF8 -NoTypeInformation -Delimiter ';' -Append
        }
}
