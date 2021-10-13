param(
        [string]$bbb
    )
    $branch = "$bbb"
    $array = @()
    $replace1 = '</SPAN><SPAN STYLE="background-color: #C0C0C0">'
    $replace2 = '</SPAN><SPAN STYLE="background-color: #E0E0E0">'
    $file = "C:\Users\chq-davidwe\Documents\Projects\web-stuff\results\$branch-ETMS.txt"
    $data = Get-Content "$file"
    $uptime_string = ($data |Select-String -Pattern "1: $bbb.$bbb.ei")
    $uptime_array = @($uptime_string -split " ")
    $uptime_begin = $uptime_array[8]
    $uptime_current_day = $uptime_array[11]
    $uptime_total = $uptime_array[14]
    $BUFFERPOOL8k = ($data | Select-String -Pattern ">BUFFERPOOL8K"| foreach{$string = "$_ "; $string.Replace("$replace1",'')}| foreach{$string = "$_ "; $string.Replace("$replace2",'')})
    $IBM = ($data | Select-String -Pattern ">IBMDEFAULTBP"| foreach{$string = "$_ "; $string.Replace("$replace1",'')}| foreach{$string = "$_ "; $string.Replace("$replace2",'')})
    $DATA8k = ($data | Select-String -Pattern ">DATA8K"| foreach{$string = "$_ "; $string.Replace("$replace1",'')}| foreach{$string = "$_ "; $string.Replace("$replace2",'')})
    $DBA8K = ($data | Select-String -Pattern ">DBA8K"| foreach{$string = "$_ "; $string.Replace("$replace1",'')}| foreach{$string = "$_ "; $string.Replace("$replace2",'')})
    $DATA32K = ($data | Select-String -Pattern ">DATA32K"| foreach{$string = "$_ "; $string.Replace("$replace1",'')}| foreach{$string = "$_ "; $string.Replace("$replace2",'')})
    $REFINDEX8K = ($data | Select-String -Pattern ">REFINDEX8K"| foreach{$string = "$_ "; $string.Replace("$replace1",'')}| foreach{$string = "$_ "; $string.Replace("$replace2",'')})
    $REFDATA8K = ($data | Select-String -Pattern ">REFDATA8K"| foreach{$string = "$_ "; $string.Replace("$replace1",'')}| foreach{$string = "$_ "; $string.Replace("$replace2",'')})
    $array += "$bbb $uptime_begin $uptime_current_day $uptime_total $BUFFERPOOL8k"
    $array += "$bbb $uptime_begin $uptime_current_day $uptime_total $IBM"
    $array += "$bbb $uptime_begin $uptime_current_day $uptime_total $DATA8k"
    $array += "$bbb $uptime_begin $uptime_current_day $uptime_total $DATA32K"
    $array += "$bbb $uptime_begin $uptime_current_day $uptime_total $REFINDEX8K"
    $array += "$bbb $uptime_begin $uptime_current_day $uptime_total $REFDATA8K"
    $array += "$bbb $uptime_begin $uptime_current_day $uptime_total $DBA8K"
    rm "$file"
    $array | Add-Content "C:\Users\chq-davidwe\Documents\Projects\web-stuff\results\results-ETMS.txt"
