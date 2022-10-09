<#
	.SYNOPSIS
	Download videos from YoutTube via yt-dlp

	.EXAMPLE
	youtube-dl -Path "D:\yt-dlp.exe" -URLs @() -Format "22+251"

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
		[string]
		$Path,

		[string[]]
		$URLs,

		[string]
		$Format
	)

	# Get the latest youtube-dl build tag
	$Parameters = @{
		Uri              = "https://api.github.com/repos/yt-dlp/yt-dlp/releases/latest"
		UseBasicParsing  = $true
	}
	$LatestytdlplRelease = (Invoke-RestMethod @Parameters).tag_name

	$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"

	$Parameters = @{
		Uri              = "https://github.com/yt-dlp/yt-dlp/releases/download/$LatestytdlplRelease/yt-dlp.exe"
		OutFile          = "$DownloadsFolder\yt-dlp.exe"
		UseBasicParsing  = $true
		Verbose          = $true
	}
	Invoke-WebRequest @Parameters

	# Get the latest FFmpeg URL
	# "ffmpeg-*-win64-lgpl-[0-9].[0-9].zip"
	# gpl includes all dependencies, even those that require full GPL instead of just LGPL
	$Parameters = @{
		Uri              = "https://api.github.com/repos/BtbN/FFmpeg-Builds/releases/latest"
		UseBasicParsing  = $true
	}
	$LatestFFmpegURL = ((Invoke-RestMethod @Parameters).assets | Where-Object -FilterScript {$_.name -match "ffmpeg-n5.1-latest-win64-gpl-5.1.zip"}).browser_download_url
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
# Run first to get URL's IDs to use
& "D:\Downloads\yt-dlp.exe" --list-formats "https://www.youtube.com/watch?v=DqTEVmed0Bc"

# Uncomment and run next when you got on the previous step URL's IDs
# yt-dlp -Path "D:\Downloads\yt-dlp.exe" -URLs @("https://www.youtube.com/watch?v=DqTEVmed0Bc") -Format "248+140"

