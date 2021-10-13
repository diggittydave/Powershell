param(
    [string]$bbb
)
$branch = "$bbb"
$uri = "http://dbadmin.chq.ei:8121/cgi-bin/dbSnap?url="+$branch+"."+$branch+".ei+db2inst7+50012+BRDB"
$outfile = "C:\Users\chq-davidwe\Documents\Projects\web-stuff\results\$branch-BRDB.txt"
Invoke-RestMethod -Uri "$uri" -OutFile "$outfile"

