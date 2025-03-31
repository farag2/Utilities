# Validate emails by sending commands to an SMTP server 
# https://github.com/gscales/Powershell-Scripts/blob/master/TLS-SMTPMod.ps1
$check_email = "test@domain.com"
$SaveFile = "D:\1.txt"
$Domain = ([mailaddress]$check_email).Host

$Array = @("noreply_pfrussia@pierre-fabre.com")
foreach ($email in $Array)
{
	# Initial check
	try
	{
		$Parameters = @{
			Name = ([mailaddress]$email).Host
			Type = "MX"
		}

		try
		{
			$Resolve = Resolve-DnsName @Parameters -ErrorAction Stop
		}
		catch
		{
			Add-Content -Path $SaveFile -Value "$email. Initial check failed" -Force
			continue
		}
	}
	catch
	{
		Add-Content -Path $SaveFile -Value "$email. Initial check failed" -Force
		continue
	}

	if ($Resolve)
	{
		$NameExchange = (Resolve-DnsName -Name ($Resolve.Name | Select-Object -First 1) -Type MX).NameExchange | Select-Object -First 1

		<#
		if ($Resolve)
		{
			$Parameters = @{
				SmtpServer = $NameExchange
				Port       = 25
				From       = $check_email
				To         = $email
				Subject    = "Test"
				Body       = "Test"
			}
			Send-MailMessage @Parameters
		}
		#>

		$email

		try
		{
			$Socket = New-Object -TypeName System.Net.Sockets.TcpClient($NameExchange, 25)
		}
		catch
		{
			Write-Warning -Message "$email. Connection was forcibly closed by the remote host"
			Add-Content -Path $SaveFile -Value "$email. Connection was forcibly closed by the remote host" -Force

			continue
		}

		$stream = $Socket.GetStream()

		try
		{
			$streamWriter = New-Object -TypeName System.IO.StreamWriter($stream)
		}
		catch
		{
			Write-Warning -Message "$email. Cannot access a disposed object"
			Add-Content -Path $SaveFile -Value "$email. Cannot access a disposed object" -Force

			$stream.Close()

			continue
		}
		$streamReader = New-Object -TypeName System.IO.StreamReader($stream)
		$streamWriter.AutoFlush = $true

		$ConnectResponse = $streamReader.ReadLine()
		if (-not ($ConnectResponse.StartsWith("220")))
		{
			Write-Warning -Message $ConnectResponse
			Add-Content -Path $SaveFile -Value "$email. $ConnectResponse" -Force

			$streamWriter.WriteLine("QUIT")
			$stream.Close()

			continue
		}
		else
		{
			Write-Verbose -Message $ConnectResponse -Verbose
		}

		# https://datatracker.ietf.org/doc/html/rfc1869#section-4
		try
		{
			$streamWriter.WriteLine("HELO $Domain")
		}
		catch
		{
			Write-Warning -Message "$email. Cannot access a disposed object"
			Add-Content -Path $SaveFile -Value "$email. Cannot access a disposed object" -Force

			$streamWriter.WriteLine("QUIT")
			$stream.Close()

			continue
		}

		$ehloResponse = $streamReader.ReadLine()
		if (-not ($ehloResponse.StartsWith("250")))
		{
			Write-Warning -Message $ehloResponse
			Add-Content -Path $SaveFile -Value "$email. $ehloResponse" -Force

			$streamWriter.WriteLine("QUIT")
			$stream.Close()

			continue
		}
		else
		{
			# Write-Verbose -Message $ehloResponse -Verbose
		}

		$streamWriter.WriteLine("MAIL FROM:<$check_email>")
		$FromResponse = $streamReader.ReadLine()
		if (-not ($FromResponse.StartsWith("250")))
		{
			Write-Warning -Message $FromResponse
			Add-Content -Path $SaveFile -Value "$email. $FromResponse" -Force

			$streamWriter.WriteLine("QUIT")
			$stream.Close()

			continue
		}
		else
		{
			# Write-Verbose -Message $FromResponse -Verbose
		}

		# Write-Verbose -Message QUIT -Verbose
		$streamWriter.WriteLine("QUIT")
		$Quit = $streamReader.ReadLine()
		if (-not ($Quit.StartsWith("221")))
		{
			Write-Warning -Message $ToResponse
			Add-Content -Path $SaveFile -Value "$email. $Quit" -Force

			$streamWriter.WriteLine("QUIT")
			$stream.Close()

			continue
		}
		else
		{
			$streamReader.ReadLine()

		}

		# Write-Verbose -Message QUIT -Verbose
		$streamWriter.WriteLine("QUIT")

		$stream.Close()
	}
}
