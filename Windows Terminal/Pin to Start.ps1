# Make Windows Terminal run as Administrator by default and pin it to Start
# Run the script after every Windows Terminal update
# Запускать Windows Terminal от имени администратора по умолчанию и закрепить на начальном экране
# Запускайте скрипт после каждого обновления Windows Terminal

Clear-Host

# Restart the Start menu
# Перезапустить меню "Пуск"
Stop-Process -Name StartMenuExperienceHost -Force

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
	break
}

Remove-Item -Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Windows Terminal*.lnk" -Force

$PackageFullName = (Get-AppxPackage -Name Microsoft.WindowsTerminal).PackageFullName

$Shell = New-Object -ComObject Wscript.Shell
$Shortcut = $Shell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\Windows Terminal.lnk")
$Shortcut.TargetPath = "powershell.exe"
$ShortCut.Arguments = "-WindowStyle Hidden -Command wt"
$ShortCut.IconLocation = "$env:ProgramFiles\WindowsApps\$PackageFullName\WindowsTerminal.exe"
$Shortcut.Save()

# Run the Windows Terminal shortcut as Administrator
# Запускать ярлык Windows Terminal от имени Администратора
[byte[]]$bytes = Get-Content -Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\Windows Terminal.lnk" -Encoding Byte -Raw
$bytes[0x15] = $bytes[0x15] -bor 0x20
Set-Content -Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\Windows Terminal.lnk" -Value $bytes -Encoding Byte -Force


Write-Verbose -Message "The `"Windows Terminal`" shortcut is being pinned to Start" -Verbose
$Arguments = @"
	"$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\Windows Terminal.lnk" "51201"
"@
Start-Process -FilePath "$DownloadsFolder\syspin.exe" -WindowStyle Hidden -ArgumentList $Arguments -Wait

Remove-Item -Path "$DownloadsFolder\syspin.exe" -Force

# Restart the Start menu
# Перезапустить меню "Пуск"
Stop-Process -Name StartMenuExperienceHost -Force
