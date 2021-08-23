# https://www.pdq.com/blog/capturing-screenshots-with-powershell-and-net/
function Capture-Screen
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]
		$Path
	)

	if (-not (Test-Path -Path $Path))
	{
		New-Item -Path $Path -ItemType Directory -Force
	}

	$FileName = "$(Get-Date -f yyyy-MM-dd_HHmmss).bmp"
	$File = "$Path\$FileName"

	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing
	$Screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
	$Width = $Screen.Width
	$Height = $Screen.Height
	$Left = $Screen.Left
	$Top = $Screen.Top
	# Create bitmap using the top-left and bottom-right bounds
	$bitmap = New-Object -TypeName System.Drawing.Bitmap -ArgumentList $Width, $Height
	# Create Graphics object
	$graphic = [System.Drawing.Graphics]::FromImage($bitmap)
	# Capture screen
	$graphic.CopyFromScreen($Left, $Top, 0, 0, $bitmap.Size)
	$bitmap.Save($File)
}
Capture-Screen -Path D:\1
