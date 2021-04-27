<#
	.SYNOPSIS
	Calculate SHA256 hash and save it into a SHA256SUM file with UTF-8 encoding

	.PARAMETER Path
	Path to a foder with downloaded Sophia Script's zip archives

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

	Get-ChildItem -Path $Path -Filter Sophia.Script*.zip -Force | ForEach-Object -Process {
		"$($_.Name) $((Get-FileHash -Path $_.FullName -Algorithm SHA256).Hash)"
	} | Add-Content -Path "$Path\SHA256SUM" -Encoding Default -Force
}
