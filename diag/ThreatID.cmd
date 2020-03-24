set ThreatID= ^
Write-Host "KMS"; ^
Add-MpPreference -ThreatIDDefaultAction_Ids 225062 -ThreatIDDefaultAction_Actions Allow -Force; ^
Add-MpPreference -ThreatIDDefaultAction_Ids 2147685180 -ThreatIDDefaultAction_Actions Allow -Force; ^
Add-MpPreference -ThreatIDDefaultAction_Ids 2147714384 -ThreatIDDefaultAction_Actions Allow -Force; ^
Add-MpPreference -ThreatIDDefaultAction_Ids 2147727613 -ThreatIDDefaultAction_Actions Allow -Force; ^
Add-MpPreference -ThreatIDDefaultAction_Ids 2147734094 -ThreatIDDefaultAction_Actions Allow -Force; ^
Add-MpPreference -ThreatIDDefaultAction_Ids 2147743522 -ThreatIDDefaultAction_Actions Allow -Force; ^
Write-Host "KMS Cleaner"; ^
Add-MpPreference -ThreatIDDefaultAction_Ids 2147749214 -ThreatIDDefaultAction_Actions Allow -Force; ^
Write-Host "Adobe patch"; ^
Add-MpPreference -ThreatIDDefaultAction_Ids 2147593794 -ThreatIDDefaultAction_Actions Allow -Force; ^
Write-Host "AutoCAD"; ^
Add-MpPreference -ThreatIDDefaultAction_Ids 2147648291 -ThreatIDDefaultAction_Actions Allow -Force;
start powershell -noexit -command %ThreatID%
