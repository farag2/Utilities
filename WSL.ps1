# Install the Windows Subsystem for Linux (WSL)
# Установить подсистему Windows для Linux (WSL)
if ($RU)
{
	$Message = "Чтобы установить Windows Subsystem for Linux, введите необходимую букву"
	$Options = "&Установить", "&Пропустить"
}
else
{
	$Message = "To install the Windows Subsystem for Linux enter the required letter"
	$Options = "&Install", "&Skip"
}
$DefaultChoice = 1
$Result = $Host.UI.PromptForChoice($Title, $Message, $Options, $DefaultChoice)

switch ($Result)
{
	"0"
	{
		# Enable the Windows Subsystem for Linux
		# Включить подсистему Windows для Linux
		Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
		# Enable Virtual Machine Platform
		# Включить поддержку платформы для виртуальных машин
		Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart

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
			if ($RU)
			{
				Write-Warning -Message "Отсутствует интернет-соединение" -ErrorAction SilentlyContinue
			}
			else
			{
				Write-Warning -Message "No Internet connection" -ErrorAction SilentlyContinue
			}
		}
	}
	"1"
	{
		if ($RU)
		{
			Write-Verbose -Message "Пропущено" -Verbose
		}
		else
		{
			Write-Verbose -Message "Skipped" -Verbose
		}
	}
}

if (Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux)
{
	# Set WSL 2 as your default version. Run the command only after restart
	# Установить WSL 2 как версию по умолчанию. Выполните команду только после перезагрузки
	wsl --set-default-version 2

	# Configuring .wslconfig
	# Настраиваем .wslconfig
	# https://github.com/microsoft/WSL/issues/5437
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
			Add-Content -Path "$env:HOMEPATH\.wslconfig" -Value "swap=0" -Force
		}
	}
}