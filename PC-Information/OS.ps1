#Requires -RunAsAdministrator

#region User
Write-Verbose -Message User -Verbose
$PCName = @{
	Name       = "Computer name"
	Expression = {$_.Name}
}
$Domain = @{
	Name       = "Domain"
	Expression = {$_.Domain}
}
$UserName = @{
	Name       = "User Name"
	Expression = {$_.UserName}
}
(Get-CimInstance -ClassName CIM_ComputerSystem | Select-Object -Property $PCName, $Domain, $UserName | Format-Table | Out-String).Trim()

Write-Verbose -Message "Local Users" -Verbose
(Get-LocalUser | Out-String).Trim()

Write-Output "`nGroup Membership"
if ((Get-CimInstance -ClassName CIM_ComputerSystem).PartOfDomain -eq $true)
{
	Get-ADPrincipalGroupMembership $env:USERNAME | Select-Object -Property Name
}
#endregion User

#region Operating System
Write-Verbose -Message "Operating System" -Verbose
$ProductName = @{
	Name = "Product Name"
	Expression = {$_.Caption}
}
$InstallDate = @{
	Name       = "Install Date"
	Expression = {$_.InstallDate.Tostring().Split("")[0]}
}
$Arch = @{
	Name       = "Architecture"
	Expression = {$_.OSArchitecture}
}
$OperatingSystem = Get-CimInstance -ClassName CIM_OperatingSystem | Select-Object -Property $ProductName, $InstallDate, $Arch

$Build = @{
	Name       = "Build"
	Expression = {"$($_.CurrentMajorVersionNumber).$($_.CurrentMinorVersionNumber).$($_.CurrentBuild).$($_.UBR)"}
}
$CurrentVersion = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows nt\CurrentVersion" | Select-Object -Property $Build

([PSCustomObject] @{
	"Product Name" = $OperatingSystem."Product Name"
	"Install Date" = $OperatingSystem."Install Date"
	Build          = $CurrentVersion.Build
	Architecture = $OperatingSystem.Architecture
} | Out-String).Trim()
#endregion Operating System

#region Registered apps
Write-Verbose -Message "Registered apps" -Verbose
(Get-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName | Sort-Object
#endregion Registered apps

#region Updates
$HotFixID = @{
	Name = "KB ID"
	Expression = {$_.HotFixID}
}
$InstalledOn = @{
	Name       = "Installed on"
	Expression = {$_.InstalledOn.Tostring().Split("")[0]}
}
(Get-HotFix | Select-Object -Property $HotFixID, $InstalledOn -Unique | Format-Table | Out-String).Trim()

Write-Output "Installed updates supplied by CBS" -Verbose
$Session = New-Object -ComObject Microsoft.Update.Session
$Searcher = $Session.CreateUpdateSearcher()
$historyCount = $Searcher.GetTotalHistoryCount()

$KB = @{
	Name       = "KB ID"
	Expression = {[regex]::Match($_.Title,"(KB[0-9]{6,7})").Value}
}
$Date = @{
	Name       = "Installed Date"
	Expression = {$_.Date.Tostring().Split("") | Select-Object -Index 0}
}
($Searcher.QueryHistory(0, $historyCount) | Where-Object -FilterScript {
	($_.Title -cmatch "KB") -and ($_.Title -notmatch "Defender") -and ($_.ResultCode -eq 2)
} | Select-Object $KB, $Date | Format-Table | Out-String).Trim()
#endregion Updates

#region Logical drives
Write-Verbose -Message "Logical drives" -Verbose
$Name = @{
	Name       = "Name"
	Expression = {$_.DeviceID}
}
enum DriveType
{
	RemovableDrive = 2
	HardDrive      = 3
}
$Type = @{
	Name       = "Drive Type"
	Expression = {[System.Enum]::GetName([DriveType],$_.DriveType)}
}
$Size = @{
	Name       = "Size, GB"
	Expression = {[math]::round($_.Size/1GB, 2)}
}
$FreeSpace = @{
	Name       = "FreeSpace, GB"
	Expression = {[math]::round($_.FreeSpace/1GB, 2)}
}
(Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object -FilterScript {$_.DriveType -ne 4} | Select-Object -Property $Name, $Type, $Size, $FreeSpace | Format-Table | Out-String).Trim()
#endregion Logical drives

#region Mapped disks
Write-Verbose -Message "Mapped disks" -Verbose
(Get-SmbMapping | Select-Object -Property LocalPath, RemotePath | Format-Table | Out-String).Trim()
#endregion Mapped disks

#region Printers
Write-Verbose -Message Printers" -Verbose
Get-CimInstance -ClassName CIM_Printer | Select-Object -Property Name, Default, PortName, DriverName, ShareName | Format-Table
#endregion Printers

#region Network
Write-Verbose -Message "Default IP gateway" -Verbose
(Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration).DefaultIPGateway

Write-Verbose -Message  DNS -Verbose
(Get-DnsClientServerAddress -Family IPv4).ServerAddresses
#endregion Network

#region Microsoft Defender threats
Write-Verbose -Message "Microsoft Defender threats" -Verbose
enum ThreatStatusID
{
	Unknown          = 0
	Detected         = 1
	Cleaned          = 2
	Quarantined      = 3
	Removed          = 4
	Allowed          = 5
	Blocked          = 6
	QuarantineFailed = 102
	RemoveFailed     = 103
	AllowFailed      = 104
	Abondoned        = 105
	BlockedFailed    = 107
}
(Get-MpThreatDetection | ForEach-Object -Process {
	[PSCustomObject] @{
		"Detected Threats Paths" = $_.Resources
		"ThreatID"               = $_.ThreatID
		"Status"                 = [System.Enum]::GetName([ThreatStatusID],$_.ThreatStatusID)
		"Detection Time"         = $_.InitialDetectionTime
	}
} | Sort-Object ThreatID -Unique | Format-Table -AutoSize -Wrap | Out-String).Trim()
#endregion Microsoft Defender threats

#region Microsoft Defender settings
Write-Verbose -Message "Microsoft Defender settings" -Verbose
(Get-MpPreference | ForEach-Object -Process {
	[PSCustomObject] @{
		"Excluded IDs"                                  = $_.ThreatIDDefaultAction_Ids | Out-String
		"Excluded Process"                              = $_.ExclusionProcess | Out-String
		"Controlled Folder Access"                      = $_.EnableControlledFolderAccess | Out-String
		"Controlled Folder Access Protected Folders"    = $_.ControlledFolderAccessProtectedFolders | Out-String
		"Controlled Folder Access Allowed Applications" = $_.ControlledFolderAccessAllowedApplications | Out-String
		"Excluded Extensions"                           = $_.ExclusionExtension | Out-String
		"Excluded Paths"                                = $_.ExclusionPath | Out-String
	}
} | Format-List | Out-String).Trim()
#endregion Windows Defender settings
