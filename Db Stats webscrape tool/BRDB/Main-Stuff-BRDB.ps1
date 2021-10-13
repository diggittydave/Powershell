param()

$ARRAY1 = @(gc C:\Users\chq-davidwe\Documents\Projects\web-stuff\allProdEtmsServers.txt) 
$maxThreads = 20
$file = "C:\Users\chq-davidwe\Documents\Projects\web-stuff\results\results-BRDB.txt"
$results = "C:\Users\chq-davidwe\Documents\Projects\web-stuff\results\results-BRDB.csv"

Function Stream-jobs{
    Foreach($element in $ARRAY1){
        $bbb = "$element"
        while((Get-Job -State Running).count -ge $maxThreads){start-sleep 1}
        Write-Host "$bbb"
        Start-Job -ScriptBlock { . 'C:\Users\chq-davidwe\Documents\Projects\web-stuff\BRDB\get-stuff-BRDB.ps1' -bbb $args[0]} -ArgumentList "$bbb"
        }
    
}
Function Receive-jobs{
    Foreach($element in $ARRAY1){
        $bbb = "$element"
        while((Get-Job -State Running).count -ge $maxThreads){start-sleep 1}
        Start-Job -ScriptBlock { . 'C:\Users\chq-davidwe\Documents\Projects\web-stuff\BRDB\parse-stuff-BRDB.ps1' -bbb $args[0]} -ArgumentList "$bbb"
    }
}

Function Create-Csv{ #
    (Get-Content "$file")|?{$_.trim() -ne ""}|Set-Content -LiteralPath "$file" -Force -Encoding Ascii
    $i = 2
    (get-content "$file")|ForEach-Object{
                            $eq = "=(K$i/60) =((100-G$i)/100)*L$i"
                            $string = "$_"
                            $string.replace("$string","$string $eq")
                            ;$i++
                        }|Set-Content "$file" -Force -Encoding ASCII
    (Get-Content "$file")|Foreach-Object{$_ -replace ' {2,}',' '}|Set-Content "$file" -Force -Encoding ASCII
    #header names
    $h1="Branch";$h2="Bufferpool";$h3="Sub-name";$h4="Hit Ratio";$h5="Total Reads";$h6="Reads per Day";
    $h7="Reads per Hour";$h8="Reads per Minute";$h9="Reads per Second";$h10="Total I.O.P.S.";$h11="Up since:";$h12="Current date";$h13="Uptime in Days"
    #gets the orignal csvs and edits them down to useable columns/data.
    (Import-Csv $file -Delimiter " " -Header $h1,$h11,$h12,$h13,$h2,$h3,$h4,$h5,$h6,$h7,$h8,$h9,$h10)|Export-Csv -Path $results -NoTypeInformation
    Start-Sleep 1
    #remove the old text files
    Remove-Item -LiteralPath "$file" -Force
}


Stream-jobs
while((get-job -State Running) -ne $null){start-sleep 1}
Receive-jobs
while((get-job -State Running) -ne $null){start-sleep 1}
Create-Csv
