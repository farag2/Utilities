<#
	.SYNOPSIS
	The "Show menu" function with the up/down arrow keys and enter key to make a selection

	.PARAMETER Menu
	Array of items to choose from

	.PARAMETER Default
	Default selected item in array

	.PARAMETER AddSkip
	Add localized extracted "Skip" string from shell32.dll

	.EXAMPLE
	Show-Menu -Menu @($Item1, $Item2) -Default 1

	.LINK
	https://qna.habr.com/answer?answer_id=1522379
	https://github.com/ryandunton/InteractivePSMenu
#>
function Show-Menu
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[array]
		$Menu,

		[Parameter(Mandatory = $true)]
		[int]
		$Default,

		[Parameter(Mandatory = $false)]
		[switch]
		$AddSkip
	)

	Write-Information -MessageData "" -InformationAction Continue

	$i = 0
	while ($i -lt $Menu.Count)
	{
		$i++
		Write-Host -Object ""
	}

	$SelectedValueIndex = [Math]::Max([Math]::Min($Default, $Menu.Count), 0)

	do
	{
		[Console]::SetCursorPosition(0, [Console]::CursorTop - $Menu.Count)

		for ($i = 0; $i -lt $Menu.Count; $i++)
		{
			if ($i -eq $SelectedValueIndex)
			{
				Write-Host -Object "[>] $($Menu[$i])" -NoNewline
			}
			else
			{
				Write-Host -Object "[ ] $($Menu[$i])" -NoNewline
			}

			Write-Host -Object ""
		}

		$Key = [Console]::ReadKey()
		switch ($Key.Key)
		{
			"UpArrow"
			{
				$SelectedValueIndex = [Math]::Max(0, $SelectedValueIndex - 1)
			}
			"DownArrow"
			{
				$SelectedValueIndex = [Math]::Min($Menu.Count - 1, $SelectedValueIndex + 1)
			}
			"Enter"
			{
				return $Menu[$SelectedValueIndex]
			}
		}
	}
	while ($Key.Key -notin ([ConsoleKey]::Escape, [ConsoleKey]::Enter))
}

<#
	.PARAMETER Path
	Path to Yandex Disk folder to rename files

	.PARAMETER Token
	Yandex Disk token

	.PARAMETER PartNumber
	PartNumber to rename files into

	.PARAMETER ExcelExportedFile
	Set Excel file to export

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
		$PartNumber,

		[Parameter(Mandatory = $true)]
		[string]
		$ExcelToExportFile
	)

	# Checking if exported file is opened already
	if (Get-CimInstance -ClassName CIM_Process | Where-Object -FilterScript {$_.Name -eq "Excel.exe"} | Where-Object -FilterScript {$_.CommandLine -match $ExcelToExportFile})
	{
		Write-Warning -Message "Please close $($ExcelToExportFile.Replace('\\', '\')) and try again"
		pause
		exit
	}

	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

	# Encode folder path
	$EncodePath = [System.Uri]::EscapeDataString($Path)

	try
	{
		$Headers = @{
			Authorization = "OAuth $Token"
			Accept        = "application/json"
		}
		$Parameters = @{
			Uri     = "https://cloud-api.yandex.net/v1/disk/resources?path=$EncodePath&sort=name"
			Headers = $Headers
			Method  = "Get"
		}
		$ListContentResponse = Invoke-RestMethod @Parameters
	}
	catch
	{
		Write-Warning -Message "Cannot connect to Yandex Disk via API. Check your connection settings"
		pause
		exit
	}

	Write-Warning -Message ("Please use the arrow keys {0} and {1} on your keyboard to select your answer" -f [System.Char]::ConvertFromUtf32(0x2191), [System.Char]::ConvertFromUtf32(0x2193))
	Write-Host -Object "Folder: $Path" -ForegroundColor Green
	Write-Host -Object "Part number: $PartNumber" -ForegroundColor Green
	Write-Host -Object "An Excel file to export: $($ExcelToExportFile.Replace('\\', '\'))" -ForegroundColor Green
	Write-Host -Object "Continue?" -ForegroundColor Red

	$Choice = Show-Menu -Menu @("Yes", "No") -Default 1
	switch ($Choice)
	{
		"Yes"
		{
			continue
		}
		"No"
		{
			exit
		}
	}

	$i = 1

	# List files in folder
	$Files = $ListContentResponse._embedded.items | Where-Object -FilterScript {$_.type -eq "file"}
	foreach ($File in $Files)
	{
		$OriginalName = $File.name
		# Get file extension. We can use a .NET class only as Get-Item cmdlet meant to be used in NTFS file system
		$FileExtension = [System.IO.Path]::GetExtension($OriginalName)
		# pattern_1.extension, pattern_2.extension
		$NewName = "$($PartNumber)_$i$($FileExtension)"

		# Encode folder path
		$OldFullName = [System.Uri]::EscapeDataString("$Path/$OriginalName")
		$NewFullName = [System.Uri]::EscapeDataString("$Path/$NewName")

		if ($OldFullName -ne $NewFullName)
		{
			# Rename files
			$Parameters = @{
				Uri     = "https://cloud-api.yandex.net/v1/disk/resources/move?from=$OldFullName&path=$NewFullName&overwrite=true"
				Headers = $Headers
				Method  = "Post"
			}
			Invoke-RestMethod @Parameters | Out-Null

			Write-Host -Object "$OriginalName ➔ $NewName" -ForegroundColor Green
		}
		else
		{
			Write-Host -Object "$OriginalName is already equal to $NewName" -ForegroundColor Red
		}

		$i++
	}

	# Create public link to a specified folder
	# We use $Headers from the previous step
	$Parameters = @{
		Uri     = "https://cloud-api.yandex.net/v1/disk/resources/publish?path=$EncodePath"
		Headers = $Headers
		Method  = "Put"
	}
	$PublicLinkResponse = Invoke-RestMethod @Parameters

	# We use $Headers from the previous step
	$Parameters = @{
		Uri     = $PublicLinkResponse.href
		Headers = $Headers
	}
	# The end URL
	$URL = (Invoke-RestMethod @Parameters).public_url

	Write-Host -Object "Public URL for $Path folder is now $URL" -ForegroundColor Green

	# List folder files after renaming to get the first file name
	# We use $Headers from the previous step
	$Parameters = @{
		Uri     = "https://cloud-api.yandex.net/v1/disk/resources?path=$EncodePath&sort=name"
		Headers = $Headers
		Method  = "Get"
	}
	$ListContentResponseAfterRenaming = Invoke-RestMethod @Parameters

	[PSCustomObject]@{
		"Папка"            = $Path
		"Публичная ссылка" = $URL
		"Дата"             = $(Get-Date -Format "dd.MM.yyyy")
		# Choosing file name
		"Первое имя файла" = $(($ListContentResponseAfterRenaming._embedded.items | Where-Object -FilterScript {$_.type -eq "file"}).name | Select-Object -First 1)
	} | Select-Object -Property * | Export-Csv -Path $ExcelToExportFile -Encoding UTF8 -NoTypeInformation -Delimiter ";" -Append
}
$Parameters = @{
	Path              = "disk:/111"
	Token             = ""
	PartNumber        = ""
	# Use "\\" instead of "\"
	ExcelToExportFile = "D:\\1.csv"
}
Rename-YandexDiskFiles @Parameters



# https://seller.ozon.ru/app/settings/api-keys
$Headers = @{
	"Client-Id"    = ""
	"Api-Key"      = ""
	"Content-Type" = "application/json"
}
$Body = @{
	filter = @{
		visibility = "ALL" # ALL, VISIBLE, INVISIBLE, EMPTY_STOCK
	}
	last_id = ""
	limit = 1000
}
$Parameters = @{
	Uri     = "https://api-seller.ozon.ru/v3/product/list"
	Headers = $Headers
	Method  = "Post"
	# We need to explicitly convert the body to JSON
	Body    = $Body | ConvertTo-Json
}
$Response = Invoke-RestMethod @Parameters
$Response.result.items
