<#
	.SYNOPSIS
	Calculate SHA256 hash and save it into a SHA256SUM file with UTF-8 encoding

	.PARAMETER Path
	Path to a folder with ZIP archives to calculate

	.EXAMPLE
	SHA256SUM -Path D:\Sophia
#>
function SHA256SUM
{
	param
	(
		[string]
		$Path
	)

	Get-ChildItem -Path $Path -Filter *.zip -Force | ForEach-Object -Process {
		"$($_.Name)  $((Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash)"
	} | Set-Content -Path "$Path\SHA256SUM" -Encoding Default -Force
}
