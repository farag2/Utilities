# Change file encoding to UTF-8 with BOM or UTF-8 without BOM
function ConvertEncoding
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]
		$Path,

		[Parameter(Mandatory = $true)]
		[ValidateSet("UTF8", "UTF8BOM")]
		[string]
		$Encoding
	)

	switch ($Encoding)
	{
		"UTF8"
		{
			# Конвертировать файл в кодировку UTF8 без BOM
			$Content = Get-Content -Path $Path -Raw
			Set-Content -Value (New-Object System.Text.UTF8Encoding).GetBytes($Content) -Encoding Byte -Path $Path -Force
			# [System.IO.File]::WriteAllText($Path, $Content)
		}
	}
	switch ($Encoding)
	{
		"UTF8BOM"
		{
			# Конвертировать файл в кодировку UTF8 с BOM
			(Get-Content -Path $Path -Encoding UTF8) | Set-Content -Encoding UTF8 -Path $Path -Force
		}
	}
}

ConvertEncoding -Path "C:\Desktop\33.ps1" -Encoding UTF8