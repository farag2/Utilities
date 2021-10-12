# https://docs.microsoft.com/en-us/windows/terminal/

Clear-Host

if ($psISE)
{
	exit
}

# Intalling the latest PowerShellGet
if (-not (Get-Package -Name NuGet -Force -ErrorAction Ignore))
{
	Install-Package -Name NuGet -Force
}

Remove-Module -Name PackageManagement -Force

if ((Get-Childitem -path "$env:ProgramFiles\WindowsPowerShell\Modules\PowerShellGet").Count -eq 1)
{
	$CurrentPowerShellGetVersion = (Get-Childitem -Path "$env:ProgramFiles\WindowsPowerShell\Modules\PowerShellGet").Name | Select-Object -Index 0
}
else
{
	$CurrentPowerShellGetVersion = (Get-Childitem -Path "$env:ProgramFiles\WindowsPowerShell\Modules\PowerShellGet").Name | Select-Object -Last 1
}

if ([System.Version]$CurrentPowerShellGetVersion -lt [System.Version]"2.2.5")
{
	Install-Module -Name PowerShellGet -Force

	# Removing the old PowerShellGet
	Remove-Module -Name PowerShellGet -Force
	# Removing all folders except the latest one
	Remove-Item -Path ((Get-Childitem -Path "$env:ProgramFiles\WindowsPowerShell\Modules\PowerShellGet").FullName | Select-Object -SkipLast 1) -Recurse -Force

	Import-Module -Name PowerShellGet -Force

	Write-Verbose -Message "Restart the PowerShell session, and re-run the script" -Verbose

	Import-Module -Name PackageManagement -Force

	exit
}

# Intalling the latest PSReadLine
# https://github.com/PowerShell/PSReadLine/releases
$LatestRelease = (Invoke-RestMethod -Uri "https://api.github.com/repos/PowerShell/PSReadLine/releases/latest").tag_name.Replace("v","")
if (Test-Path -Path "$env:ProgramFiles\WindowsPowerShell\Modules\PSReadline\2.1.0\Microsoft.PowerShell.PSReadLine2.dll")
{
	$CurrentRelease = (Get-Module -Name PSReadline).Version.ToString()
}
else
{
	$null = $CurrentRelease
}

# Check if PSReadline is installed
if ($null -ne (Get-Module -Name PSReadline))
{
	if ([System.Version]$LatestRelease -gt [System.Version]$CurrentRelease)
	{
		# Intalling the latest PSReadLine
		if (-not (Get-Package -Name NuGet -Force -ErrorAction Ignore))
		{
			Install-Package -Name NuGet -Force
		}
		Install-Module -Name PSReadLine -RequiredVersion $LatestRelease -Force

		# Removing the old PSReadLine
		$PSReadLine = @{
			ModuleName    = "PSReadLine"
			ModuleVersion = $CurrentVersion
		}
		Remove-Module -FullyQualifiedName $PSReadLine -Force
		Get-InstalledModule -Name PSReadline -AllVersions | Where-Object -FilterScript {$_.Version -eq $CurrentVersion} | Uninstall-Module -Force
		Remove-Item -Path $env:ProgramFiles\WindowsPowerShell\Modules\PSReadline\$CurrentVersion -Recurse -Force -ErrorAction Ignore

		Import-Module -Name PSReadLine -Force

		Get-InstalledModule -Name PSReadline -AllVersions

		Write-Verbose -Message "Restart the PowerShell session, and re-run the script" -Verbose

		exit
	}
}
else
{
	# Intalling the latest PSReadLine
	if (-not (Get-Package -Name NuGet -Force -ErrorAction Ignore))
	{
		Install-Package -Name NuGet -Force
	}
	Install-Module -Name PSReadLine -RequiredVersion $LatestRelease -Force

	Import-Module -Name PSReadLine

	Write-Verbose -Message "Restart the PowerShell session, and re-run the script" -Verbose

	exit
}
