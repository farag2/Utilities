# Download file from SFTP server via WinSCP
# https://winscp.net/eng/docs/library#classes

Add-Type -Path "D:\WinSCPnet.dll"

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

$Session = New-Object -TypeName WinSCP.Session
$SessionOptions = New-Object -TypeName WinSCP.SessionOptions -Property @{
	Protocol              = [WinSCP.Protocol]::Sftp
	HostName              = "server"
	UserName              = "username"
	Password              = "password1"
	PrivateKeyPassphrase  = "password2"
	SshPrivateKeyPath     = "D:\folder\key.ppk"
	SshHostKeyFingerprint = "ssh-ed25519 255 xxxxxxxxxxxxxxxx"
}

$Session.Open($sessionOptions)

$TransferOptions = New-Object -TypeName WinSCP.TransferOptions
$TransferOptions.TransferMode = [WinSCP.TransferMode]::Binary

$Directory = $session.ListDirectory("/folder_on_remote_server")
foreach ($file in $Directory.Files)
{
	# Get files with current date in their name in "date.month.year" format (17.03.2025)
	$File | Where-Object -FilterScript {$_.Name -match (Get-Date).ToString("dd.MM.yyyy")} | ForEach-Object -Process {
		# Copy file to folder without deleting the original
		$TransferResult = $Session.GetFiles(
			$_.FullName,
			# Where copy files to
			"D:\Download",
			# Do not delete original files
			$false,
			$TransferOptions
		)

		# Check for errors
		$TransferResult.Check()
	}
}

$session.Dispose()
