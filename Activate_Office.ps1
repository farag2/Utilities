# Activate Office 2019/2021 using a 3rd party KMS server

# https://docs.microsoft.com/en-us/deployoffice/vlactivation/tools-to-manage-volume-activation-of-office
<#
	ProPlus2021VL
	Standard2021VL
	ProPlus2019VL
	Standard2019VL
#>
$Items = @((Get-ChildItem -Path "$env:ProgramFiles\Microsoft Office\root\Licenses16" | Where-Object -FilterScript {$_.FullName -match "Standard2021VL"}).FullName)
foreach ($Item in $Items)
{
	cscript "$env:ProgramFiles\Microsoft Office\Office16\ospp.vbs" /inslic:"$Item" //nologo
}

# Get the last 5 characters of installed product key to remove it
if ($null -ne ((cscript "$env:ProgramFiles\Microsoft Office\Office16\ospp.vbs" /dstatus | Select-String -Pattern "Last 5" -SimpleMatch | Out-String).Replace("Last 5 characters of installed product key: ", "").Trim()))
{
	$KeyToRemove = (cscript "$env:ProgramFiles\Microsoft Office\Office16\ospp.vbs" /dstatus | Select-String -Pattern "Last 5" -SimpleMatch | Out-String).Replace("Last 5 characters of installed product key: ", "").Trim()
}
# Set a KMS port with a user-provided port number. The default port number is 1688
cscript "$env:ProgramFiles\Microsoft Office\Office16\ospp.vbs" /setprt:1688 //nologo
# Uninstall an installed product key with the last five digits of the product key to uninstall (as displayed by the /dstatus option)
cscript "$env:ProgramFiles\Microsoft Office\Office16\ospp.vbs" /unpkey:"$KeyToRemove" //nologo

# https://docs.microsoft.com/en-us/deployoffice/vlactivation/gvlks
# Office Professional Plus 2019: NMMKJ-6RK4F-KMJVX-8D9MJ-6MWKP
# Office Standard 2019: 6NWWJ-YQWMR-QKGCB-6TMB3-9D9HK
# Office Professional Plus 2021: FXYTK-NJJ8C-GB6DW-3DYQT-6F7TH 
# Office Standard 2021: KDX7X-BNVR8-TXXGX-4Q7Y8-78VT3
cscript "$env:ProgramFiles\Microsoft Office\Office16\ospp.vbs" /inpkey:KDX7X-BNVR8-TXXGX-4Q7Y8-78VT3 //nologo

# Set the specific DNS domain in which all KMS SRV records can be found. This setting has no effect if the specific single KMS host name is set by the /sethst option
# https://moe.best/kms.html
cscript $env:SystemRoot\System32\slmgr.vbs /skms kms.loli.best //nologo
cscript $env:SystemRoot\System32\slmgr.vbs /ato //nologo
# Activate installed Office product keys
cscript "$env:ProgramFiles\Microsoft Office\Office16\ospp.vbs" /act //nologo
