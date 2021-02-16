# Uninstall unnecessary Office 2010-2016 updates
# http://www.bifido.net/tweaks-and-scripts/7-script-of-additional-cleanup-of-windows-updates.html

function Get-SupersededState ([string]$Patch)
{
	# Проверка состояния обновления
	$IsSuperseded = $false
	$Uninstallable = Get-ItemPropertyValue -LiteralPath "Registry::$Patch" -Name Uninstallable

	# Обновление является удаляемым
	if ($Uninstallable -eq "1")
	{
		$State = Get-ItemPropertyValue -LiteralPath "Registry::$Patch" -Name State
		# Обновление является устаревшим
		if ($State -eq "2")
		{
			$IsSuperseded = $true
		}
	}

	return $IsSuperseded
}

function Get-Guid ([string]$Token)
{
	# Преобразование ключа реестра соответствующего обновлению в специальное значение необходимое для его удаления
	$guid = $Token[7] + $Token[6] + $Token[5] + $Token[4] + $Token[3] + $Token[2] + $Token[1] + $Token[0] + "-"
	$guid += $Token[11] + $Token[10] + $Token[9] + $Token[8] + "-"
	$guid += $Token[15] + $Token[14] + $Token[13] + $Token[12] + "-"
	$guid += $Token[17] + $Token[16] + $Token[19] + $Token[18] + "-"
	$guid += $Token[21] + $Token[20] + $Token[23] + $Token[22] + $Token[25] + $Token[24] + $Token[27] + $Token[26] + $Token[29] + $Token[28] + $Token[31] + $Token[30]

	return $guid
}

function Get-OfficeUpdates
{
	# Поиск устаревших обновлений для офиса
	[System.Collections.Hashtable]$ProductsNames = @{}
	[System.Collections.Hashtable]$ProductsUpdates = @{}
	[System.Collections.Hashtable]$ProductsPatches = @{}

	# Список обновлений 
	[string[]]$Updates = $null
	[string[]]$Patches = $null

	# Цикл по офисным продуктам
	foreach ($Product in (Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products"))
	{
		# Значения оканчивающиеся 000000F01FEC
		if ($Product.PSChildName -match "000000F01FEC")
		{
			$Updates = $null
			$Patches = $null
			$KeyPatches = "$Product\Patches"

			# Цикл по обновлениям для выбранного продукта
			foreach ($Item in Get-ChildItem -Path "Registry::$KeyPatches")
			{
				# Проверка состояния обновления
				$IsSuperseded = Get-SupersededState -Patch $Item

				# Обновление является устаревшим
				if ($IsSuperseded)
				{
					# Получение имени обновления
					$Update = Get-ItemPropertyValue -LiteralPath "Registry::$Item" -Name DisplayName
					# Получение списка названий обновлений
					$Updates += , "$Update"
					# Получение списка ключей
					$Patches += , $Item.PSChildName
				}
			}

			if ($Patches)
			{
				# Получение имени продукта
				$KeyProduct = "$Product\InstallProperties"
				$ProductName = Get-ItemProperty -LiteralPath "Registry::$KeyProduct" -Name DisplayName
				$ProductsNames[$Product.PSChildName] = $ProductName
				$ProductsPatches[$Product.PSChildName] = $Patches
				$ProductsUpdates[$Product.PSChildName] = $Updates
			}
		}
	}

	# Вывод результатов
	if ($ProductsNames.Count -gt 0)
	{
		foreach ($Key in $ProductsNames.Keys)
		{
			# Название продукта
			$Title = $ProductsNames["$Key"]
			# Обновления
			$Updates = $ProductsUpdates["$Key"]
		}

		Clear-Host

		# Удаление обновлений
		foreach ($Key in $ProductsNames.Keys)
		{
			# Название продукта
			$Title = $ProductsNames["$Key"]
			# Обновления
			$Updates = $ProductsUpdates["$Key"]
			# Ключи
			$Patches = $ProductsPatches["$Key"]
			# Преобразование ключа в специальное значение
			$ProductGuid = Get-Guid -Token "$Key"

			# Цикл по удаляемым обновлениям
			for
			(
				$n = 0
				$n -lt $Patches.Count
				$n++
			)
			{
				# Преобразование ключа в специальное значение
				$Patch = $Patches[$n]
				$PatchGuid = Get-Guid -Token $Patch

				# Вывод имени удаляемого обновления
				Write-Host "Removing: " -NoNewline
				Write-Host $Updates[$n]

				# Удаление обновления с помощью специальных значений для продукта и обновления
				if ((Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Patches\$Patch") -and (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\$Key\Patches\$Patch"))
				{
					# Проверка существования файла инсталлятора для обновления
					if ($PathPatch = (Get-ItemPropertyValue -LiteralPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Patches\$Patch" -Name LocalPackage))
					{
						if (Test-Path -Path "$PathPatch")
						{
							& "msiexec.exe" /package "{$ProductGuid}" /uninstall "{$PatchGuid}" /qn /norestart | Out-Null

							if (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\$Key\Patches\$Patch")
							{
								Write-Warning -Message "Error occurred"
							}
						}
						else
						{
							Write-Warning -Message "Installer not exist"
						}
					}
					else
					{
						Write-Warning -Message "Path not exist"
					}
				}
				else
				{
					Write-Warning -Message "Already removed"
				}
			}
		}
	}
	else
	{
		Write-Warning -Message "There are no updates to remove"
	}

	pause
}

Get-OfficeUpdates
pause