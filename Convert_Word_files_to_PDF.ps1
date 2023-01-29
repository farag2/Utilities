# Convert Word files to PDF. If a corrputed file is found it will be written to to variable

# Remove all records about corrupted files
Remove-ItemProperty -Path HKCU:\Software\Microsoft\Office\16.0\Word\Resiliency\DisabledItems -Name * -ErrorAction Ignore
Clear-Variable -Name CorruptedFiles -Force -ErrorAction Ignore

$Word = New-Object -ComObject Word.Application
# We need $true to see if Word found a corrupted file or other information pop-ups
$Word.Visible = $true

Get-ChildItem -Path "D:\folder" -Include *.docx, *.doc -Recurse -File | ForEach-Object -Process {
	if (Test-Path -Path "$($_.DirectoryName)\$($_.BaseName).pdf")
	{
		$SkippedFiles += "`n$($_.FullName)"

		return
	}

	Write-Verbose -Message $_.FullName -Verbose

	$Document = $Word.Documents.Open($_.FullName)

	# Check if a registry key was created that indicates that a corrupted file were found
	$Path = Get-Item -Path HKCU:\Software\Microsoft\Office\16.0\Word\Resiliency\DisabledItems -ErrorAction Ignore
	foreach ($Item in $Path.Property)
	{
		# Decode binary record that actually is a full path to a corrupted file
		if ([System.Text.Encoding]::Unicode.GetString((Get-ItemPropertyValue -Path HKCU:\Software\Microsoft\Office\16.0\Word\Resiliency\DisabledItems -Name $Item)) -match $_.FullName)
		{
			$CorruptedFiles += "`n$($_.FullName)"
		}
	}

	# https://learn.microsoft.com/en-us/office/vba/api/word.wdsaveformat
	$Document.SaveAs("$($_.DirectoryName)\$($_.BaseName).pdf", 17)
	$Document.Close()
}

# Garbage collection
$Word.Quit()
$null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Word)
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()

if ($SkippedFiles)
{
	$CorruptedFiles | ForEach-Object -Process {
		[PSCustomObject]@{
			"Skipped Files" = $SkippedFiles
		}
	} | Format-Table -AutoSize -Wrap
}

if ($CorruptedFiles)
{
	$CorruptedFiles | ForEach-Object -Process {
		[PSCustomObject]@{
			"Corrupted Files" = $CorruptedFiles
		}
	} | Format-Table -AutoSize -Wrap
}
