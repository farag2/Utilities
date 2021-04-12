# -All
#Disable-WindowsOptionalFeature -Path $WIMTemp -FeatureName LegacyComponents -ScratchDirectory $env:TEMP -Remove -NoRestart -Verbose

#Dismount-WindowsImage -Path $WIMTemp -Discard -Verbose

function Get-ValidValues
{
	[CmdletBinding()]
	param
	(
		[string]
		$Path
	)

	(Get-ChildItem -Path "D:\Folder" -File -Recurse).FullName
}

function Get-FileLength
{
	[CmdletBinding()]
	param
	(
		[Parameter(
			Mandatory = $true,
			Position = 0
		)]
		[ArgumentCompleter(
			{
				param
				(
					$commandName,
					$parameterName,
					$wordToComplete,
					$commandAst,
					$fakeBoundParameters
				)

				Get-ValidValues -Path $Path | ForEach-Object -Process {"`"$_`""}
			}
		)]
		[ValidateScript(
			{
				$_ -in (Get-ValidValues -Path $Path)
			}
		)]
		[string[]]
		$Paths
	)

	foreach ($Path in $Paths)
	{
		(Get-ChildItem -Path $Path).Length
	}
}