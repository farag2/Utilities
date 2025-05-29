#Requires -RunAsAdministrator

Write-Verbose -Message BIOS -Verbose
$Version = @{
	Name       = "Version"
	Expression = {$_.Name}
}
(Get-CimInstance -ClassName CIM_BIOSElement | Select-Object -Property Manufacturer, $Version | Format-Table | Out-String).Trim()

Write-Verbose -Message Motherboard"
(Get-CimInstance -ClassName Win32_BaseBoard | Select-Object -Property Manufacturer, Product | Format-Table | Out-String).Trim()

Write-Verbose -Message "Serial number" -Verbose
(Get-CimInstance -ClassName Win32_BIOS).Serialnumber

Write-Verbose -Message CPU -Verbose
$Cores = @{
	Name       = "Cores"
	Expression = {$_.NumberOfCores}
}
$L3CacheSize = @{
	Name       = "L3, MB"
	Expression = {$_.L3CacheSize/1024}
}
$Threads = @{
	Name       = "Threads"
	Expression = {$_.NumberOfLogicalProcessors}
}
(Get-CimInstance -ClassName CIM_Processor | Select-Object -Property Name, $Cores, $L3CacheSize, $Threads | Format-Table | Out-String).Trim()

Write-Verbose -MessageRAM -Verbose
$Speed = @{
	Name       = "Speed, MHz"
	Expression = {$_.ConfiguredClockSpeed}
}
$Capacity = @{
	Name       = "Capacity, GB"
	Expression = {$_.Capacity/1GB}
}
(Get-CimInstance -ClassName CIM_PhysicalMemory | Select-Object -Property Manufacturer, PartNumber, $Speed, $Capacity | Format-Table | Out-String).Trim()

Write-Verbose -Message "Physical disks" -Verbose
$Model = @{
	Name       = "Model"
	Expression = {$_.FriendlyName}
}
$MediaType = @{
	Name       = "Drive type"
	Expression = {$_.MediaType}
}
$Size = @{
	Name       = "Size, GB"
	Expression = {[math]::round($_.Size/1GB, 2)}
}
$BusType = @{
	Name       = "Bus type"
	Expression = {$_.BusType}
}
(Get-PhysicalDisk | Select-Object -Property $Model, $MediaType, $BusType, $Size | Format-Table | Out-String).Trim()

# Integrated graphics
if ((Get-CimInstance -ClassName CIM_VideoController | Where-Object -FilterScript {$_.AdapterDACType -eq "Internal"}))
{
	$Caption = @{
		Name       = "Model"
		Expression = {$_.Caption}
	}
	$VRAM = @{
		Name       = "VRAM, MB"
		Expression = {[math]::round($_.AdapterRAM/1MB)}
	}
	Get-CimInstance -ClassName CIM_VideoController | Where-Object -FilterScript {$_.AdapterDACType -eq "Internal"} | Select-Object -Property $Caption, $VRAM
}

# Dedicated graphics
if ((Get-CimInstance -ClassName CIM_VideoController | Where-Object -FilterScript {$_.AdapterDACType -ne "Internal"}))
{
	$qwMemorySize = (Get-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0*" -Name HardwareInformation.qwMemorySize -ErrorAction SilentlyContinue)."HardwareInformation.qwMemorySize"
	foreach ($VRAM in $qwMemorySize)
	{
		Get-CimInstance -ClassName CIM_VideoController | Where-Object -FilterScript {$_.AdapterDACType -ne "Internal"} | ForEach-Object -Process {
			[PSCustomObject] @{
				Model      = $_.Caption
				"VRAM, MB" = [math]::round($VRAM/1MB)
			}

			continue
		}
	}
}
