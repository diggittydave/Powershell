$excutingScriptDirectory = 
$who = $ENV:USERNAME
Start-Job -ScriptBlock { . "C:\Users\$who\Documents\Projects\web-stuff\BRDB\Main-Stuff-BRDB.ps1" }
Start-Job -ScriptBlock { . "C:\Users\$who\Documents\Projects\web-stuff\ETMS\Main-Stuff-ETMS.ps1" }
Start-Job -ScriptBlock { . "C:\Users\$who\Documents\Projects\web-stuff\EDOC\Main-Stuff-EDOC.ps1" }
Start-Job -ScriptBlock { . "C:\Users\$who\Documents\Projects\web-stuff\INVPROC\Main-Stuff-INVPROC.ps1" }
while(Get-Job -State Running){start-sleep 1}

