<# planets.csv
Planet,Diameter
 "Mercury","4879"
 "Venus","12104"
 "Earth","12756"
 "Mars","6805"
 "Jupiter","142984"
 "Saturn","120536"
 "Uranus","51118"
 "Neptune","49528"
 "Pluto","2306"
#>

class Planet : System.Management.Automation.IValidateSetValuesGenerator
{
	[String[]] GetValidValues()
	{
		$Global:planets = Import-CSV -Path "D:\planets.csv"
		return ($Global:planets).Planet
	}
}

Function Get-PlanetDiameter
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $false)]
		[ValidateSet([Planet])]
		[string]
		$Planet
	)

	$Planet | Foreach-Object -Process {
		$targetplanet = $planets | Where-Object -Property Planet -match $_
		$output = "The diameter of planet {0} is {1} km" -f $targetplanet.Planet, $targetplanet.Diameter

		Write-Output $output
	}
}
