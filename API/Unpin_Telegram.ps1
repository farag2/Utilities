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

$Client = [WTelegram.Client]::new($api_id, $api_hash, "$PSScriptRoot\tg.session")

try
{
	# Telegram temp code + MFA
	$Need = $Client.Login($Phone).GetAwaiter().GetResult()
	while ($Need)
	{
		$Need = $Client.Login((Read-Host -Prompt $Need)).GetAwaiter().GetResult()
	}

	# Find group by username
	$Resolved   = [TL.SchemaExtensions]::Contacts_ResolveUsername($Client, $Username, $null).GetAwaiter().GetResult()
	$Chat       = $Resolved.Chat
	$ChannelId  = $Resolved.peer.channel_id
	$AccessHash = Get-Field -Object $Chat -Name access_hash
	$Peer       = [TL.InputPeerChannel]::new($ChannelId, $AccessHash)

    # Collect all IDs of pinned messages by 100 items per a request
    $Filter   = [TL.InputMessagesFilterPinned]::new()
    $NoDate   = [datetime]::new(0)
    $PinnedIds = [System.Collections.Generic.List[int]]::new()
    $OffsetId = 0

    while ($true)
    {
        # peer, q, filter, min_date, max_date, offset_id, add_offset, limit, max_id, min_id, hash
        $Page = [TL.SchemaExtensions]::Messages_Search($Client, $Peer, "", $Filter, $NoDate, $NoDate, $OffsetId, 0, 100, 0, 0, 0).GetAwaiter().GetResult()
        $Messages = Get-Field -Object $Page -Name messages
        if (-not $Messages)
        {
            break
        }

        foreach ($Message in $Messages)
        {
            $PinnedIds.Add((Get-Field -Object $Message -Name id))
        }
        $OffsetId = ($PinnedIds | Measure-Object -Minimum).Minimum
    }

    $ToUnpin = $PinnedIds | Where-Object -FilterScript {$_ -ne $KeepId}

    # Unpin one be one: silent = $false, unpin = $true, pm_oneside = $false
    $i = 0
    foreach ($Id in $ToUnpin)
    {
        $i++
        while ($true)
        {
            try
            {
                $null = [TL.SchemaExtensions]::Messages_UpdatePinnedMessage($Client, $Peer, $Id, $false, $true, $false).GetAwaiter().GetResult()
                break
            }
            catch
            {
                # If FLOOD_WAIT, wait for X seconds anre retry
                $RpcException = $_.Exception.GetBaseException()
                if ($RpcException.Message -match "FLOOD_WAIT")
                {
                    $Seconds = [int]$RpcException.X + 1
                    Write-Host -Object "Waiting for $Seconds seconds"
                    Start-Sleep -Seconds $Seconds
                }
                else
                {
                    throw
                }
            }
        }
    }
}
finally
{
    $Client.Dispose()
}
