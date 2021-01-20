[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"

# Main archive
$Parameters = @{
	Uri = "https://github.com/minischetti/metro-for-steam/archive/v4.4.zip"
	OutFile = "$DownloadsFolder\metro-for-steam.zip"
	Verbose = [switch]::Present
}
Invoke-WebRequest @Parameters

$Parameters = @{
	Path = "$DownloadsFolder\metro-for-steam.zip"
	DestinationPath = "$DownloadsFolder\Metro"
	Force = [switch]::Present
	Verbose = [switch]::Present
}
Expand-Archive @Parameters

# Patch
$Parameters = @{
	Uri = "https://github.com/redsigma/UPMetroSkin/archive/master.zip"
	OutFile = "$DownloadsFolder\UPMetroSkin.zip"
	Verbose = [switch]::Present
}
Invoke-WebRequest @Parameters

$Parameters = @{
	Path = "$DownloadsFolder\UPMetroSkin.zip"
	DestinationPath = "$DownloadsFolder\Metro"
	Force = [switch]::Present
	Verbose = [switch]::Present
}
Expand-Archive @Parameters

<#
    .SYNOPSIS
        Копирование или псевдоперемещение файлов и каталогов с сохранением структуры

    .Description
        Скрипт предназначен для копирования или перемещения файлов из одного каталога
        в другой, при этом сохраняется вложенная структура каталогов. Фактически,
        перемещение не выполняется, вместо него работает копирование с последующим
        удалением скопированнных итемов.

    .Parameter Source
        Необязательный: Исходный каталог для выборки элементов. Указывается либо
        относительный, либо абсолютный путь.

    .Parameter Destination
        Необязательный: Целевой каталог. Указывается либо относительный, либо
        абсолютный путь.

    .Parameter Include
        Необязательный: маска(и) для включения элементов в выборку

    .Parameter Exclude
        Необязательный: маска(и) для исключения элементов из выборки

    .Parameter Delete
        Переключатель: Если указан, то будут удалены исходные файлы, включенные в выборку,
        рекурсивно

    .Parameter DeleteEmpty
        Переключатель: Если указан, то будут удалены рекурсивно пустые подкаталоги в исходном каталоге

    .Example
        .\script.ps1 -Source "D:\FOLDER1" -Destination "d:\Folder2" -Include '*.pdf', '*.txt' -Exclude '*_out.*' -Delete

        Это пример перемещения файлов по маскам '*.pdf','*.txt' с исключением из выборки по маске
        '*_out.*', с последующим удалением исходных элементов. Пустые каталоги не удаляются

    .Example
        .\script.ps1

        Это пример копирования/перемещения файлов/каталогов, с сохранением структуры, но
        по указанным в самом скрипте параметрам...

    .Link
        https://forum.ru-board.com/topic.cgi?forum=62&topic=30859&start=3600#4

    .Notes
        Created By YuS

        Version: 1.00
        Date: 20.01.2021
#>
function Move-Recursively
{
    [CmdletBinding()]
    param
    (
        [string]
        $Source,

        [string]
        $Destination,

        [string[]]
        $Include = '*.*',

        [string[]]
        $Exclude = '',

        [switch]
        $Delete,

        [switch]
        $DeleteEmpty
    )
    $src = Get-Item -LiteralPath $Source -Force

    # перемещение файлов с сохранением структуры
    Get-ChildItem -LiteralPath $src.fullname -Include $Include -Exclude $Exclude -Recurse -Force | Copy-Item -Destination {
        $Folder = Split-Path -Path $_.FullName.Replace("$($src.FullName)",$Destination)
        if (-not (Test-Path -LiteralPath $Folder))
        {
            New-Item -Path $Folder -ItemType Directory -Force
        }
        else
        {
            $Folder
        }
    } -Force #-whatif

    if ($Delete.IsPresent)
    {
        # удаляем все скопированные файлы
        Get-ChildItem -LiteralPath $src.FullName  -Include $Include -Exclude $Exclude -Recurse -Force -File | Remove-Item -Recurse -Force
    }
    if ($DeleteEmpty.IsPresent)
    {
        # удаляем пустые каталоги
        Get-ChildItem -LiteralPath $src.FullName -Recurse -Directory -Force | Sort-Object {$_.FullName.Length} -Descending | ForEach-Object -Process {
            if ($null -eq (Get-ChildItem -LiteralPath $_.FullName -Recurse -force))
            {
                Remove-Item -LiteralPath $_.FullName -Force
            }
        }
    }
}

$Source = "$DownloadsFolder\Metro\UPMetroSkin-master\Unofficial 4.x Patch\Main Files [Install First]"
$Destination = "$DownloadsFolder\Metro\metro-for-steam-4.4"

Move-Recursively -Source $Source -Destination $Destination -Delete

# Removing unnecessary files and folders
Remove-Item -Path "$DownloadsFolder\metro-for-steam.zip", "$DownloadsFolder\UPMetroSkin.zip" -Force
Remove-Item -LiteralPath "$DownloadsFolder\Metro\metro-for-steam-4.4\.gitattributes", "$DownloadsFolder\Metro\metro-for-steam-4.4\.gitignore" -Force
# Remove-Item -LiteralPath "$DownloadsFolder\Metro\UPMetroSkin-master" -Recurse -Force

Get-ChildItem -LiteralPath "$DownloadsFolder\Metro\metro-for-steam-4.4" -Recurse -Force | Move-Item -Destination "$DownloadsFolder\Metro" -Force
Remove-Item -LiteralPath "$DownloadsFolder\Metro\metro-for-steam-4.4" -Force

# Custom menu
$Parameters = @{
	Uri = "https://github.com/farag2/Utilities/blob/master/Steam/steam.menu"
	OutFile = "$DownloadsFolder\Metro\resource\menus\steam.menu"
	Verbose = [switch]::Present
}
Invoke-WebRequest @Parameters

if (Test-Path -Path ${env:ProgramFiles(x86)}\Steam)
{
	Move-Item -Path "$DownloadsFolder\Metro" -Destination "${env:ProgramFiles(x86)}\Steam\Skins" -Force
}
else
{
	Write-Warning -Message "No Steam installed"
}
