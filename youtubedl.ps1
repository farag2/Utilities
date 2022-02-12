<#
	.SYNOPSIS
	Download videos from YoutTube via youtube-dl

	.EXAMPLE
	youtube-dl -Path "D:\youtube-dl.exe" -URLs @() -Format "22+251"

	.NOTES
	Invoke "D:\youtube-dl.exe" --list-formats URL

	.NOTES
	--username $username
	--password $password
	--video-password $videopassword

	.LINKS
	https://github.com/ytdl-org/youtube-dl
	https://github.com/BtbN/FFmpeg-Builds
#>
function youtube-dl
{
	[CmdletBinding()]
	param
	(
		[string]
		$Path,

		[string[]]
		$URLs,

		[string]
		$Format
	)

	# Get the latest youtube-dl build tag
	$Parameters = @{
		Uri              = "https://api.github.com/repos/ytdl-org/youtube-dl/releases/latest"
		UseBasicParsing  = $true
	}
	$LatestyoutubedlRelease = (Invoke-RestMethod @Parameters).tag_name

	$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"

	$Parameters = @{
		Uri              = "https://github.com/ytdl-org/youtube-dl/releases/download/$LatestyoutubedlRelease/youtube-dl.exe"
		OutFile          = "$DownloadsFolder\youtube-dl.exe"
		UseBasicParsing  = $true
		Verbose          = $true
	}
	Invoke-WebRequest @Parameters

	# Get the latest FFmpeg URL
    # "ffmpeg-*-win64-lgpl-[0-9].[0-9].zip"
	$Parameters = @{
		Uri              = "https://api.github.com/repos/BtbN/FFmpeg-Builds/releases/latest"
		UseBasicParsing  = $true
	}
	$LatestFFmpegURL = ((Invoke-RestMethod @Parameters).assets | Where-Object -FilterScript {$_.name -match "ffmpeg-n5.0-latest-win64-gpl-5.0.zip"}).browser_download_url
	$Parameters = @{
		Uri              = $LatestFFmpegURL
		OutFile          = "$DownloadsFolder\FFmpeg.zip"
		UseBasicParsing  = $true
		Verbose          = $true
	}
	Invoke-WebRequest @Parameters

	# Expand ffmpeg.exe from the ZIP archive
	Add-Type -Assembly System.IO.Compression.FileSystem

	$ZIP = [IO.Compression.ZipFile]::OpenRead("D:\Downloads\FFmpeg.zip")
	$Entries = $ZIP.Entries | Where-Object -FilterScript {$_.FullName -like "ffmpeg*/bin/ffmpeg.exe"}
	$Entries | ForEach-Object -Process {[IO.Compression.ZipFileExtensions]::ExtractToFile($_, "$DownloadsFolder\ffmpeg.exe", $true)}
	$ZIP.Dispose()

	Remove-Item -Path "$DownloadsFolder\FFmpeg.zip" -Force

	$OutputFolder = Split-Path -Path $Path -Parent
	$Title = "%(title)s.mp4"

	$n = 1
	foreach ($URL in $URLs)
	{
		# 1. FileName.mp4
		$FileName = "{0}. {1}" -f $n++, $Title

		Start-Process -FilePath $Path -ArgumentList "--output `"$OutputFolder\$FileName`" --format $Format $URL"
	}
}
youtube-dl -Path "D:\Downloads\youtube-dl.exe" -URLs @("https://youtu.be/qDHBoSJe5X0") -Format "248+140"
