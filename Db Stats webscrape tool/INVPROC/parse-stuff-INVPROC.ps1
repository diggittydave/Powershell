param(
        [string]$bbb
    )
    $who = $ENV:USERNAME
    $branch = "$bbb"
    $array = @()
    $replace1 = '</SPAN><SPAN STYLE="background-color: #C0C0C0">'
    $replace2 = '</SPAN><SPAN STYLE="background-color: #E0E0E0">'
    $file = "C:\Users\$who\Documents\Projects\web-stuff\results\$branch-INVPROC.txt"
    $data = Get-Content "$file"
    $uptime_string = ($data |Select-String -Pattern "1: $bbb.$bbb.ei")
    $uptime_array = @($uptime_string -split " ")
    $uptime_begin = $uptime_array[8]
    $uptime_current_day = $uptime_array[11]
    $uptime_total = $uptime_array[14]
    $IBM = ($data | Select-String -Pattern ">IBMDEFAULTBP"| ForEach-Object{$string = "$_ "; $string.Replace("$replace1",'')}| ForEach-Object{$string = "$_ "; $string.Replace("$replace2",'')})
    $DATA4K = ($data | Select-String -Pattern ">DATA4K"| ForEach-Object{$string = "$_ "; $string.Replace("$replace1",'')}| ForEach-Object{$string = "$_ "; $string.Replace("$replace2",'')})
    $DATA8k = ($data | Select-String -Pattern ">DATA8K"| ForEach-Object{$string = "$_ "; $string.Replace("$replace1",'')}| ForEach-Object{$string = "$_ "; $string.Replace("$replace2",'')})
    $DBA8K = ($data | Select-String -Pattern ">DBA8K"| ForEach-Object{$string = "$_ "; $string.Replace("$replace1",'')}| ForEach-Object{$string = "$_ "; $string.Replace("$replace2",'')})
    $DATA16K = ($data | Select-String -Pattern ">DATA16K"| ForEach-Object{$string = "$_ "; $string.Replace("$replace1",'')}| ForEach-Object{$string = "$_ "; $string.Replace("$replace2",'')})
    $DATA32K = ($data | Select-String -Pattern ">DATA32K"| ForEach-Object{$string = "$_ "; $string.Replace("$replace1",'')}| ForEach-Object{$string = "$_ "; $string.Replace("$replace2",'')})
    $INDEX8K = ($data | Select-String -Pattern ">INDEX8K"| ForEach-Object{$string = "$_ "; $string.Replace("$replace1",'')}| ForEach-Object{$string = "$_ "; $string.Replace("$replace2",'')})
    $INDEX4K = ($data | Select-String -Pattern ">INDEX4K"| ForEach-Object{$string = "$_ "; $string.Replace("$replace1",'')}| ForEach-Object{$string = "$_ "; $string.Replace("$replace2",'')})
    $array += "$bbb $uptime_begin $uptime_current_day $uptime_total $BUFFERPOOL8k"
    $array += "$bbb $uptime_begin $uptime_current_day $uptime_total $DATA4K"
    $array += "$bbb $uptime_begin $uptime_current_day $uptime_total $IBM"
    $array += "$bbb $uptime_begin $uptime_current_day $uptime_total $DATA8k"
    $array += "$bbb $uptime_begin $uptime_current_day $uptime_total $DATA32K"
    $array += "$bbb $uptime_begin $uptime_current_day $uptime_total $REFINDEX8K"
    $array += "$bbb $uptime_begin $uptime_current_day $uptime_total $REFDATA8K"
    $array += "$bbb $uptime_begin $uptime_current_day $uptime_total $DBA8K"
    $array += "$bbb $uptime_begin $uptime_current_day $uptime_total $DATA16K"
    $array += "$bbb $uptime_begin $uptime_current_day $uptime_total $INDEX8K"
    $array += "$bbb $uptime_begin $uptime_current_day $uptime_total $INDEX4K"
    Remove-Item "$file"
    $array | Add-Content "C:\Users\$who\Documents\Projects\web-stuff\results\results-INVPROC.txt"

