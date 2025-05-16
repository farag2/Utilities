#Requires -RunAsAdministrator
#Requires -Version 5.1

$Updates = @()

$Session = New-Object -ComObject Microsoft.Update.Session
$Searcher = $Session.CreateUpdateSearcher()
$Searcher.ServiceID = "7971f918-a847-4430-9279-4a52d1efe18d"

Write-Verbose -Message "Searching Driver Updates..." -Verbose

$SearchResult = $Searcher.Search("IsInstalled=0 and Type='Driver' and IsHidden=0")
$Updates = $SearchResult.Updates

if ($Updates.Count -gt 0)
{
	$Updates | Select-Object -Property Title, DriverModel, DriverVerDate, Driverclass, DriverManufacturer
}
else
{
	Write-Verbose -Message "No updates available" -Verbose
	exit
}

$Updates | ForEach-Object -Process {$_.AcceptEula()}

Write-Verbose -Message "Downloading Drivers..." -Verbose

$UpdateToDownload = New-Object -ComObject Microsoft.Update.UpdateColl
$Updates | ForEach-Object -Process {
	$UpdateToDownload.Add($_) | Out-Null
}

$Downloader = $Session.CreateUpdateDownloader()
$Downloader.Updates = $UpdateToDownload
$Downloader.Download()

# Check if drivers were downloaded and trigger installation
$UpdatesToInstall = New-Object -ComObject Microsoft.Update.UpdateColl
$Updates | ForEach-Object -Process {
	if ($_.IsDownloaded)
	{
		$UpdatesToInstall.Add($_) | Out-Null
	}
}

Write-Verbose -Message "Installing Drivers..." -Verbose

$Installer = $Session.CreateUpdateInstaller()
$Installer.Updates = $UpdatesToInstall
$InstallationResult = $Installer.Install()

if ($InstallationResult.RebootRequired)
{
	Write-Verbose -Message "Reboot required" -Verbose
}
else
{
	Write-Verbose -Message "Done" -Verbose
}
