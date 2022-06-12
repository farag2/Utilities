# Add new "UA" property to JSON
Remove-TypeData System.Array -ErrorAction Ignore
$Terminal = Get-Content -Path "D:\Downloads\1.js" -Encoding UTF8 -Force | ConvertFrom-Json

$Terminal | ForEach-Object {
	$_.Header | Add-Member -MemberType NoteProperty -Name "UA" -Value "" -Force
}
$Terminal | ForEach-Object {
	$_.Description | Add-Member -MemberType NoteProperty -Name "UA" -Value "" -Force
}
<#
$Terminal | Where-Object -FilterScript {$_.ChildElements.ChildDescription} | ForEach-Object {
	$_.ChildElements.ChildDescription | Add-Member -MemberType NoteProperty -Name "UA" -Value "" -Force
}
#>

ConvertTo-Json -InputObject $Terminal -Depth 4 | Set-Content -Path "D:\Downloads\1.js" -Encoding UTF8 -Force
# Re-save in the UTF-8 without BOM encoding due to JSON must not has the BOM: https://datatracker.ietf.org/doc/html/rfc8259#section-8.1
Set-Content -Value (New-Object -TypeName System.Text.UTF8Encoding -ArgumentList $false).GetBytes($(Get-Content -Path "D:\Downloads\1.js" -Raw)) -Encoding Byte -Path "D:\Downloads\1.js" -Force
