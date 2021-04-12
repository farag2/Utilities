[CmdletBinding()]
param()

DynamicParam
{
	# Имя динамических параметров
	$ParameterName = 'Functions'

	# Создание словаря
	$RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

	# Коллекция атрибутов
	$AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]

	# Атрибуты параметров
	$ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
	$ParameterAttribute.Mandatory = $true
	$ParameterAttribute.Position = 1

	# Добавить атрибуты в коллекцию атрибутов
	$AttributeCollection.Add($ParameterAttribute)

	# Создать и установить ValidateSet
	$arrSet = & {
		Remove-Module -Name Sophia -Force -ErrorAction Ignore
		Import-Module -Name $PSScriptRoot\Sophia.psd1 -PassThru -Force

		Import-LocalizedData -BindingVariable Global:Localization -FileName Sophia

		$Keys = (Get-Module -Name Sophia).ExportedCommands.Keys
		foreach ($Key in $Keys)
		{
			$ParameterSets = (Get-Command -Name $Key).ParameterSets | Select-Object -ExpandProperty Parameters | Where-Object -FilterScript {$_.IsMandatory}
			foreach ($ParameterSet in $ParameterSets.Name)
			{
				$Key + " -$($ParameterSet)"
			}
			continue
		}
	}
	$ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)

	# Добавить ValidateSet в коллекцию атрибутов
	$AttributeCollection.Add($ValidateSetAttribute)

	# Создать и вернуть динамический параметр
	$RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string[]], $AttributeCollection)
	$RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)

	return $RuntimeParameterDictionary
}

begin
{
	# Свяжите параметр с переменной
	[string[]]$Functions = $PsBoundParameters[$ParameterName]
}

end
{
	Invoke-Command -ScriptBlock {Checkings}

	foreach ($Function in $Functions)
	{
		Invoke-Expression -Command $Function
	}

	Invoke-Command -ScriptBlock {Refresh; Errors}
}
