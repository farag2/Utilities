# Install VS Code extensions
$Extensions = @(
	# Локализация
	"ms-ceintl.vscode-language-pack-ru",
	# Markdown
	"DavidAnson.vscode-markdownlint",
	"ms-vscode.PowerShell"
)
foreach ($Extension in $Extensions)
{
	& "${env:ProgramFiles}\Microsoft VS Code\bin\code.cmd" --install-extension $Extension
}