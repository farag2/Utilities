<#
<?xml version="1.0" encoding="utf-8"?>
<HelpBox>
	<Categorys>
		<Category Selected="True" Name="Admin Tools"></Category>
		<Category Selected="False" Name="Scripts"></Category>
		<Category Selected="False" Name="Clipboard"></Category>
	</Categorys>
	<Actions></Actions>
</HelpBox>
#>

<#
	.SYNOPSIS
	Write data to an xml file

	.EXAMPLE
	AddEntryInConfig -Selector "//tutorials[@name='tutorial:start']" -Path "C:\Desktop\test.xml" -NewNode "PowerShell"

	.NOTES
	https://social.technet.microsoft.com/Forums/scriptcenter/en-US/eb4f4d97-1c6e-41e5-830f-244b50bf722c/append-to-an-xml-file-with-powershell
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
		$Fragment
	)

	[xml]$xml = Get-Content -Path $Path
	$xmlFrag = $xml.CreateDocumentFragment()
	$xmlFrag.InnerXml = $Fragment
	$node = $xml.SelectSingleNode($Selector)
	$node.AppendChild($xmlFrag)
	$xml.Save($Path)
}

$Fragment = @'
<Item Name="CMD" Icon="27" TaskType="Launch" Category="Scripts">
	<File>C:\Windows\System32\cmd.exe</File>
	<Arg></Arg>
</Item>
'@

AddEntryInConfig -Selector "//Actions" -Path "C:\Desktop\test.xml" -Fragment $Fragment
