# Add "Windows Photo Viewer" to Open with context menu
if (-not (Test-Path -Path Registry::HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open\command))
{
	New-Item -Path Registry::HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open\command -Force
}
if (-not (Test-Path -Path Registry::HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open\DropTarget))
{
	New-Item -Path Registry::HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open\DropTarget -Force
}
New-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open -Name MuiVerb -Type String -Value "@photoviewer.dll,-3043" -Force
New-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open\command -Name "(default)" -Type ExpandString -Value "%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1" -Force
New-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open\DropTarget -Name Clsid -Type String -Value "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" -Force

# Associate BMP, JPEG, PNG, TIF to "Windows Photo Viewer"
cmd.exe --% /c ftype Paint.Picture=%windir%\System32\rundll32.exe "%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll", ImageView_Fullscreen %1
cmd.exe --% /c ftype jpegfile=%windir%\System32\rundll32.exe "%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll", ImageView_Fullscreen %1
cmd.exe --% /c ftype pngfile=%windir%\System32\rundll32.exe "%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll", ImageView_Fullscreen %1
cmd.exe --% /c ftype TIFImage.Document=%windir%\System32\rundll32.exe "%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll", ImageView_Fullscreen %1
cmd.exe --% /c assoc .bmp=Paint.Picture
cmd.exe --% /c assoc .jpg=jpegfile
cmd.exe --% /c assoc .jpeg=jpegfile
cmd.exe --% /c assoc .png=pngfile
cmd.exe --% /c assoc .tif=TIFImage.Document
cmd.exe --% /c assoc .tiff=TIFImage.Document
cmd.exe --% /c assoc Paint.Picture\DefaultIcon=%SystemRoot%\System32\imageres.dll,-70
cmd.exe --% /c assoc jpegfile\DefaultIcon=%SystemRoot%\System32\imageres.dll,-72
cmd.exe --% /c assoc pngfile\DefaultIcon=%SystemRoot%\System32\imageres.dll,-71
cmd.exe --% /c assoc TIFImage.Document\DefaultIcon=%SystemRoot%\System32\imageres.dll,-122
