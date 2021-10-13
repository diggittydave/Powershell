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

    # SIG # Begin signature block
# MIIOXQYJKoZIhvcNAQcCoIIOTjCCDkoCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUWb1nfH3p0H8yiQ0KOKqMiQhH
# LmqgggvEMIIFUDCCAzigAwIBAgIBCzANBgkqhkiG9w0BAQsFADBdMQswCQYDVQQG
# EwJVUzETMBEGA1UECgwKRXhwZWRpdG9yczEUMBIGA1UECwwLSVMgU2VjdXJpdHkx
# IzAhBgNVBAMMGkV4cGVkaXRvcnMgQ29kZSBTaWduaW5nIENBMB4XDTE4MTAyMzIy
# MDMxMFoXDTM4MDcxMDIyMDMxMFowgYwxCzAJBgNVBAYTAlVTMRMwEQYDVQQKDApF
# eHBlZGl0b3JzMScwJQYDVQQLDB5JUy1DdXN0b21zIEFwcGxpY2F0aW9uIFN1cHBv
# cnQxFDASBgNVBAMMC0RhdmlkIFdlYmVyMSkwJwYJKoZIhvcNAQkBFhpEYXZpZC5X
# ZWJlckBleHBlZGl0b3JzLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
# ggEBAMqtwf/MAOxiUlEG0WXNS7DPZ+huGdfrO12MHbUf1Dx0EOvm4+iMCnDv1nbV
# Fa6aIdJ41L1huvM880D4Dj9acIDa+TvWl/Bp/tDPC4z5Zs8OQsS50L4MU7VZf/tc
# 4i+N9gZjWa324vkFLj/WWZ+2cVk1EmV6LtCU6pZgbZE65OKUcbDYAXpo/YmTgOOz
# y2suRFiRL8NR3m45UEEwf5Q60J7qr7xnWg/fEQlSnZS9wQw0iJOc9aggtnm5NbL8
# gvZdN2tSL+zFLZLGYTonMMAw+1SPdd8fMhAZp1hvvxtz2LT+AOQlooSmepDD3u3T
# ZmygOYKM50hhlAYLjXuFZAQFuB0CAwEAAaOB6jCB5zAOBgNVHQ8BAf8EBAMCB4Aw
# CQYDVR0TBAIwADATBgNVHSUEDDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQUDceLgvHI
# /9WMfva+Tvrk6yIu06QwHwYDVR0jBBgwFoAUCUbgxP6iMUQTqLPfwKxNyeRfa3Qw
# PwYIKwYBBQUHAQEEMzAxMC8GCCsGAQUFBzAChiNodHRwOi8vcGtpLmNocS5laS9j
# b2Rlc2lnbi0yMDE1LmNlcjA0BgNVHR8ELTArMCmgJ6AlhiNodHRwOi8vcGtpLmNo
# cS5laS9jb2Rlc2lnbi0yMDE1LmNybDANBgkqhkiG9w0BAQsFAAOCAgEAE6+R2qQ1
# B29ahz3odP4dbEbu1EGYT9SpbvGEw+lF0HqSrA9Xb2va34K1YdQdwAbcGYBFnV6P
# zsAc9dtu27aDAEet/v9SJVMPjLiL2es9uLI7ASJCzdUJYqQOJT0lZthg+3bLT+bU
# R2DkkjNuebEyuGNdNRMD7DpeJuuAP5eWPHZZYKI4RpnPv4hYq3yQjEn3shEtrY2j
# Bk9mWSP4bbJkGMr/+CgKFGOV1QgF56cQVwuN7KFUwLXUq/Y5OXQY0hU2eDn6eccR
# UfYIQpUB69eIOnfrtVnCoUpzk0REhlm92zIJM8n1J1WToH6prtyxlpuVqwDvocUm
# RMRZNjQ28xq6li7KTWI9TVOufqsapUcjybs6Ebvo0oHnF2Gu3dljj+wDms7MMvbU
# MKtsRB9xpT4c7yY5LJQreh6uDhR9ayWU+KOoBAL1UAfmaSA8516jzxz/Ro3OcX7U
# jMMQEdUpCsYWkP7cYo/HwZceyipVjIz0RsDxvwsgyBaW5Nyj5jaLHv3Ll1sX174c
# msbl94hWVIvABNamYE/6Aguo/OwYAgfnon8Plh4JryWjM/r+zDrnf8BXaKO7crxv
# aG8bLVk6pQfhxeA9rDu3X8gSlfzKxXG7xS/f+s1Q8havLvXSb/G2l/0HcizaYana
# kfnBYO7N5dfVaEYSQu4t64Ksb6BoW17/8eowggZsMIIEVKADAgECAgEFMA0GCSqG
# SIb3DQEBCwUAMFoxCzAJBgNVBAYTAlVTMRMwEQYDVQQKDApFeHBlZGl0b3JzMRQw
# EgYDVQQLDAtJUyBTZWN1cml0eTEgMB4GA1UEAwwXRXhwZWRpdG9ycyAyMDE1IFJv
# b3QgQ0EwHhcNMTUwNTE0MTg1ODQxWhcNMzUwMTI5MTg1ODQxWjBdMQswCQYDVQQG
# EwJVUzETMBEGA1UECgwKRXhwZWRpdG9yczEUMBIGA1UECwwLSVMgU2VjdXJpdHkx
# IzAhBgNVBAMMGkV4cGVkaXRvcnMgQ29kZSBTaWduaW5nIENBMIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEA4tlIdovnVUqhqexvjlRyTfxMQPrm8ZWnexqP
# RKeEJLRqYITRqVd2XQYVUB1IC6mUwajt05LwB/rlRI26aHwrONaGo1Bhw5LwpTxI
# WPztvKl+GyMmaW9I8kEuN10JKFGIaMAQwcVr5EpvQO1tbOuo4hqBe0Z3Eqvmy9Yh
# SMr5es6I5hw1K7lzk3X/SgFZvhuDaMSwtMTzhYhcVfXtpS4kmTjyQGf7dBGoOB40
# gUHxIENQc1zq30G30dT7B5HK8ezXUsg4Gp0fZFY5DIStsp9kILX5DtKYfR1QQJta
# yoFHbcpIs6FPaboVlVQOZUhZ5vPCV3nlWNPSb0FFHwuhje++1QqD1vDjq9p3N1R8
# f9+/TMpHaaHXSF2AAcQMtFcze2af2NVapxNZXYDIhAEWkbCBlQf4EEyyLw1V5A5i
# VTU06DQjCVQm0wGvvsBgw9Yyd19dxDzKdA6N1leUo6XtQeawQ+J1xQ0Lpx87Xb6r
# h5DdJh+Z1gJqcSZypAIPeK3xwqLyZzcvQ3tvjwsOEwryGx+xtYJ8CC1NyNH+TZ2n
# D5Zww33Ykk24xK+hIn5Vt6iIOeZ7eqq3/UtjEjxv/ZvPPsBvVYolBlAHY+nIJKkD
# LxB+V3kpWslG+uMAqOyZUnPfYX2gTcaVBtNLWp+1zNHciquH+kUkAxcHlmk6khCS
# 2TGU19ECAwEAAaOCATgwggE0MA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFAlG
# 4MT+ojFEE6iz38CsTcnkX2t0MIGCBgNVHSMEezB5gBTK/GkUKGAYiyUMgnG/ni4L
# fML0A6FepFwwWjELMAkGA1UEBhMCVVMxEzARBgNVBAoMCkV4cGVkaXRvcnMxFDAS
# BgNVBAsMC0lTIFNlY3VyaXR5MSAwHgYDVQQDDBdFeHBlZGl0b3JzIDIwMTUgUm9v
# dCBDQYIBATAOBgNVHQ8BAf8EBAMCAQYwOwYIKwYBBQUHAQEELzAtMCsGCCsGAQUF
# BzAChh9odHRwOi8vcGtpLmNocS5laS9yb290LTIwMTUuY2VyMDAGA1UdHwQpMCcw
# JaAjoCGGH2h0dHA6Ly9wa2kuY2hxLmVpL3Jvb3QtMjAxNS5jcmwwDQYJKoZIhvcN
# AQELBQADggIBAEcZa8ef+qBMqc6aadV74UrQVGJemDsEbK1ghu3SpDwWFYO9VtUk
# CTvNKba+k+X8deBmPvQbNe9UqVhQnt/kGabm+/FgJZ4DeZuR7hMVr7z0th1ZDEkK
# qU3ThgpWyMib4HCieDkykgzM6ph3LnU0azo9NSrFfifaBq0oIf6DAkm2RvsGHUGx
# YfuEx7/knN7tAXYGdhLqSL7HZlj5D9zSwsalIC+oFj34ljGlv2dEkEpadymkpn2e
# FiypQwRDV6SJXiF3Z0hfHAuNFofe+sleNufo+jEE5w309muQreRPAHToC07+oTof
# ilLAhjPSfnF+462u4U4G06SzjHGFz8zxJ+IJSRSVClDCFRGmNEom5l1ATDLQrxmz
# Bhr6Ui4+6hgApChjDJcCALd63cpwxcHy4hjY8XGPXcDdvwhR0NNlykBjXODvWO8y
# rs5EF/gPqU82rPlaRFTne7A9emUcbehGz5WCluEWswWB8abdIAtJlFYWnLowtirL
# I4CKYBmLuc0YG+Iw1z3r72CQxTa9Vz3AU30RvO82d56q3aiywMXlscB1LAA4MzLF
# f5fx1VEjlL3BRyMcerHZE882hHD+P/uUn71oR2MCcus9Co3xm5+2HJjtaxB3BUpc
# hTYCAttDQXfspeMZXpI20a1MNSyTDwlhBB8UbgaafFg+LghgxpD7dxhfMYICAzCC
# Af8CAQEwYjBdMQswCQYDVQQGEwJVUzETMBEGA1UECgwKRXhwZWRpdG9yczEUMBIG
# A1UECwwLSVMgU2VjdXJpdHkxIzAhBgNVBAMMGkV4cGVkaXRvcnMgQ29kZSBTaWdu
# aW5nIENBAgELMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAA
# MBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgor
# BgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBR66tyil7Gi5Vgzk5d8rPU+FaJNvDAN
# BgkqhkiG9w0BAQEFAASCAQCnq0zpHdvfMxyyNgahsbXQb5iZLd2fEp0C68inX5zG
# G6U+iAZsqu5hlUPa/do7U6i+ekBsJYkUj5a9A5KsBw57AQcHZiE2MIsM5uSlLRfh
# 8SoeIHRIdUYgdYSzT73oyKBoj3r2A8aX1H+vmVfAvwx1a9rzvxT+YLN7W8zEbeyO
# mdf3+Q8m8NiTcYOS//7a47zpBaxIx0eny9T/cpTT0xUdKrqpLoeWndTd/vlIni/K
# BihsJBfcPLhMjHdxfw3q6ssxQO0NbtoTE6KOnsH46/5ZPSvDgGc/FbeWfsjf26P/
# PJdVvr7dEUKgUJmRCFRfwBvWnX8ZrNbqn64H+yb9kYfu
# SIG # End signature block
