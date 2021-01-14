<#
	.SYNOPSIS
	Publish PowerShell module to PowerShell Gallery

	.PARAMETER Path
	Path to a module folder

	.PARAMETER NuGetApiKey
	Your API key got from PowerShell Gallery

	.EXAMPLE
	PublishModule -Path D:\folder -NuGetApiKey <APIKey>
#>
function PublishModule
{
	param
	(
		[Parameter(Mandatory = $true)]
		[String]
		$Path,

		[Parameter(Mandatory = $true)]
		[String]
		$NuGetApiKey
	)

	Clear-Host

	# [Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("Windows-1251")

	if ($psISE)
	{
		exit
	}

	# Enable TLS 1.2
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

	# Automatically installs the NuGet provider if it isn't installed
	Get-PackageProvider -Name NuGet -ForceBootstrap

	if ($null -eq (Get-Module PowerShellGet -ListAvailable | Where-Object -FilterScript {$_.Version -eq "2.2.5"}))
	{
		Install-Module -Name PowerShellGet -RequiredVersion 2.2.5 -Force
	}
	else
	{
		Import-Module -Name PowerShellGet
	}

	if (-not (Test-Path -Path HKLM:\Software\Microsoft\.NetFramework\v4.8))
	{
		New-Item -Path HKLM:\Software\Microsoft\.NetFramework\v4.8 -Force
	}
	New-ItemProperty -Path HKLM:\Software\Microsoft\.NetFramework\v4.8 -Name SchUseStrongCrypto -Value 1 -PropertyType DWord -Force

	# Publishing
	Publish-Module -Path $Path -NuGetApiKey $NuGetApiKey -Force -Verbose

	Remove-Item -Path HKLM:\Software\Microsoft\.NetFramework\v4.8 -Force
}

PublishModule -Path "C:\Users\test\Desktop\Sophia" -NuGetApiKey oy2gxymm4xz75t7vwcna6q6fp7ubfi3upbbqwf4ebceyxu