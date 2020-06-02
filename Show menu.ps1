<#
.SYNOPSIS
	The "Show menu" function using PowerShell with the up/down arrow keys and enter key to make a selection
.EXAMPLE
	ShowMenu -Menu $ListOfItems -Default $DefaultChoice
.NOTES
	Doesn't work in PowerShell ISE
	https://community.spiceworks.com/scripts/show/4656-powershell-create-menu-easily-add-arrow-key-driven-menu-to-scripts
#>

function Menu
{
	param
	(
		[Parameter(Mandatory = $true)]
		[string]
		$Title,

		[Parameter(Mandatory = $true)]
		[array]
		$Options
	)

	$MaxValue = $Options.Count - 1
	$Selection = 0
	$EnterPressed = $False

	Clear-Host

	while ($EnterPressed -eq $False)
	{
		Write-Host "$Title"

		for ($i = 0; $i -le $MaxValue; $i++)
		{
			if ($i -eq $Selection)
			{
				Write-Host "[ $($Options[$i]) ]" -BackgroundColor Cyan -ForegroundColor Black
			}
			else
			{
				Write-Host "  $($Options[$i])  "
			}
		}

		$KeyInput = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").VirtualKeyCode

		switch ($KeyInput)
		{
			"13"
			{
				$EnterPressed = $true
				return $Selection
				Clear-Host
				break
			}
			"38"
			{
				if ($Selection -eq 0)
				{
					$Selection = $MaxValue
				}
				else
				{
					$Selection -= 1
				}
				Clear-Host
				break
			}
			"40"
			{
				if ($Selection -eq $MaxValue)
				{
					$Selection = 0
				}
				else
				{
					$Selection +=1
				}
				Clear-Host
				break
			}
			Default
			{
				Clear-Host
			}
		}
	}
}

$Title = "Choose theme color for default Windows mode"
$Options = @(
	"Light",
	"Dark",
	"Skip"
)
$Result = Menu -Title $Title -Options $Options

switch ($Result)
{
	"0"
	{}
	"1"
	{}
	"2"
	{
		Write-Verbose -Message "Skipped" -Verbose
	}
}



# https://michael-casey.com/2019/07/03/powershell-terminal-menu-template/
# Sample list data to populate menu:
# Set $List to any array to populate the menu with custom options
$List = Get-ChildItem -Path C:\ -Name

# menu offset to allow space to write a message above the menu
$xmin = 3
$ymin = 3

# Write Menu
Clear-Host
Write-Host "`nUse the up / down arrow to navigate and Enter to make a selection"
[Console]::SetCursorPosition(0, $ymin)
foreach ($name in $List)
{
	for ($i = 0; $i -lt $xmin; $i++)
	{
		Write-Host " " -NoNewline
	}
	Write-Host "   " + $name
}

#Highlights the selected line
function Write-Highlighted
{
	[Console]::SetCursorPosition(1 + $xmin, $cursorY + $ymin)
	Write-Host ">" -BackgroundColor Yellow -ForegroundColor Black -NoNewline
	Write-Host " " + $List[$cursorY] -BackgroundColor Yellow -ForegroundColor Black
	[Console]::SetCursorPosition(0, $cursorY + $ymin)
}

#Undoes highlight
function Write-Normal
{
	[Console]::SetCursorPosition(1 + $xmin, $cursorY + $ymin)
	Write-Host "  " + $List[$cursorY]
}

#highlight first item by default
$cursorY = 0
Write-Highlighted

$selection = ""
$menu_active = $true
while ($menu_active)
{
	if ([console]::KeyAvailable)
	{
		$x = $Host.UI.RawUI.ReadKey()
		[Console]::SetCursorPosition(1, $cursorY)
		Write-Normal
		switch ($x.VirtualKeyCode)
		{
			38
			{
				#down key
				if ($cursorY -gt 0)
				{
					$cursorY = $cursorY - 1
				}
			}

			40
			{
				#up key
				if ($cursorY -lt $List.Length - 1)
				{
					$cursorY = $cursorY + 1
				}
			}
			13
			{
				#enter key
				$selection = $List[$cursorY]
				$menu_active = $false
			}
		}
		Write-Highlighted
	}
	Start-Sleep -Milliseconds 5 #Prevents CPU usage from spiking while looping
}

Clear-Host
Write-Host $selection
#May use switch statement here to process menu selection



# https://qna.habr.com/answer?answer_id=1522379#answers_list_answer
function ShowMenu
{
	param
	(
		[Parameter(Mandatory = $true)]
		[string]
		$Title,

		[Parameter(Mandatory = $true)]
		[array]
		$Menu,

		[Parameter(Mandatory = $true)]
		[int]
		$Default
	)

	Write-Host $Title

	$minY = [Console]::CursorTop
	$y = [Math]::Max([Math]::Min($Default, $Menu.Count), 0)
	do
	{
		[Console]::CursorTop = $minY
		[Console]::CursorLeft = 0
		$i = 0
		foreach ($item in $Menu)
		{
			$colors = @{
				BackgroundColor = if ($i -ne $y)
				{
					[Console]::BackgroundColor
				}
				else
				{
					"Cyan"
				}
				ForegroundColor = if ($i -ne $y)
				{
					[Console]::ForegroundColor
				}
				else
				{
					"Blue"
				}
			}
			Write-Host (' {0}. {1} ' -f ($i+1), $item) @colors
			$i++
		}
		$k = [Console]::ReadKey()
		switch ($k.Key)
		{
			"UpArrow"
			{
				if ($y -gt 0)
				{
					$y--
				}
			}
			"DownArrow"
			{
				if ($y -lt ($Ьenu.Count - 1))
				{
					$y++
				}
			}
			"Enter"
			{
				return $Menu[$y]
			}
		}
	}
	while ($k.Key -notin ([ConsoleKey]::Escape, [ConsoleKey]::Enter))
}

$DriveLetters = (Get-Disk | Where-Object -FilterScript {$_.BusType -ne "USB"} | Get-Partition | Get-Volume | Where-Object -FilterScript {$null -ne $_.DriveLetter}).DriveLetter | Sort-Object
$Title = "Choose the drive letter in the root of which the `"Desktop`" folder will be created"
ShowMenu -Title $Title -Menu $DriveLetters -Default $Default 0
