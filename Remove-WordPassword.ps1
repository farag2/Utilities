<#
	.SYNOPSIS
	Remove password from docx file by editing settings.xml inside archive directly

	.EXAMPLE
	Remove-WordPassword -Path "D:\1.docx"
#>
function Remove-WordPassword
{
	param([string]$Path)

	# Check if file is opened by another process
	$File = Split-Path -Path $Path -Leaf
	$ProcessUsed = Get-CimInstance -ClassName CIM_Process | Where-Object -FilterScript {($_.ProcessId -ne $PID) -and ($_.CommandLine -match $File)}
	if ($ProcessUsed)
	{
		Write-Warning -Message "The file is opened by $($ProcessUsed.ExecutablePath)"
		exit
	}

	Add-Type -AssemblyName System.IO.Compression.FileSystem

	# Open file
	$archive = [System.IO.Compression.ZipFile]::Open($Path, "Update")
	$settingsEntry = $archive.GetEntry("word/settings.xml")

	# Read content
	$stream = $settingsEntry.Open()
	$reader = New-Object System.IO.StreamReader($stream)
	$content = $reader.ReadToEnd()
	$reader.Close()
	$stream.Close()

	# Remove "documentProtection" element
	[xml]$xml = $content
	$NamespaceManager = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
	$NamespaceManager.AddNamespace("w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main")
	$protectionNodes = $xml.SelectNodes("//w:documentProtection", $NamespaceManager)
	if ($xml.settings.documentProtection)
	{
		foreach ($node in $protectionNodes) 
		{
			$node.ParentNode.RemoveChild($node)
		}

		# Delete old entry and create new one
		$settingsEntry.Delete()
		$newEntry = $archive.CreateEntry("word/settings.xml")
		$newStream = $newEntry.Open()
		$writer = New-Object System.IO.StreamWriter($newStream)
		$writer.Write($xml.OuterXml)

		$writer.Close()
		$newStream.Close()
	}
	else
	{
		Write-Warning -Message "$($Path) is not protected"
	}

	$archive.Dispose()
}
