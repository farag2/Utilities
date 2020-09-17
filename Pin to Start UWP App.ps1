# Make any UWP app run as Administrator by default and pin it to Start menu
# Run the script after every app update
# Запускать UWP-приложение от имени администратора по умолчанию и закрепить на начальном экране
# Запускайте скрипт после каждого обновления приложения
# Inspired by https://lennybacon.com/posts/create-a-link-to-a-UWP-app-to-run-as-administrator/

Clear-Host

$appname = 

Remove-Item -Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\$appname.lnk" -Force -ErrorAction Ignore
Stop-Process -Name StartMenuExperienceHost -Force

$shell = New-Object -ComObject Wscript.Shell
$shortcut = $shell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\$appname.lnk")
$appnameAppID = (Get-StartApps | Where-Object -FilterScript {$_.Name -eq "$appname"}).AppID[-1]
$Shortcut.TargetPath = "shell:AppsFolder\$appnameAppID"
$Shortcut.Save()

# Run upcoming the $appname shortcut as Administrator
# Запускать будущий ярлык $appname от имени Администратора
[byte[]]$bytes = Get-Content -Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\$appname.lnk" -Encoding Byte -Raw
$bytes[0x15] = $bytes[0x15] -bor 0x20
Set-Content -Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\$appname.lnk" -Value $bytes -Encoding Byte -Force

$DesktopFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name Desktop
$Target = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\$appname.lnk"
$PackageFullName = (Get-AppxPackage -Name $appname).PackageFullName

$Shell = New-Object -ComObject Wscript.Shell
$Shortcut = $Shell.CreateShortcut("$DesktopFolder\$appname.lnk")
$Shortcut.TargetPath = "cmd.exe"
$ShortCut.Arguments = "/c `"$Target`""
$ShortCut.IconLocation = "$env:ProgramFiles\WindowsApps\$PackageFullName\$appname.exe"
# Start cmd window minimized
# Запускать окно cmd свернутым
$Shortcut.WindowStyle = 7
$Shortcut.Save()

# Pin the second shortcut to Start
# Закрепить второй ярлык на начальном экране
# Download syspin.exe to the "Downloads" folder
# Скачать syspin.exe в папку "Загрузки"
# http://www.technosys.net/products/utils/pintotaskbar
# SHA256: 6967E7A3C2251812DD6B3FA0265FB7B61AADC568F562A98C50C345908C6E827
if (Test-Connection -ComputerName google.com -Quiet)
{
	$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	$Parameters = @{
		Uri = "https://github.com/farag2/Windows-10-Setup-Script/raw/master/Start%20menu%20pinning/syspin.exe"
		OutFile = "$DownloadsFolder\syspin.exe"
		Verbose = [switch]::Present
	}
	Invoke-WebRequest @Parameters
}
else
{
	Write-Warning -Message "No internet connection"
	Remove-Item -Path "$DesktopFolder\Windows Terminal.lnk" -Force
	break
}
Write-Verbose -Message "The `"$appname`" shortcut is being pinned to Start" -Verbose
$Arguments = @"
	"$DesktopFolder\$appname.lnk" "51201"
"@
Start-Process -FilePath "$DownloadsFolder\syspin.exe" -WindowStyle Hidden -ArgumentList $Arguments -Wait

Remove-Item -Path "$DownloadsFolder\syspin.exe" -Force
Remove-Item -Path "$DesktopFolder\$appname.lnk" -Force

# Restart the Start menu
# Перезапустить меню "Пуск"
Stop-Process -Name StartMenuExperienceHost -Force
