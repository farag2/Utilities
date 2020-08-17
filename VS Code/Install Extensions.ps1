# Install VS Code extensions
$Extensions = @(
	# Локализация
	"ms-ceintl.vscode-language-pack-ru",
	# Markdown
	"DavidAnson.vscode-markdownlint",
	# PowerShell
	"ms-vscode.PowerShell",
	# Code Runner
	"formulahendry.code-runner",
	# Regex Previewer
	"chrmarti.regex",
	# SVG Viewer
	"cssho.vscode-svgviewer",
)
foreach ($Extension in $Extensions)
{
	 & "${env:ProgramFiles}\Microsoft VS Code\bin\code.cmd" --install-extension $Extension
}