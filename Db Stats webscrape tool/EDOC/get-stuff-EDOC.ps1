param(
    [string]$bbb
)
$branch = "$bbb"
$uri = "http://dbadmin.chq.ei:8121/cgi-bin/dbSnap?url="+$branch+"."+$branch+".ei+db2inst2+50002+EDOC"
$outfile = "C:\Users\chq-davidwe\Documents\Projects\web-stuff\results\$branch-EDOC.txt"
Invoke-RestMethod -Uri "$uri" -OutFile "$outfile"

