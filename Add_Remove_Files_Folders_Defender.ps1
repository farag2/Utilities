# Enable Controlled folder access and add protected folders
function AddProtectedFolders
{
	$Title = $Localization.ControlledFolderAccess
	$Message = $Localization.ProtectedFoldersRequest
	$Add = $Localization.Add
	$Skip = $Localization.Skip
	$Options = "&$Add", "&$Skip"
	$DefaultChoice = 1

	do
	{
		$Result = $Host.UI.PromptForChoice($Title, $Message, $Options, $DefaultChoice)
		switch ($Result)
		{
			"0"
			{
				Add-Type -AssemblyName System.Windows.Forms
				$FolderBrowserDialog = New-Object -TypeName System.Windows.Forms.FolderBrowserDialog
				$FolderBrowserDialog.Description = $Localization.FolderSelect
				$FolderBrowserDialog.RootFolder = "MyComputer"

				# Force move the open file dialog to the foreground
				$Focus = New-Object -TypeName System.Windows.Forms.Form -Property @{TopMost = $true}
				$FolderBrowserDialog.ShowDialog($Focus)

				if ($FolderBrowserDialog.SelectedPath)
				{
					Set-MpPreference -EnableControlledFolderAccess Enabled
					Add-MpPreference -ControlledFolderAccessProtectedFolders $FolderBrowserDialog.SelectedPath -Force
					Write-Verbose -Message ("{0}" -f $FolderBrowserDialog.SelectedPath) -Verbose
				}
			}
			"1"
			{
				Write-Verbose -Message $Localization.Skipped -Verbose
			}
		}
	}
	until ($Result -eq 1)
}

# Remove all added protected folders
function RemoveProtectedFolders
{
	if ($null -ne (Get-MpPreference).ControlledFolderAccessProtectedFolders)
	{
		(Get-MpPreference).ControlledFolderAccessProtectedFolders | Format-Table -AutoSize -Wrap
		Remove-MpPreference -ControlledFolderAccessProtectedFolders (Get-MpPreference).ControlledFolderAccessProtectedFolders -Force
		Write-Verbose -Message $Localization.ProtectedFoldersListRemoved -Verbose
	}
}

# Allow an app through Controlled folder access
function AddAppControlledFolder
{
	$Title = $Localization.ControlledFolderAccess
	$Message = $Localization.AppControlledFolderRequest
	$Add = $Localization.Add
	$Skip = $Localization.Skip
	$Options = "&$Add", "&$Skip"
	$DefaultChoice = 1

	do
	{
		$Result = $Host.UI.PromptForChoice($Title, $Message, $Options, $DefaultChoice)
		switch ($Result)
		{
			"0"
			{
				Add-Type -AssemblyName System.Windows.Forms
				$OpenFileDialog = New-Object -TypeName System.Windows.Forms.OpenFileDialog
				$OpenFileDialog.Filter = $Localization.EXEFilesFilter
				$OpenFileDialog.InitialDirectory = "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
				$OpenFileDialog.Multiselect = $false

				# Force move the open file dialog to the foreground
				$Focus = New-Object -TypeName System.Windows.Forms.Form -Property @{TopMost = $true}
				$OpenFileDialog.ShowDialog($Focus)

				if ($OpenFileDialog.FileName)
				{
					Add-MpPreference -ControlledFolderAccessAllowedApplications $OpenFileDialog.FileName -Force
					Write-Verbose -Message ("{0}" -f $OpenFileDialog.FileName) -Verbose
				}
			}
			"1"
			{
				Write-Verbose -Message $Localization.Skipped -Verbose
			}
		}
	}
	until ($Result -eq 1)
}

# Remove all allowed apps through Controlled folder access
function RemoveAllowedAppsControlledFolder
{
	if ($null -ne (Get-MpPreference).ControlledFolderAccessAllowedApplications)
	{
		(Get-MpPreference).ControlledFolderAccessAllowedApplications | Format-Table -AutoSize -Wrap
		Remove-MpPreference -ControlledFolderAccessAllowedApplications (Get-MpPreference).ControlledFolderAccessAllowedApplications -Force
		Write-Verbose -Message $Localization.AllowedControlledFolderAppsRemoved -Verbose
	}
}

# Add a folder to the exclusion from Microsoft Defender scanning
function AddDefenderExclusionFolder
{
	$Title = "Microsoft Defender"
	$Message = $Localization.DefenderExclusionFolderRequest
	$Add = $Localization.Add
	$Skip = $Localization.Skip
	$Options = "&$Add", "&$Skip"
	$DefaultChoice = 1

	do
	{
		$Result = $Host.UI.PromptForChoice($Title, $Message, $Options, $DefaultChoice)
		switch ($Result)
		{
			"0"
			{
				Add-Type -AssemblyName System.Windows.Forms
				$FolderBrowserDialog = New-Object -TypeName System.Windows.Forms.FolderBrowserDialog
				$FolderBrowserDialog.Description = $Localization.FolderSelect
				$FolderBrowserDialog.RootFolder = "MyComputer"

				# Force move the open file dialog to the foreground
				$Focus = New-Object -TypeName System.Windows.Forms.Form -Property @{TopMost = $true}
				$FolderBrowserDialog.ShowDialog($Focus)

				if ($FolderBrowserDialog.SelectedPath)
				{
					Add-MpPreference -ExclusionPath $FolderBrowserDialog.SelectedPath -Force
					Write-Verbose -Message ("{0}" -f $FolderBrowserDialog.SelectedPath) -Verbose
				}
			}
			"1"
			{
				Write-Verbose -Message $Localization.Skipped -Verbose
			}
		}
	}
	until ($Result -eq 1)
}

# Remove all excluded folders from Microsoft Defender scanning
function RemoveDefenderExclusionFolders
{
	if ($null -ne (Get-MpPreference).ExclusionPath)
	{
		$ExcludedFolders = (Get-Item -Path (Get-MpPreference).ExclusionPath -Force -ErrorAction Ignore | Where-Object -FilterScript {$_.Attributes -match "Directory"}).FullName
		$ExcludedFolders | Format-Table -AutoSize -Wrap
		Remove-MpPreference -ExclusionPath $ExcludedFolders -Force
		Write-Verbose -Message $Localization.DefenderExclusionFoldersListRemoved -Verbose
	}
}

# Add a file to the exclusion from Microsoft Defender scanning
function AddDefenderExclusionFile
{
	$Title = "Microsoft Defender"
	$Message = $Localization.AddDefenderExclusionFileRequest
	$Add = $Localization.Add
	$Skip = $Localization.Skip
	$Options = "&$Add", "&$Skip"
	$DefaultChoice = 1

	do
	{
		$Result = $Host.UI.PromptForChoice($Title, $Message, $Options, $DefaultChoice)
		switch ($Result)
		{
			"0"
			{
				Add-Type -AssemblyName System.Windows.Forms
				$OpenFileDialog = New-Object -TypeName System.Windows.Forms.OpenFileDialog
				$OpenFileDialog.Filter = $Localization.AllFilesFilter
				$OpenFileDialog.InitialDirectory = "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
				$OpenFileDialog.Multiselect = $false

				# Force move the open file dialog to the foreground
				$Focus = New-Object -TypeName System.Windows.Forms.Form -Property @{TopMost = $true}
				$OpenFileDialog.ShowDialog($Focus)

				if ($OpenFileDialog.FileName)
				{
					Add-MpPreference -ExclusionPath $OpenFileDialog.FileName -Force
					Write-Verbose -Message ("{0}" -f $OpenFileDialog.FileName) -Verbose
				}
			}
			"1"
			{
				Write-Verbose -Message $Localization.Skipped -Verbose
			}
		}
	}
	until ($Result -eq 1)
}

# Remove all excluded files from Microsoft Defender scanning
function RemoveDefenderExclusionFiles
{
	if ($null -ne (Get-MpPreference).ExclusionPath)
	{
		$ExcludedFiles = (Get-Item -Path (Get-MpPreference).ExclusionPath -Force -ErrorAction Ignore | Where-Object -FilterScript {$_.Attributes -notmatch "Directory"}).FullName
		$ExcludedFiles | Format-Table -AutoSize -Wrap
		Remove-MpPreference -ExclusionPath $ExcludedFiles -Force
		Write-Verbose -Message $Localization.DefenderExclusionFilesRemoved -Verbose
	}
}
