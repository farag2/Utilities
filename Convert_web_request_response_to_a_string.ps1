# https://gist.github.com/mklement0/209a9506b8ba32246f95d1cc238d564d
function ConvertTo-BodyWithEncoding
{
	[CmdletBinding(PositionalBinding = $false)]
	param
	(
		[Parameter(Mandatory, ValueFromPipeline)]
		[Microsoft.PowerShell.Commands.WebResponseObject]
		$InputObject,

		# The encoding to use; defaults to UTF-8
		[Parameter(Position = 0)]
		$Encoding = [System.Text.Encoding]::UTF8
	)

	begin
	{
		if ($Encoding -isnot [System.Text.Encoding])
		{
			try
			{
				$Encoding = [System.Text.Encoding]::GetEncoding($Encoding)
			}
			catch
			{
				throw
			}
		}
	}

	process
	{
		$Encoding.GetString($InputObject.RawContentStream.ToArray())
	}
}

# We cannot invoke an expression with non-latin words to avoid "??????"
# New-ItemProperty -LiteralPath Registry::HKEY_CLASSES_ROOT\*\shell\Paint.NET -Name "(Default)" -PropertyType String -Value "Открыть с помощью Paint.NET" -Force
$Parameters = @{
	Uri             = "https://raw.githubusercontent.com/farag2/Utilities/master/Paint.NET_context_menu.ps1"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-WebRequest @Parameters | ConvertTo-BodyWithEncoding | Invoke-Expression
