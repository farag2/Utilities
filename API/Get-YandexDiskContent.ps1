<#
	.PARAMETER Path
	Path to Yandex Disk folder to rename files

	.PARAMETER Token
	Yandex Disk token

	.EXAMPLE
	Get-YandexDiskContent -Path disk:/folder -Token your_token

	.ACCESS LEVEL
	cloud_api:disk.app_folder
	cloud_api:disk.read
	cloud_api:disk.info
	cloud_api:disk.write
	yadisk:disk

	.NOTES
	disk:/folder

	.LINK
	https://oauth.yandex.ru
	https://oauth.yandex.ru/verification_code
	https://oauth.yandex.ru/authorize?response_type=token&client_id=<clientid>
	https://oauth.yandex.ru/client/new/
	https://yandex.ru/dev/disk-api/doc/ru/concepts/quickstart
#>
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
	# We need to that only if path has HTML encoded characters. If path is clean, $EncodePath should not be used, and "Uri" property has to use $Path string
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

	$Response._embedded.items | Where-Object -FilterScript {$_.media_type -eq "image"} | ForEach-Object -Process {
		$Type = if ($_.type -eq "dir") {"Folder"} else {"File"}

		[PSCustomObject]@{
			Name = $_.name
			Type = $Type
			Path = $_.path
		}
	}
}

$Parameters = @{
	# Use here clean URL path (without URL encoded characters) by default, unless $EncodePath will fail to decode it, and vice versa
	Path  = "disk:/folder"
	# Your token from https://oauth.yandex.ru/authorize?response_type=token&client_id=<Your_ClientID> page
	Token = ""
}
Get-YandexDiskContent @Parameters | Format-Table -AutoSize
