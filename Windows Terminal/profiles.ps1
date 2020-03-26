$JsonPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\profiles.json"
# Remove all comments to parse JSON file
# Удалить все комментарии, чтобы пропарсить JSON-файл
if (Get-Content -Path $JsonPath | Select-String -Pattern "//" -SimpleMatch)
{
	Set-Content -Path $JsonPath -Value (Get-Content -Path $JsonPath | Select-String -Pattern "//" -NotMatch)
}
# Delete all blank lines from JSON file
# Удалить все пустые строки в JSON-файле
(Get-Content -Path $JsonPath) | Where-Object -FilterScript {$_.Trim(" `t")} | Set-Content -Path $JsonPath
$Terminal = Get-Content -Path $JsonPath | ConvertFrom-Json
# Do not show tabs in title bar
# Не отображать вкладки в заголовке
if ($Terminal.showTabsInTitlebar)
{
	$Terminal.showTabsInTitlebar = $false
}
else
{
	$Terminal | Add-Member -MemberType NoteProperty -Name showTabsInTitlebar -Value $false -Force
}
# Do not confirm closing all tabs
# Не подтверждать закрытие всех вкладок
if ($Terminal.confirmCloseAllTabs)
{
	$Terminal.confirmCloseAllTabs = $false
}
else
{
	$Terminal | Add-Member -MemberType NoteProperty -Name confirmCloseAllTabs -Value $false -Force
}
# Set powershell.exe starting directory to %SYSTEMDRIVE%
# Установить начальную директорию powershell.exe на %SYSTEMDRIVE%
# https://github.com/microsoft/terminal/issues/1555#issuecomment-505157311
if ($Terminal.profiles.list[0].startingDirectory)
{
	$Terminal.profiles.list[0].startingDirectory = "%SYSTEMDRIVE%\"
}
else
{
	$Terminal.profiles.list[0] | Add-Member -MemberType NoteProperty -Name startingDirectory -Value "%SYSTEMDRIVE%\" -Force
}
# Set cmd.exe starting directory to %SYSTEMDRIVE%
# Установить начальную директорию cmd.exe на %SYSTEMDRIVE%
if ($Terminal.profiles.list[1].startingDirectory)
{
	$Terminal.profiles.list[1].startingDirectory = "%SYSTEMDRIVE%\"
}
else
{
	$Terminal.profiles.list[1] | Add-Member -MemberType NoteProperty -Name startingDirectory -Value "%SYSTEMDRIVE%\" -Force
}
# Hide Azure Cloud Shell
# Скрыть Azure Cloud Shell
if ($Terminal.profiles.list[2].hidden)
{
	$Terminal.profiles.list[2].hidden = $true
}
else
{
	$Terminal.profiles.list[2] | Add-Member -MemberType NoteProperty -Name hidden -Value $true -Force
}
# Closing tabs by ctrl+w
# Закрытие вкладок по ctrl+w
$closeTab = [PSCustomObject]@{
	"command" = "closeTab"
	"keys" = "ctrl+w"
}
$Terminal.keybindings += $closeTab
# New tab by ctrl+t
# Новая вкладка по ctrl+t
$newTab = [PSCustomObject]@{
	"command" = "newTab"
	"keys" = "ctrl+t"
}
$Terminal.keybindings += $newTab
# Find by ctrl+f
# Поиск по ctrl+f
$find = [PSCustomObject]@{
	"command" = "find"
	"keys" = "ctrl+f"
}
$Terminal.keybindings += $find
# Copying by ctrl+с
# Копирование по ctrl+c
$Copy = [PSCustomObject]@{
	"command" = "copy"
	"keys" = "ctrl+c"
}
$Terminal.keybindings += $Copy
# Pasting by ctrl+v
# Вставка по ctrl+v
$Paste = [PSCustomObject]@{
	"command" = "paste"
	"keys" = "ctrl+v"
}
$Terminal.keybindings += $Paste
# Splitting pane by ctrl+shift+d
# Разделение оболочки по ctrl+shift+d
$split = [PSCustomObject]@{
	"action" = "splitPane"
	"split" = "auto"
	"splitMode" = "duplicate"
}
$splitPane = [PSCustomObject]@{
	"command" = $split
	"keys" = "ctrl+shift+d"
}
$Terminal.keybindings += $splitPane
ConvertTo-Json -InputObject $Terminal -Depth 4 | Set-Content -Path $JsonPath -Force