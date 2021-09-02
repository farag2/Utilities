<#
	.SYNOPSIS
	Download videos from YoutTube via youtube-dl

	.EXAMPLE
	$youtubedlPath = "D:\Downloads\youtube-dl.exe"
	youtube-dl -URLs @()

	.NOTES
	"D:\youtube-dl.exe" --list-formats url
	Get video & audio indexes: --format 43+35 url
	--username $username
	--password $password
	--video-password $videopassword

	.LINKS
	https://github.com/ytdl-org/youtube-dl/releases
	https://github.com/BtbN/FFmpeg-Builds
#>
funtion youtube-dl
{
	[CmdletBinding()]
	param
	(
		[string[]]
		$URLs
	)

	$OutputFolder = Split-Path -Path $youtubedlPath -Parent
	$Title = "%(title)s.mp4"

	$n = 1
	foreach ($URL in $URLs)
	{
		# 1. FileName.mp4
		$FileName = "{0}. {1}" -f $n++, $Title

		Start-Process -FilePath $youtubedlPath -ArgumentList "--output `"$OutputFolder\$FileName`" --format 136+251 $url"
	}
}
