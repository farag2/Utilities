# Unmap all drives
Get-PSDrive -Name "U", "H", "L", "P", "T" -ErrorAction Ignore | Remove-PSDrive -Force

# Map drives
$Parameters = @{
	Name       = "U"
	PSProvider = "FileSystem"
	Root       = "<\\fileserver>\folder"
	Persist    = $true
}
New-PSDrive @Parameters

$Parameters = @{
	Name       = "H"
	PSProvider = "FileSystem"
	Root       = "<\\fileserver>\folder"
	Persist    = $true
}
New-PSDrive @Parameters

$Parameters = @{
	Name       = "L"
	PSProvider = "FileSystem"
	Root       = "<\\fileserver>\folder"
	Persist    = $true
}
New-PSDrive @Parameters

$Parameters = @{
	Name       = "P"
	PSProvider = "FileSystem"
	Root       = "<\\fileserver>\folder"
	Persist    = $true
}
New-PSDrive @Parameters

$Parameters = @{
	Name       = "T"
	PSProvider = "FileSystem"
	Root       = "<\\fileserver>\folder"
	Persist    = $true
}
New-PSDrive @Parameters

pause
