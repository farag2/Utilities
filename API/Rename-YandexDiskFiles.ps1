<#
	.PARAMETER Path
	Path to Yandex Disk folder to rename files

	.PARAMETER Token
	Yandex Disk token

	.PARAMETER PartNumber
	PartNumber to rename files into

	.EXAMPLE
	Rename-YandexDiskFiles -Path disk:/folder -Token your_token -PartNumber C244003

	.OUTPUT
	All files in folder will be renamed into pattern_1, pattern_2, etc.

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
function Rename-YandexDiskFiles
{
	param
	(
		[Parameter(Mandatory = $true)]
		[string]
		$Path,

		[Parameter(Mandatory = $true)]
		[string]
		$Token,

		[Parameter(Mandatory = $true)]
		[string]
		$PartNumber
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

	Write-Host -Object $Path -ForegroundColor Green
	Write-Host -Object ""

	$i = 1

	# List files in folder
	$Files = $Response._embedded.items | Where-Object -FilterScript {$_.type -eq "file"}
	foreach ($File in $Files)
	{
		$OriginalName = $file.name
		# Get file extension. We can use a .NET class only as Get-Item cmdlet meant to be used in NTFS file system
		$FileExtension = [System.IO.Path]::GetExtension($OriginalName)
		# pattern_1.extension, pattern_2.extension
		$NewName = "$($PartNumber)_$i$($FileExtension)"

		# Encode folder path
		$OldFullName = [System.Uri]::EscapeDataString("$Path/$OriginalName")
		$NewFullName = [System.Uri]::EscapeDataString("$Path/$NewName")

		if ($OldFullName -ne $NewFullName)
		{
			$Parameters = @{
				Uri     = "https://cloud-api.yandex.net/v1/disk/resources/move?from=$OldFullName&path=$NewFullName&overwrite=true"
				Headers = $Headers
				Method  = "Post"
			}
			# Rename files
			$Response = Invoke-RestMethod @Parameters

			Write-Host -Object "$OriginalName ➔ $NewName" -ForegroundColor Green
		}
		else
		{
			Write-Host -Object "$OriginalName is already equal to $NewName" -ForegroundColor Red
		}

		$i++
	}
}
$Parameters = @{
	Path       = "disk:/folder"
 	# Your token from https://oauth.yandex.ru/authorize?response_type=token&client_id=<Your_ClientID> page
	Token      = ""
	PartNumber = "Pattern"
}
Rename-YandexDiskFiles @Parameters
