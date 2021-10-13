param(
    [string]$bbb
)
$branch = "$bbb"
$uri = "http://dbadmin.chq.ei:8121/cgi-bin/dbSnap?url="+$branch+"."+$branch+".ei+db2inst5+50008+INVPROC"
$outfile = "C:\Users\chq-davidwe\Documents\Projects\web-stuff\results\$branch-INVPROC.txt"
Invoke-RestMethod -Uri "$uri" -OutFile "$outfile"
