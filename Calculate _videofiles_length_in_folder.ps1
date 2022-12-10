# Calculate videofiles' length in folder
function Get-Duration
{
	[CmdletBinding()]
	Param
	(
		[string]
		$Path,

		[string]
		$Extention
	)

	$Shell = New-Object -ComObject Shell.Application
	$TotalDuration = [timespan]0

	Get-ChildItem -Path $Path -Filter *.$Extention | ForEach-Object -Process {
		$Folder = $Shell.Namespace($Path)
		$File = $Folder.ParseName($_.Name)
		$Duration = [timespan]$Folder.GetDetailsOf($File, 27)
		$TotalDuration += $Duration

		[PSCustomObject]@{
			File     = $_.Name
			Duration = $Duration
		}
	}

	"`nTotal duration $TotalDuration"
}
Get-Duration -Path D:\folder -Extention mp4 | Sort-Object -Property Duration
