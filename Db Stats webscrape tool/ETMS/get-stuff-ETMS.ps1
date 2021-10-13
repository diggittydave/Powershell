param(
    [string]$bbb
)
$branch = "$bbb"
$uri = "http://dbadmin.chq.ei:8121/cgi-bin/dbSnap?url="+$branch+"."+$branch+".ei+db2inst1+50000+"+$branch.ToUpper()
$outfile = "C:\Users\chq-davidwe\Documents\Projects\web-stuff\results\$branch-ETMS.txt"
Invoke-RestMethod -Uri "$uri" -OutFile "$outfile"
