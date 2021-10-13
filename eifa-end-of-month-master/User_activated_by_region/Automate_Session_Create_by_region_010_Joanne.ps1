﻿<#############++$i#################################################################################################################################
$csv = @(Import-Csv 'F:\IMPORT SUPPORT SHARED\David\Eifa_End_of_Month\User_activated_by_region\branch_time.csv') #csv containing the branch code and the associated GMT zone.
$hour = ((get-date).ToUniversalTime().ToString("HH")).ToInt32($null)#gets the current hour of the day and sets it to an integer.
$day = ((get-date).ToUniversalTime().AddDays(1).ToString("dd")).ToInt32($null) #gets the current day of the month and sets it to an integer.
$minute =((get-date).ToUniversalTime().ToString("mm")).ToInt32($null)
$path = "F:\IMPORT SUPPORT SHARED\David\Eifa_End_of_Month\User_activated_by_region\Logs"
$logFile = "MONTH_END_LOG_FILE.txt" #sets logfile name.
$from = "EfiaHelpDesk@expeditors.com"
$to = "david.weber@expeditors.com"
$subject = "End of Month Results"
$smtp = "exch-smtp.expeditors.com"
###########################################Functions setups###################################################################################
    Do{
        if($csv.region[$i] -eq $region){
            $add = $csv.BRANCH[$i]
            $script:branches += $add
            ++$i
        }
        else{
            ++$i
        }
    }
    until($i -eq $csv.Branch.Count)
}
#creates the initial desktop session
Function Start-DesktopSession{
}
#creates sessions based on the $branches array. Kicks off the .eds script on the session and closes when finished.
Function Branch-PopCtrl{
    #Import user32.dll to simulate moust clicks
    Add-Type -MemberDefinition '[DllImport("user32.dll")] public static extern void mouse_event(int flags, int dx, int dy, int cButtons, int info);' -Name U32 -Namespace W;
    #click mouse to open luanch item menu
    [W.U32]::mouse_event(6,370,10,0,0)
    #wait for menu to load
    sleep 1
    #position mouse of "EIFA Configurable" Launch item
    $Pos = [System.Windows.Forms.Cursor]::Position
    #click to open launch item
    [W.U32]::mouse_event(6,370,80,0,0)
    #wait for item to open
    sleep 4
    [void][System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
    $wshell.AppActivate($app.Id)
    #enter credential and template
    $wshell.SendKeys("$branch{ENTER}")#change {tab} to {Enter} for prod
    #open script prompt un comment when finished coding loop
    $wshell.SendKeys("^{p}")
    #run script and wait for completion
    #exit screen
    $wshell.AppActivate($app.Id)
    $wshell.SendKeys("{F8}")
}
    param(
    [sting]$From,
    [string]$To,
    [string]$Subject,
    [string]$Log
    )
    $body = @(Get-Content $Log)
    Send-MailMessage -from "$from" -to "$to" -Subject "$subject" -SmtpServer "$smtp" -Body "$body"
}
    Foreach($element in $files){
        $stuff = $element
        (Get-Content "$path\$stuff")|?{$_.trim() -ne ""}|Set-Content -LiteralPath "$path\$stuff" -Force -Encoding Ascii
    }
if(!(Get-Process -Name Desktop)){
    $passWord = Read-Host "password"
    Start-DesktopSession
    }
sleep 1
$region = (Read-Host "What region are we working in?")
branch-Get -region $region
"What action are we taking?"
;"Enter 1 for Resend"
;"Enter 2 for close period";
$eds = (Read-Host)
switch($eds){
    '1'{
    $script:popCtrl = $resend
    }
    '2'{
    $script:popCtrl = $closePeriod
    }
}
Foreach($element in $branches){
    $branch = "$element"
    "$branch" |Add-Content -LiteralPath "$log" -Force -Encoding Ascii
    "Running :"|Add-Content -LiteralPath "$log" -Force -Encoding Ascii
    "$popCtrl" |Add-Content -LiteralPath "$log" -Force -Encoding Ascii
    Branch-PopCtrl -branch $branch -popCtrl $popCtrl
    sleep 5
}

Compress-logs

# SIG # Begin signature block
# MIIOXQYJKoZIhvcNAQcCoIIOTjCCDkoCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUusZpKbITv3V+orOCSU3gRZ7N
# XaSgggvEMIIFUDCCAzigAwIBAgIBCzANBgkqhkiG9w0BAQsFADBdMQswCQYDVQQG
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
# BgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRb9XcK1nzp5lPOLls68MZ6fB+X2zAN
# BgkqhkiG9w0BAQEFAASCAQBK6fBxCN4cHSHnf6ZnS29KdzWz7rEXtklfgUemAgvz
# llBUvLhdumHOK/rqZvRfXnIIJwIpId+3o5hvnKKou4wOnsGPQ8f1JDTMa02SqTqc
# EGqhtNqVdX/GyahLSUfr1hCv5xhSKg0+E/rYxIJ17WaOiq8TF9d6mPuJGzi5g7Mw
# HtiXHrnAbjHrxvcRxq+jhcQObBj8VU/G1rawsKUYj/IxzNdQ8BXUXcgQ+1/r8ik1
# ivG88b4gxcVSY+VxlFc4dEmhnFJzJ3vNrJj8Huo75iba/kJyFKopASKuoNjd1u88
# ctmqgbu/W/CTdU+OKuY6A4swNkwU9xWASqBWqv0mr6Sq
# SIG # End signature block