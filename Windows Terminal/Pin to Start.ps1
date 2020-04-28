# Make Windows Terminal run as Administrator by default and pin it to Start
# Make any UWP app run as Administrator by default
# Запускать Windows Terminal от имени администратора по умолчанию и закрепить на начальном экране 
# Inspired by https://lennybacon.com/post/Create-a-link-to-a-UWP-app-to-run-as-administrator

Clear-Host
$Error.Clear()

Remove-Item -Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\Windows Terminal.lnk" -Force -ErrorAction Ignore
Start-Sleep -Seconds 3

$shell = New-Object -ComObject Wscript.Shell
$shortcut = $shell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\Windows Terminal.lnk")
$Shortcut.TargetPath = "shell:AppsFolder\Microsoft.WindowsTerminal_8wekyb3d8bbwe!App"
$Shortcut.Save()

# Run upcoming the Windows Terminal shortcut as Administrator
# Запускать будущий ярлык Windows Terminal от имени Администратора
[byte[]]$bytes = Get-Content -Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\Windows Terminal.lnk" -Encoding Byte -Raw
$bytes[0x15] = $bytes[0x15] -bor 0x20
Set-Content -Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\Windows Terminal.lnk" -Value $bytes -Encoding Byte -Force

$DesktopFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name Desktop
$PackageFullName = (Get-AppxPackage -Name Microsoft.WindowsTerminal).PackageFullName
$Target = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\Windows Terminal.lnk"

$shell = New-Object -ComObject Wscript.Shell
$shortcut = $shell.CreateShortcut("$DesktopFolder\Windows Terminal.lnk")
$Shortcut.TargetPath = "cmd.exe"
$shortCut.Arguments = "/c `"$Target`""
$shortCut.IconLocation = "$env:ProgramFiles\WindowsApps\$PackageFullName\WindowsTerminal.exe"
# Start cmd window minimized
# Запускать окно cmd свернутым
$Shortcut.WindowStyle = 7
$Shortcut.Save()

# Pin the second shortcut to Start
# Закрепить второй ярлык на нчальном экране
# Download syspin.exe to the "Downloads" folder
# Скачать syspin.exe в папку "Загрузки"
# http://www.technosys.net/products/utils/pintotaskbar
# SHA256: 6967E7A3C2251812DD6B3FA0265FB7B61AADC568F562A98C50C345908C6E827
if (Test-Connection -ComputerName google.com -Quiet)
{
	$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	$param = @{
		Uri = "https://github.com/farag2/Windows-10-Setup-Script/raw/master/Start%20menu%20pinning/syspin.exe"
		OutFile = "$DownloadsFolder\syspin.exe"
		Verbose = [switch]::Present
	}
	Invoke-WebRequest @param
}
Write-Verbose -Message "The `"Windows Terminal`" shortcut is being pinned to Start" -Verbose
$Arguments = @"
	"$DesktopFolder\Windows Terminal.lnk" "51201"
"@
Start-Process -FilePath "$DownloadsFolder\syspin.exe" -WindowStyle Hidden -ArgumentList $Arguments -Wait

Remove-Item -Path "$DownloadsFolder\syspin.exe" -Force
Remove-Item -Path "$DesktopFolder\Windows Terminal.lnk" -Force

# Restart the Start menu
# Перезапустить меню "Пуск"
Stop-Process -Name StartMenuExperienceHost -Force