#Requires -Version 7

# Unpin all pinned messages from group except one with specific ID

# https://www.nuget.org/packages/WTelegramClient/
# https://my.telegram.org/apps

$api_id   = ""
$api_hash = ""
$Phone    = "+"
# Your group name
$Username = ""
# From link to message. e. g. 1111
$KeepId   = ""

Clear-Host

function Get-Field
{
	param ($Object, [string]$Name)

	$Type  = [type]::GetTypeFromHandle([type]::GetTypeHandle($Object))
	$Field = $Type.GetField($Name)
	if ($Field)
	{
		$Field.GetValue($Object)
	}
}

Add-Type -Path "D:\Desktop\WTelegramClient.dll"

$Client  = $null
$Attempt = 0

try
{
	# Telegram temp code + MFA. If connection drops, recreate client from tg.session (max 3 times)
	while ($true)
	{
		$Client = [WTelegram.Client]::new($api_id, $api_hash, "$PSScriptRoot\tg.session")

		try
		{
			$Need = $Client.Login($Phone).GetAwaiter().GetResult()
			while ($Need)
			{
				if ($Need -eq "password")
				{
					$Value = Read-Host -Prompt $Need -MaskInput
				}
				else
				{
					$Value = Read-Host -Prompt $Need
				}
				$Need = $Client.Login($Value).GetAwaiter().GetResult()
			}
			break
		}
		catch
		{
			$Attempt++
			if ((-not $_.Exception.GetBaseException().Message.Contains("Connection shut down")) -or ($Attempt -ge 3))
			{
				throw
			}

			Write-Warning -Message "Connection dropped. Reconnecting with a new client"
			$Client.Dispose()
		}
	}

	# Find group by username
	$Resolved   = [TL.SchemaExtensions]::Contacts_ResolveUsername($Client, $Username, $null).GetAwaiter().GetResult()
	$Chat       = $Resolved.Chat
	$ChannelId  = $Resolved.peer.channel_id
	$AccessHash = Get-Field -Object $Chat -Name access_hash
	$Peer       = [TL.InputPeerChannel]::new($ChannelId, $AccessHash)

	# Unpin all messages in one request. Repeat while server reports a non-zero offset
	do
	{
		$Affected = [TL.SchemaExtensions]::Messages_UnpinAllMessages($Client, $Peer).GetAwaiter().GetResult()
		$Offset   = Get-Field -Object $Affected -Name offset
	}
	while ($Offset -gt 0)
	Write-Verbose -Message "All messages unpinned" -Verbose

	# Pin message back without notification: silent = $true, unpin = $false, pm_oneside = $false
	$null = [TL.SchemaExtensions]::Messages_UpdatePinnedMessage($Client, $Peer, $KeepId, $true, $false, $false).GetAwaiter().GetResult()
	Write-Verbose -Message "Pinned $KeepId back" -Verbose
}
finally
{
	if ($Client)
	{
		$Client.Dispose()
	}
}
