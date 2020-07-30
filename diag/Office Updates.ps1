# http://www.bifido.net/tweaks-and-scripts/7-script-of-additional-cleanup-of-windows-updates.html

$RegProducts = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products"
$RegPatches = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Patches"

function Get-UpdatesResult ([string]$Title, [string[]]$UpdatesList, [string[]]$ActualUpdates)
{
	if ($null -ne $UpdatesList)
	{
		Write-Host "Component: " -ForegroundColor Green -NoNewline
		Write-Host $Title -ForegroundColor Yellow
		if ($null -ne $ActualUpdates)
		{
			Write-Host "Actual update is : " -ForegroundColor Cyan -NoNewline
			Write-Host $ActualUpdates[($ActualUpdates.count - 1)]
		}
		if ($null -ne $UpdatesList)
		{
			$UpdatesList | Out-Host
			Write-Host
		}
	}
}

function Get-SupersededState ([string]$Patche)
{
	$IsSuperseded = "False"
	$Uninstallable = (Get-ItemProperty -LiteralPath "Registry::$Patche").'Uninstallable'
	if ("$Uninstallable" -eq "1")
	{
		$State = (Get-ItemProperty -LiteralPath "Registry::$Patche").'State'
		if ("$State" -eq "2")
		{
			$IsSuperseded = "True"
		}
	}
	return $IsSuperseded
}

function Get-Guid ([string]$t)
{
	$guid = $t[7] + $t[6] + $t[5] + $t[4] + $t[3] + $t[2] + $t[1] + $t[0] + "-"
	$guid += $t[11] + $t[10] + $t[9] + $t[8] + "-"
	$guid += $t[15] + $t[14] + $t[13] + $t[12] + "-"
	$guid += $t[17] + $t[16] + $t[19] + $t[18] + "-"
	$guid += $t[21] + $t[20] + $t[23] + $t[22] + $t[25] + $t[24] + $t[27] + $t[26] + $t[29] + $t[28] + $t[31] + $t[30]
	return $guid
}

function Get-OfficeUpdate
{
	[System.Collections.Hashtable]$ProductsNames = @{}
	[System.Collections.Hashtable]$ProductsUpdates = @{}
	[System.Collections.Hashtable]$ProductsPatches = @{}

	[string[]]
	$Updates = $null
	[string[]]
	$Patches = $null

	foreach ($r in (Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products))
	{
		if ($r.PSChildName -match "000000F01FEC")
		{
			$Updates = $null
			$Patches = $null
			$KeyPatches = "$r" + "\" + "Patches"
			foreach ($p in (Get-ChildItem -Path "Registry::$KeyPatches"))
			{
				$IsSuperseded = Get-SupersededState $p
				if ("$IsSuperseded" -eq "True")
				{
					$Update = (Get-ItemProperty -LiteralPath "Registry::$p").'DisplayName'
					$Updates += , "$Update"
					$Patches += , $p.PSChildName
				}
			}

			if ($null -ne $Patches)
			{
				$KeyProduct = "$r" + "\" + "InstallProperties"
				$ProductName = (Get-ItemProperty -LiteralPath "Registry::$KeyProduct").'DisplayName'
				$ProductsNames[$r.PSChildName] = $ProductName
				$ProductsPatches[$r.PSChildName] = $Patches
				$ProductsUpdates[$r.PSChildName] = $Updates
			}
		}
	}

	if ($ProductsNames.count -gt 0)
	{
		foreach ($Key in $ProductsNames.Keys)
		{
			$Title = $ProductsNames["$Key"]
			$Updates = $ProductsUpdates["$Key"]
			if ($null -ne $Updates)
			{
				Get-UpdatesResult $Title $Updates
			}
		}
		pause

		foreach ($Key in $ProductsNames.Keys)
		{
			$Title = $ProductsNames["$Key"]
			$Updates = $ProductsUpdates["$Key"]
			$Patches = $ProductsPatches["$Key"]
			$ProductGuid = Get-Guid "$Key"
			Write-Host "Component: " -ForegroundColor Green -NoNewline
			Write-Host $Title -ForegroundColor Yellow

			for ($n=0; $n -lt $Patches.count; $n++)
			{
				$Patche = $Patches[$n]
				$PatcheGuid = Get-Guid $Patche
				Write-Host "Removing: " -ForegroundColor Cyan -NoNewline
				Write-Host $Updates[$n]

				if ((Test-Path -Path "$RegPatches\$Patche") -and (Test-Path "$RegProducts\$Key\Patches\$Patche"))
				{
					$PathPatche = (Get-ItemProperty -LiteralPath "$RegPatches\$Patche").'LocalPackage'
					if (Test-Path -Path "$PathPatche")
					{
						& "msiexec.exe" /package "{$ProductGuid}" /uninstall "{$PatcheGuid}" /qn /norestart | Out-Null
						if (Test-Path -Path "$RegProducts\$Key\Patches\$Patche")
						{
							Write-Host "Error occurred" -ForegroundColor Red
						}
					}
					else
					{
						Write-Host "Installer not exist" -ForegroundColor Magenta
					}
				}
				else
				{
					Write-Host "Already removed" -ForegroundColor Magenta
				}
			}
		}
	}
	else
	{
		Write-Host "There are no updates to remove"
	}
}
Get-OfficeUpdate
