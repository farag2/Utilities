# Uninstall Chromium Edge
$ProductVersion = (Get-Item -Path ${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe).VersionInfo.ProductVersion
Start-Process -FilePath ${env:ProgramFiles(x86)}\Microsoft\Edge\Application\$ProductVersion\msedge.exe -ArgumentList "--uninstall --system-level --verbose-logging --force-uninstall" -Wait

# Revert to the original Edge with a pop-up
Stop-Process -Name msedge -Force -PassThru -ErrorAction SilentlyContinue
[string]$UninstallString = Get-Package -Name "Microsoft Edge" | ForEach-Object -Process {$_.Meta.Attributes["UninstallString"]}
[string[]]$UninstallString = ($UninstallString -Replace("\s*--",",--")).Split(",").Trim()
# [string[]]$Edge = ($UninstallString -Replace("\s*--",",--")).Split(",").Trim()
$ProductVersion = (Get-Item -Path ${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe).VersionInfo.ProductVersion
Start-Process -FilePath "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\$ProductVersion\msedge.exe" -ArgumentList $UninstallString[1..3] -Wait

# Revert to the original Edge without a pop-up
Stop-Process -Name msedge -Force -PassThru -ErrorAction SilentlyContinue
[string]$UninstallString = Get-Package -Name "Microsoft Edge" | ForEach-Object -Process {$_.Meta.Attributes["UninstallString"]}
[string[]]$UninstallString = ($UninstallString -Replace("\s*--",",--")).Split(",").Trim()
# [string[]]$Edge = ($UninstallString -Replace("\s*--",",--")).Split(",").Trim()
$ProductVersion = (Get-Item -Path ${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe).VersionInfo.ProductVersion
Start-Process -FilePath "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\$ProductVersion\msedge.exe" -ArgumentList "$UninstallString[1..3] --force-uninstall" -Wait
