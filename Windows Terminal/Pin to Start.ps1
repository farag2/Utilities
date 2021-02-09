<#
	Make Windows Terminal run as Administrator by default and pin it to Start
	Run the script after every Windows Terminal update
	Запускать Windows Terminal от имени администратора по умолчанию и закрепить на начальном экране
	Запускайте скрипт после каждого обновления Windows Terminal
#>

Clear-Host

# Restart the Start menu
# Перезапустить меню "Пуск"
Stop-Process -Name StartMenuExperienceHost -Force

<#
	Pin the "Windows Terminal" shortcut to Start within syspin
	Закрепить ярлык "Windows Terminal" на начальном экране с помощью syspin

	http://www.technosys.net/products/utils/pintotaskbar
	SHA256: 6967E7A3C2251812DD6B3FA0265FB7B61AADC568F562A98C50C345908C6E827
#>
try
{
	# Downloading syspin
	# Скачиваем syspin
	if ((Invoke-WebRequest -Uri https://www.google.com -UseBasicParsing -DisableKeepAlive -Method Head).StatusDescription)
	{
		$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"

		[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
		$Parameters = @{
			Uri = "https://github.com/farag2/Windows-10-Sophia-Script/raw/master/syspin/syspin.exe"
			OutFile = "$DownloadsFolder\syspin.exe"
			Verbose = [switch]::Present
		}
		Invoke-WebRequest @Parameters
	}
}
catch
{
	if ($Error.Exception.Status -eq "NameResolutionFailure")
	{
		if ($RU)
		{
			Write-Warning -Message "Отсутствует интернет-соединение" -ErrorAction SilentlyContinue
		}
		else
		{
			Write-Warning -Message "No Internet connection" -ErrorAction SilentlyContinue
		}
		break
	}
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
