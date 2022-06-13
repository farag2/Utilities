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
