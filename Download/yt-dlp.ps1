<#
	.SYNOPSIS
	Download videos from YoutTube via yt-dlp

	.EXAMPLE
	youtube-dl -URLs @()

	.NOTES
	Invoke "D:\yt-dlp.exe" --list-formats URL

	.NOTES
	--username $username
	--password $password
	--video-password $videopassword

	.LINKS
	https://github.com/yt-dlp/yt-dlp
	https://github.com/BtbN/FFmpeg-Builds
#>
function yt-dlp
{
	[CmdletBinding()]
	param
	(
		[string[]]
		$URLs
	)

	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	
	if ($Host.Version.Major -eq 5)
	{
		# Progress bar can significantly impact cmdlet performance
		# https://github.com/PowerShell/PowerShell/issues/2138
		$Script:ProgressPreference = "SilentlyContinue"
	}

	# https://github.com/yt-dlp/yt-dlp
	# Get the latest youtube-dl build tag
	$Parameters = @{
		Uri              = "https://api.github.com/repos/yt-dlp/yt-dlp/releases/latest"
		UseBasicParsing  = $true
	}
	$LatestytdlplRelease = (Invoke-RestMethod @Parameters).tag_name

	$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
	if (-not (Test-Path -Path "$DownloadsFolder\yt-dlp.exe"))
	{
		$Parameters = @{
			Uri              = "https://github.com/yt-dlp/yt-dlp/releases/download/$LatestytdlplRelease/yt-dlp.exe"
			OutFile          = "$DownloadsFolder\yt-dlp.exe"
			UseBasicParsing  = $true
			Verbose          = $true
		}
		Invoke-WebRequest @Parameters
	}

	# Get the latest FFmpeg URL
 	# https://github.com/BtbN/FFmpeg-Builds
	# "ffmpeg-*-win64-lgpl-[0-9].[0-9].zip"
	# gpl includes all dependencies, even those that require full GPL instead of just LGPL
	$Parameters = @{
		Uri              = "https://api.github.com/repos/BtbN/FFmpeg-Builds/releases/latest"
		UseBasicParsing  = $true
	}
	$LatestFFmpegURL = ((Invoke-RestMethod @Parameters).assets | Where-Object -FilterScript {$_.name -eq "ffmpeg-master-latest-win64-lgpl.zip"}).browser_download_url

	if (-not (Test-Path -Path "$DownloadsFolder\ffmpeg.exe"))
	{
		$Parameters = @{
			Uri              = $LatestFFmpegURL
			OutFile          = "$DownloadsFolder\FFmpeg.zip"
			UseBasicParsing  = $true
			Verbose          = $true
		}
		Invoke-WebRequest @Parameters

		# Expand ffmpeg.exe from the ZIP archive
		Add-Type -Assembly System.IO.Compression.FileSystem

		$ZIP = [IO.Compression.ZipFile]::OpenRead("$DownloadsFolder\FFmpeg.zip")
		$Entries = $ZIP.Entries | Where-Object -FilterScript {$_.FullName -like "ffmpeg*/bin/ffmpeg.exe"}
		$Entries | ForEach-Object -Process {[IO.Compression.ZipFileExtensions]::ExtractToFile($_, "$DownloadsFolder\ffmpeg.exe", $true)}
		$ZIP.Dispose()

		Remove-Item -Path "$DownloadsFolder\FFmpeg.zip" -Force
	}

	$Title = "%(title)s.mp4"
	$n = 1

	foreach ($URL in $URLs)
	{
		# Getting URL's IDs
		# https://www.reddit.com/r/youtubedl/comments/fzv58p/comment/fn6hass/?context=3
		& "$DownloadsFolder\yt-dlp.exe" --list-formats $URL
		$VideoID = Read-Host -Prompt "`nType prefered video ID"
		$AudioID = Read-Host -Prompt "`nType prefered audio ID"

		# 1. FileName.mp4
		$FileName = "{0}. {1}" -f $n++, $Title

		Start-Process -FilePath "$DownloadsFolder\yt-dlp.exe" -ArgumentList "--output `"$DownloadsFolder\$FileName`" --format `"$($VideoID)+$($AudioID)`" $URL"
	}
}
yt-dlp -URLs @("https://www.youtube.com/watch?v=DqTEVmed0Bc")
