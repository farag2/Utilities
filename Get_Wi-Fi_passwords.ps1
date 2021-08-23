# Get Wi-Fi SSIDs and Passwords
if ($PSUICulture -eq "ru-RU")
{
	ping.exe | Out-Null
	$OutputEncoding = [System.Console]::OutputEncoding = [System.Console]::InputEncoding = [System.Text.Encoding]::UTF8
}

$Profiles = netsh wlan show profiles | Select-String -Pattern "All User Profile" | Foreach-Object -Process {$_.ToString().Split(":")[-1].Trim()}
$Profiles | Foreach-Object -Process {
	$Password = netsh wlan show profiles name=$_ key="clear" | Select-String -Pattern "Key Content" | Foreach-Object -Process {$_.ToString().Split(":")[-1].Trim()}
	[PSCustomObject]@{
		SSID = $_
		Password = $Password
	}
}
