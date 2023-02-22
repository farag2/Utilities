# Copy WSL distro to a new drive

Get-ChildItem -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss" -Recurse -ErrorAction Ignore | ForEach-Object -Process {Get-ItemProperty -Path $_.PSPath} | Where-Object -FilterScript {$_.Version -eq 2} | ForEach-Object -Process {
	[PSCustomObject]@{
		"Path"   = $_.BasePath
		"Distro" = $_.DistributionName
	}
}

$NewPath = "D:\DistributionName\DistroName"

& wsl --shutdown

if (-not (Test-Path -Path $NewPath))
{
	New-Item -Path $NewPath -Force
}

$Parameters = @{
	Path        = (Get-ChildItem -Path "$env:LOCALAPPDATA\Packages\TheDebianProject.DebianGNULinux_76v4gfsz19hv4\LocalState" -Filter *.vhdx -Force).FullName
	Destination = $NewPath
	Force       = $true
	Verbose     = $true
}
Copy-Item @Parameters

New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss\{caea3eaf-4e1c-4055-bccc-78f7e5134858}" -Name BasePath -Value $NewPath -Force
