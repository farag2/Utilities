# https://yandex.ru/dev/disk/poligon/
# https://id.yandex.ru/personal/data-access
# https://github.com/rclone/rclone/releases/latest

function YandexDiskRescue
{
	[CmdletBinding()]
	param
	(
		[string]
		$Destination,

		[string]
		$Source,

		[string]
		$rclone
	)

	Clear-Host

	$Global:LASTEXITCODE = 0
	$rcloneFolder = Split-Path -Path $rclone -Parent
	$token        = ""
	$conf         = "$rcloneFolder\rclone.conf"

	$json = [ordered]@{
		access_token  = $token
		token_type    = "OAuth"
		refresh_token = "unused"
		expiry        = "2099-01-01T00:00:00Z"
	} | ConvertTo-Json -Compress

	$Parameters = @{
		Path     = $conf
		Value    = "[yandex]", "type = yandex", "token = $json"
		Encoding = "UTF8"
		Force    = $true
	}
	Set-Content @Parameters

	& $rclone about yandex:

	if ($LASTEXITCODE -ne 0)
	{
		Write-Warning -Message "Cannot connect to Yandex Disk API: check your token"
		exit
	}

	$Timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
	$LogFile   = "$rcloneFolder\yandex-rescue-$Timestamp.log"
	$rcloneLog = "$rcloneFolder\rclone-$Timestamp.log"
	$Transfers = 16

	$Arguments = @(
		"copy", $Source, $Destination,
		"--transfers", $Transfers,
		"--checkers", "8",
		"--timeout", "60s",
		"--contimeout", "15s",
		"--low-level-retries", "2",
		"--retries", "2",
		"--progress",
		"--log-file", $rcloneLog,
		"--log-level", "INFO"
	)

	& $rclone @Arguments

	$Copied = [System.Collections.Generic.HashSet[string]]::new()
	$Failed = [System.Collections.Generic.HashSet[string]]::new()

	foreach ($Line in (Get-Content -Path $rcloneLog -Encoding UTF8))
	{
		$Start = $Line.IndexOf(" : ") + 3

		if ($Line.Contains(": Copied ("))
		{
			[void]$Copied.Add($Line.Substring($Start, $Line.IndexOf(": Copied (") - $Start))
		}
		elseif ($Line.Contains(" ERROR : ") -and $Line.Contains(": Failed to copy:") -and (-not $Line.Contains(" : Attempt ")))
		{
			[void]$Failed.Add($Line.Substring($Start, $Line.IndexOf(": Failed to copy:") - $Start))
		}
	}

	$Failed.ExceptWith($Copied)

	Get-Item -Path $rcloneLog -Force | Remove-Item -Force

	$Parameters = @{
		Path     = $LogFile
		Value    = @(
			"Copied: $($Copied.Count)"
			$Copied | Sort-Object
			""
			"Failed to copy: $($Failed.Count)"
			$Failed | Sort-Object
		)
		Encoding = "UTF8"
		Force    = $true
	}
	Set-Content @Parameters

	Write-Verbose -Message "Files copied: $($Copied.Count)" -Verbose

	if ($Failed.Count -gt 0)
	{
		Write-Warning -Message "Files failed to copy: $($Failed.Count)"
	}
}
YandexDiskRescue -Source "yandex:" -Destination D:\Yandex -rclone "D:\Desktop\rclone.exe"
