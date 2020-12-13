set ThreatID= ^
Write-Host "KMS"; ^
Add-MpPreference -ThreatIDDefaultAction_Ids 225062 -ThreatIDDefaultAction_Actions Allow -Force; ^
Add-MpPreference -ThreatIDDefaultAction_Ids 2147685180 -ThreatIDDefaultAction_Actions Allow -Force; ^
Add-MpPreference -ThreatIDDefaultAction_Ids 2147714384 -ThreatIDDefaultAction_Actions Allow -Force; ^
Add-MpPreference -ThreatIDDefaultAction_Ids 2147727613 -ThreatIDDefaultAction_Actions Allow -Force; ^
Add-MpPreference -ThreatIDDefaultAction_Ids 2147734094 -ThreatIDDefaultAction_Actions Allow -Force; ^
Add-MpPreference -ThreatIDDefaultAction_Ids 2147743522 -ThreatIDDefaultAction_Actions Allow -Force; ^
Add-MpPreference -ExclusionPath C:\Windows\KMS -Force; ^
Add-MpPreference -ExclusionPath $env:SystemRoot\KMSAutoS -Force; ^
Add-MpPreference -ExclusionPath $env:SystemRoot\System32\SppExtComObjHook.dll -Force; ^
Add-MpPreference -ExclusionPath $env:SystemRoot\System32\SppExtComObjPatcher.exe -Force; ^
Write-Host "KMS Cleaner"; ^
Add-MpPreference -ThreatIDDefaultAction_Ids 2147749214 -ThreatIDDefaultAction_Actions Allow -Force; ^
Write-Host "Adobe patch"; ^
Add-MpPreference -ThreatIDDefaultAction_Ids 2147593794 -ThreatIDDefaultAction_Actions Allow -Force; ^
Write-Host "AutoCAD"; ^
Add-MpPreference -ThreatIDDefaultAction_Ids 2147648291 -ThreatIDDefaultAction_Actions Allow -Force; ^
Add-MpPreference -ThreatIDDefaultAction_Ids 2147726780 -ThreatIDDefaultAction_Actions Allow -Force;
START powershell -NoExit -NoLogo NoProfile -Command %ThreatID%
