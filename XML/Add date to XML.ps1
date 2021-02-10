<#
<configuration xmlns:patch="https://www.dotnet-helpers.com/xmlconfig/">
	<dotnet-helpers-tutorials>
		<tutorials name="tutorial:start">
			<Topics hint="list">
				<Topic>MVC</Topic>
				<Topic>Jquery</Topic>
				<Topic>OOPS</Topic>
			</Topics>
		</tutorials>
	</dotnet-helpers-tutorials>
</configuration>
#>

<#
	.SYNOPSIS
	Write data to an xml file

	.EXAMPLE
	AddEntryInConfig -Selector "//tutorials[@name='tutorial:start']" -Path "C:\Desktop\test.xml" -NewNode "PowerShell"

	.NOTES
	https://dotnet-helpers.com/powershell/how-to-write-data-to-an-xml-file-using-powershell/
#>

function AddEntryInConfig
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]
		$Selector,

		[Parameter(Mandatory = $true)]
		[string]
		$Path,

		[Parameter(Mandatory = $true)]
		[string]
		$NewNode
	)

	# Get the content of the file using the path
	[xml]$XmlDocument = Get-Content -Path $Path -Force

	# Selecting all the childs by finding its parent with $Selector value
	$events = $XmlDocument.SelectSingleNode($Selector)

	# Assigning the chilld elements to variable
	$topics = $events.Topics

	# creating new Element with heading as "Topic"
	$child = $XmlDocument.CreateElement("Topic")

	# Assinging the value to the Element "Topic"
	$child.InnerText = $NewNode

	# The appendChild method is used to add the data in the newly created XmlElement to the XmlDocument.
	$topics.AppendChild($child)

	# Save in to the file
	$XmlDocument.Save($Path)
}

# AddEntryInConfig -Selector "//tutorials[@name='tutorial:start']" -Path "C:\Desktop\test.xml" -NewNode "PowerShell"
