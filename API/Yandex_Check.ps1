$rclone = "D:\Desktop\rclone.exe"
$rcloneFolder = Split-Path -Path $rclone -Parent
$Timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"

$Arguments = @(
	"check", "yandex:", "D:\Yandex",
	"--checkers", "8",
	"--combined", "$rcloneFolder\check-combined-$Timestamp.txt",
	"--missing-on-dst", "$rcloneFolder\check-missing-local-$Timestamp.txt",
	"--missing-on-src", "$rcloneFolder\check-extra-local-$Timestamp.txt",
	"--differ", "$rcloneFolder\check-differ-$Timestamp.txt",
	"--error", "$rcloneFolder\check-error-$Timestamp.txt",
	"--log-file", "$rcloneFolder\check-$Timestamp.log",
	"--log-level", "NOTICE",
	"--progress"
)
& $rclone @Arguments

if ($LASTEXITCODE -eq 0)
{
	Write-Verbose -Message "All files match" -Verbose
}
else
{
	Write-Warning -Message "Differences found: see check-*.txt files"
}