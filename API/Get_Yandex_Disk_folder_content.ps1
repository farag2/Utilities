# https://oauth.yandex.ru
# Open https://oauth.yandex.ru/authorize?response_type=token&client_id=<Your_ClientID> and obtain your Token
# https://yandex.ru/dev/disk-api/doc/ru/concepts/quickstart

# Rights needed
# cloud_api:disk.app_folder
# cloud_api:disk.read
# cloud_api:disk.info
# cloud_api:disk.write
# yadisk:disk

function Get-YandexDiskContent
{
	param
	(
		[Parameter(Mandatory = $true)]
		[string]
		$Path,

		[Parameter(Mandatory = $true)]
		[string]
		$Token
	)

	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

	# Encode folder path
	$EncodePath = [System.Uri]::EscapeDataString($Path)

	$Headers = @{
		Authorization = "OAuth $Token"
		Accept        = "application/json"
	}
	$Parameters = @{
		Uri     = "https://cloud-api.yandex.net/v1/disk/resources?path=$EncodePath&sort=name"
		Headers = $Headers
		Method  = "Get"
	}
	$Response = Invoke-RestMethod @Parameters

	$items = $response._embedded.items | ForEach-Object -Process {
		$Type = if ($_.type -eq "dir")
		{
			"Folder"
		}
		else
		{
			"File"
		}

		[PSCustomObject]@{
			Name  = $_.name
			Type  = $Type
			Path  = $_.path
		}
	}

	return $items
}

# Your token from https://oauth.yandex.ru/authorize?response_type=token&client_id=<Your_ClientID> page
$Token = ""
# disk:/folder
Get-YandexDiskContent -Path "disk:/folder" -Token $Token | Format-Table -AutoSize
