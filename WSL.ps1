# https://github.com/farag2/Windows-10-Setup-Script/issues/43
# https://github.com/microsoft/WSL/issues/5437

# Install the Windows Subsystem for Linux (WSL2)
# Установить подсистему Windows для Linux (WSL2)
$Title = "Windows Subsystem for Linux"
$Message = "Would you like to install Windows Subsystem for Linux (WSL)?"
$Options = "&Install", "&Skip"
$DefaultChoice = 1
$Result = $Host.UI.PromptForChoice($Title, $Message, $Options, $DefaultChoice)

switch ($Result)
{
	"0"
	{
		$WSLFeatures = @(
			# Enable the Windows Subsystem for Linux
			# Включить подсистему Windows для Linux
			"Microsoft-Windows-Subsystem-Linux",

			# Enable Virtual Machine Platform
			# Включить поддержку платформы для виртуальных машин
			"VirtualMachinePlatform"
		)
		Enable-WindowsOptionalFeature -Online -FeatureName $WSLFeatures -NoRestart

		# Downloading the Linux kernel update package
		# Скачиваем пакет обновления ядра Linux
		try
		{
			[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
			if ((Invoke-WebRequest -Uri https://www.google.com -UseBasicParsing -DisableKeepAlive -Method Head).StatusDescription)
			{
				$Parameters = @{
					Uri = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
					OutFile = "$PSScriptRoot\wsl_update_x64.msi"
					Verbose = [switch]::Present
				}
				Invoke-WebRequest @Parameters

				Start-Process -FilePath $PSScriptRoot\wsl_update_x64.msi -ArgumentList "/passive" -Wait
				Remove-Item -Path $PSScriptRoot\wsl_update_x64.msi -Force
			}
		}
		catch [Exception]
		{
			Write-Warning -Message "No Internet connection" -ErrorAction SilentlyContinue
		}
	}
	"1"
	{
		Write-Verbose -Message "Skipped" -Verbose
	}
}

if (Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux)
{
	# Set WSL 2 as your default version. Run the command only after restart
	# Установить WSL 2 как версию по умолчанию. Выполните команду только после перезагрузки
	wsl --set-default-version 2

	# Configuring .wslconfig
	# Настраиваем .wslconfig
	if (-not (Test-Path -Path "$env:HOMEPATH\.wslconfig"))
	{
		$wslconfig = @"
[wsl2]
swap=0
"@
		# Saving .wslconfig in UTF-8 encoding
		# Сохраняем .wslconfig в кодировке UTF-8
		Set-Content -Path "$env:HOMEPATH\.wslconfig" -Value (New-Object System.Text.UTF8Encoding).GetBytes($wslconfig) -Encoding Byte -Force
	}
	else
	{
		$String = Get-Content -Path "$env:HOMEPATH\.wslconfig" | Select-String -Pattern "swap=" -SimpleMatch
		if ($String)
		{
			(Get-Content -Path "$env:HOMEPATH\.wslconfig").Replace("swap=1", "swap=0") | Set-Content -Path "$env:HOMEPATH\.wslconfig" -Force
		}
		else
		{
			Add-Content -Path "$env:HOMEPATH\.wslconfig" -Value "`r`nswap=0" -Force
		}
	}
}
