$Session            = New-Object -ComObject Microsoft.Update.Session
$Searcher           = $Session.CreateUpdateSearcher()

$Searcher.ServiceID = "7971f918-a847-4430-9279-4a52d1efe18d"
# MachineOnly
$Searcher.SearchScope     =  1
# Third Party
$Searcher.ServerSelection = 3

Write-Verbose -Message "Searching Driver Updates..." -Verbose

$SearchResult = $Searcher.Search("IsInstalled=0 and Type='Driver' and IsHidden=0")
$Updates      = $SearchResult.Updates

#Show available Drivers
$Updates | Select-Object -Property Title, DriverModel, DriverVerDate, Driverclass, DriverManufacturer

#Download the Drivers from Microsoft
$UpdatesToDownload = New-Object -Com Microsoft.Update.UpdateColl
$Updates | ForEach-Object -Process {
	$UpdatesToDownload.Add($_) | Out-Null
}

Write-Verbose -Message "Downloading Drivers..." -Verbose

$UpdateSession      = New-Object -Com Microsoft.Update.Session
$Downloader         = $UpdateSession.CreateUpdateDownloader()
$Downloader.Updates = $UpdatesToDownload
$Downloader.Download()

# Check if the Drivers are all downloaded and trigger the Installation
$UpdatesToInstall = New-Object -Com Microsoft.Update.UpdateColl
$Updates | ForEach-Object -Process {
	if ($_.IsDownloaded)
	{
		$UpdatesToInstall.Add($_) | Out-Null
	}
}

Write-Verbose -Message "Installing Drivers..." -Verbose

$Installer          = $UpdateSession.CreateUpdateInstaller()
$Installer.Updates  = $UpdatesToInstall
$InstallationResult = $Installer.Install()

if ($InstallationResult.RebootRequired)
{
	Write-Verbose -Message "Reboot required" -Verbose
}
else
{
	Write-Verbose -Message "Done" -Verbose
}
