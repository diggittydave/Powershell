param(
        [string]$bbb
    )
    $branch = "$bbb"
    $array = @()
    $replace1 = '</SPAN><SPAN STYLE="background-color: #C0C0C0">'
    $replace2 = '</SPAN><SPAN STYLE="background-color: #E0E0E0">'
    $file = "C:\Users\chq-davidwe\Documents\Projects\web-stuff\results\$branch-BRDB.txt"
    $data = Get-Content "$file"
    $uptime_string = ($data |Select-String -Pattern "1: $bbb.$bbb.ei")
    $uptime_array = @($uptime_string -split " ")
    $uptime_begin = $uptime_array[8]
    $uptime_current_day = $uptime_array[11]
    $uptime_total = $uptime_array[14]
    $4k = ($data | Select-String -Pattern ">USER4K"| foreach{$string = "$_ "; $string.Replace("$replace1",'')}| foreach{$string = "$_ "; $string.Replace("$replace2",'')})
    $8K = ($data | Select-String -Pattern ">USER8K"| foreach{$string = "$_ "; $string.Replace("$replace1",'')}| foreach{$string = "$_ "; $string.Replace("$replace2",'')})
    $array += "$bbb $uptime_begin $uptime_current_day $uptime_total $4k"
    $array += "$bbb $uptime_begin $uptime_current_day $uptime_total $8K"
    rm "$file"
    $array | Add-Content "C:\Users\chq-davidwe\Documents\Projects\web-stuff\results\Results-BRDB.txt"

 
