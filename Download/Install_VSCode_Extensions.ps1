# Install VS Code extensions
$Extensions = @(
	# Localization
	"ms-ceintl.vscode-language-pack-ru",

	# Markdown
	"DavidAnson.vscode-markdownlint",

	# PowerShell
	"ms-vscode.PowerShell",

	# Gremlins tracker
	"nhoizey.gremlins",

	# Run selected PowerShell script
	"bvanderhorn.run-selected-powershell-script",

	# Symbols
	"miguelsolorio.symbols"
)
foreach ($Extension in $Extensions)
{
	if (Test-Path -Path "$env:ProgramFiles\Microsoft VS Code\bin\code.cmd")
	{
		& "$env:ProgramFiles\Microsoft VS Code\bin\code.cmd" --install-extension $Extension
	}
	elseif (Test-Path -Path "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd")
	{
		& "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd" --install-extension $Extension
	}
}
