<#
	.SYNOPSIS
	Install/uninstall the Windows Subsystem for Linux (WSL)
	Установить/удалить подсистему Windows для Linux (WSL)
	.PARAMETER Enable
	Install the Windows Subsystem for Linux (WSL)
	Установить подсистему Windows для Linux (WSL)
	.PARAMETER Disable
	Uninstall the Windows Subsystem for Linux (WSL)
	Удалить подсистему Windows для Linux (WSL)
	.EXAMPLE
	WSL -Enable
	.EXAMPLE
	WSL -Disable
#>
function WSL
{
	param
	(
		[Parameter(
			Mandatory = $true,
			ParameterSetName = "Enable"
		)]
		[switch]
		$Enable,

		[Parameter(
			Mandatory = $true,
			ParameterSetName = "Disable"
		)]
		[switch]
		$Disable
	)

	$WSLFeatures = @(
		# Windows Subsystem for Linux
		# Подсистема Windows для Linux
		"Microsoft-Windows-Subsystem-Linux",

		# Virtual Machine Platform
		# Поддержка платформы для виртуальных машин
		"VirtualMachinePlatform"
	)

	switch ($PSCmdlet.ParameterSetName)
	{
		"Enable"
		{
			Enable-WindowsOptionalFeature -Online -FeatureName $WSLFeatures -NoRestart

			Write-Warning -Message $Localization.RestartWarning
		}
		"Disable"
		{
			Disable-WindowsOptionalFeature -Online -FeatureName $WSLFeatures -NoRestart

			Uninstall-Package -Name "Windows Subsystem for Linux Update" -Force -ErrorAction SilentlyContinue
			Remove-Item -Path "$env:USERPROFILE\.wslconfig" -Force -ErrorAction Ignore

			Write-Warning -Message $Localization.RestartWarning
		}
	}
}

<#
	.SYNOPSIS
	Download, install the Linux kernel update package and set WSL 2 as the default version when installing a new Linux distribution
	Скачать, установить пакет обновления ядра Linux и установить WSL 2 как версию по умолчанию при установке нового дистрибутива Linux
	.NOTES
	To receive kernel updates, enable the Windows Update setting: "Receive updates for other Microsoft products when you update Windows"
	Чтобы получать обновления ядра, включите параметр Центра обновления Windows: "Получение обновлений для других продуктов Майкрософт при обновлении Windows"
#>
function EnableWSL2
{
	$WSLFeatures = @(
		# Windows Subsystem for Linux
		# Подсистема Windows для Linux
		"Microsoft-Windows-Subsystem-Linux",

		# Virtual Machine Platform
		# Поддержка платформы для виртуальных машин
		"VirtualMachinePlatform"
	)
	$WSLFeaturesDisabled = Get-WindowsOptionalFeature -Online | Where-Object {($_.FeatureName -in $WSLFeatures) -and ($_.State -eq "Disabled")}

	if ($null -eq $WSLFeaturesDisabled)
	{
		if ((Get-Package -Name "Windows Subsystem for Linux Update" -ProviderName msi -Force -ErrorAction Ignore).Status -ne "Installed")
		{
			# Downloading and installing the Linux kernel update package
			# Скачивание и установка пакета обновления ядра Linux
			try
			{
				if ((Invoke-WebRequest -Uri https://www.google.com -UseBasicParsing -DisableKeepAlive -Method Head).StatusDescription)
				{
					Write-Verbose -Message $Localization.WSLUpdateDownloading -Verbose

					[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
					$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
					$Parameters = @{
						Uri = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
						OutFile = "$DownloadsFolder\wsl_update_x64.msi"
						Verbose = [switch]::Present
					}
					Invoke-WebRequest @Parameters

					Write-Verbose -Message $Localization.WSLUpdateInstalling -Verbose
					Start-Process -FilePath "$DownloadsFolder\wsl_update_x64.msi" -ArgumentList "/passive" -Wait

					Remove-Item -Path "$DownloadsFolder\wsl_update_x64.msi" -Force

					Write-Warning -Message $Localization.RestartWarning
				}
			}
			catch [System.Net.WebException]
			{
				Write-Warning -Message $Localization.NoInternetConnection
				Write-Error -Message $Localization.NoInternetConnection -ErrorAction SilentlyContinue
				return
			}
		}
		else
		{
			# Set WSL 2 as the default architecture when installing a new Linux distribution
			# Установить WSL 2 как архитектуру по умолчанию при установке нового дистрибутива Linux
			wsl --set-default-version 2
		}
	}
}
