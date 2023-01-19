# https://git.zx2c4.com/wireguard-windows/about/docs/enterprise.md
Get-Process -Name wireguard -ErrorAction Ignore | Stop-Process -Force

# Driver Removal
& "$PSScriptRoot\wireguard.exe" /removedriver

if (Get-Service -Name WireGuardTunnel* -ErrorAction Ignore)
{
	$conf = (Get-Service -Name WireGuardTunnel* -ErrorAction Ignore).Name.Split("$") | Select-Object -Index 1
	if ($conf)
	{
		# Uninstall Tunnel service
		Write-Verbose -Message $conf -Verbose
		Start-Process -FilePath "$PSScriptRoot\wireguard.exe" -ArgumentList "/uninstalltunnelservice $conf" -Wait
	}

	# Uninstall services
	Start-Process -FilePath "$PSScriptRoot\wireguard.exe" -ArgumentList "/uninstallmanagerservice" -Wait
}

if (Test-Path -Path "$env:ProgramFiles\WireGuard")
{
	# --%
	& takeown /F "$env:ProgramFiles\WireGuard" /R

	$UserFiles = Get-ChildItem -Path "$env:ProgramFiles\WireGuard" -File -Recurse -Force
	foreach ($Folder in $UserFiles)
	{
		& icacls "$($Folder.FullName)" /grant:r "$($env:USERNAME):F" /T
	}

	Remove-Item -Path $env:ProgramFiles\WireGuard -Recurse -Force
}

# Helps if the app cannot be installed
# https://support.microsoft.com/en-us/topic/fix-problems-that-block-programs-from-being-installed-or-removed-cca7d1b6-65a9-3d98-426b-e9f927e1eb4d

# The deselecting of “block untunneled traffic (kill-switch)” option changes the following line
# AllowedIPs = 0.0.0.0/0, ::/0
# AllowedIPs = 0.0.0.0/1, 128.0.0.0/1, ::/1, 8000::/1
