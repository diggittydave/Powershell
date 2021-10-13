###############################################################################################################################################SCRIPT: EIFA_END_OF_MONTH.ps1#SYSTEM: Windows/Eifa#DESC: CREATES AND INTERACTS WITH MULTIPLE DESKTOP SESSIONS TO PERFORM MONTH END POPULATION CONTROL ACROSS ALL EIFA SITES#LIMITS:#SCRIPT_ID"#AUTHOR        DATE          STATUS##chq-davidwe   01/22/2019    initial write up#chq-davidwe   01/25/2019    creation of sessions loop#chq-davidwe   02/07/2019    creation of date-get function to check the current date and build arrays based on branch time zone#chq-davidwe   02/07/2019    thoroughly create notes for individual functions#chq-davidwe   02/07/2019    Rename functions and create Branch-Close function and loop#chq-davidwe   02/07/2019    added log file functionality.#chq-davidwe   02/12/2019    added full email functionality################################################################################################################################################define variables.$executingScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent #allows execution of script from any directory$popCtrl = "$executingScriptDirectory\Eifa_end_of_Month_012.eds" #sets the base desktop script file.$closePeriod = "$executingScriptDirectory\Eifa_Close_Period_004.eds" #sets the base close period script file.$user = $env:USERNAME #gets current logged in username to add to log files.$date = Get-Date -UFormat %y%m%d%H #gets the date in YYMMDDHH format useable in file naming.$logFile = "MONTH_END_LOG_FILE_$hour.txt" #sets logfile name.$i=0 #counting integer.
$csv = @(Import-Csv $executingScriptDirectory\branch_time.csv) #csv containing the branch code and the associated GMT zone.
$branches = @() #creates an empty array for the date-get funtion to add too for the Branch-Windows function to run against.
$close = @() #creates empty array for for the date-get function to add too for the close-period function to run against.
$hour = ((get-date).ToUniversalTime().ToString("HH")).ToInt32($null)#gets the current hour of the day and sets it to an integer.
$day = ((get-date).ToUniversalTime().ToString("dd")).ToInt32($null) #gets the current day of the month and sets it to an integer.
$minute =((get-date).ToUniversalTime().ToString("mm")).ToInt32($null)
###########################################Functions setups###################################################################################Function Date-Get{    #check if utc day is = 1 meaning first of the month.    if($day -eq 5){
        #start walking the csv array
        While ($i -le $csv.Count){
            #sets the value pulled from the array as a useable variable
            $time = ($csv.TIME[$i]).ToInt32($null)
            #if the time at the branch is = 1am, adds the branch code to the $branches array
            if(($hour-$time) -eq 1){
                $branches += $csv.BRANCH[$i]
            }
            #if the time at the branch is = 2am, adds the branch code to the $close array
            if(($hour-$time) -eq 2){
                $close += $csv.BRANCH[$i]
            }
            #itterates upward
            ++$i
        }
    }
}
#creates the initial desktop session
Function Start-DesktopSession{    #great new shell object    $wshell = New-Object -ComObject wscript.shell    #open DESKTOP APPLICATION and grab the handle for the app windows    #NOTE NOTE NOTE    #This line will need to changed to be specific to the PC where the script is run    #Alternatively, this could be configured to read a config file    #NOTE NOTE NOTE    $app = Start-Process "C:\Program Files (x86)\Expeditors\Desktop\Desktop.exe" "http://qa1.chq.ei:8008/desktop/DesktopServlet" -passthru    #Login. Wait 4 seconds for Desktop to process login information before moving on    $wshell.AppActivate($app.Id)    sleep 5    $pass = ConvertFrom-SecureString     $wshell.SendKeys("$passWord{ENTER}")    sleep 4
}
#creates sessions based on the $branches array. Kicks off the .eds script on the session and closes when finished.
Function Branch-PopCtrl{    $wshell = New-Object -ComObject wscript.shell    $Pos = [System.Windows.Forms.Cursor]::Position    $x = 370    $y = 10    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($x, $y)
    #Import user32.dll to simulate moust clicks
    Add-Type -MemberDefinition '[DllImport("user32.dll")] public static extern void mouse_event(int flags, int dx, int dy, int cButtons, int info);' -Name U32 -Namespace W;
    #click mouse to open luanch item menu
    [W.U32]::mouse_event(6,370,10,0,0)
    #wait for menu to load
    sleep 1
    #position mouse of "EIFA Configurable" Launch item
    $Pos = [System.Windows.Forms.Cursor]::Position    $x = 370    $y = 100    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($x, $y)
    #click to open launch item
    [W.U32]::mouse_event(6,370,80,0,0)
    #wait for item to open
    sleep 4
    [void][System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
    $wshell.AppActivate($app.Id)
    #enter credential and template
    $wshell.SendKeys("$branch{TAB}")    sleep 1
    $wshell.SendKeys("mgr{TAB}")    sleep 1
    $wshell.SendKeys("{TAB}")    sleep 1
    $wshell.SendKeys("eifa{ENTER}")    sleep 5
    #open script prompt un comment when finished coding loop
    $wshell.SendKeys("^{p}")    sleep 5
    #run script and wait for completion    $wshell.SendKeys("Eifa_end_of_Month_011.eds")    sleep 1    $wshell.SendKeys("{ENTER}")    sleep 20    ####################################
    #exit screen
    $wshell.SendKeys("{F8}")    sleep 3
}#creates sessions based on the $close array. Kicks off the .eds script on the session and closes when finished.Function Branch-Close{    $wshell = New-Object -ComObject wscript.shell    $Pos = [System.Windows.Forms.Cursor]::Position    $x = 370    $y = 10    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($x, $y)
    #Import user32.dll to simulate moust clicks
    Add-Type -MemberDefinition '[DllImport("user32.dll")] public static extern void mouse_event(int flags, int dx, int dy, int cButtons, int info);' -Name U32 -Namespace W;
    #click mouse to open luanch item menu
    [W.U32]::mouse_event(6,370,10,0,0)
    #wait for menu to load
    sleep 1
    #position mouse of "EIFA Configurable" Launch item
    $Pos = [System.Windows.Forms.Cursor]::Position    $x = 370    $y = 100    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($x, $y)
    #click to open launch item
    [W.U32]::mouse_event(6,370,80,0,0)
    #wait for item to open
    sleep 4
    [void][System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
    $wshell.AppActivate($app.Id)
    #enter credential and template
    $wshell.SendKeys("$branch{TAB}")    sleep 1
    $wshell.SendKeys("mgr{TAB}")    sleep 1
    $wshell.SendKeys("{TAB}")    sleep 1
    $wshell.SendKeys("eifa{ENTER}")    sleep 5
    #open script prompt un comment when finished coding loop
    $wshell.SendKeys("^{p}")    sleep 5
    #run script and wait for completion    #this will need to be updated to match the "close_period" script.    $wshell.SendKeys("EIFA_Close_Period_002.eds")          sleep 1    $wshell.SendKeys("{ENTER}")    sleep 20    ####################################
    #exit screen
    $wshell.SendKeys("{F8}")    sleep 3}
#creates log file and updates the script to match.
Function Setup-LogFiles{
    New-Item -Path $executingScriptDirectory -Name "$logFile" -ItemType "file" -Force
}#Condenses and creates a single log file and emails.Function Send-Log{    $files = @(ls -Path $executingScriptDirectory -Name *.txt)    $combinedFile = "$executingScriptDirectory\MonthEndReport.txt"    foreach($element in $files){        $stuff = $element        (Get-Content "$stuff")|?{$_.trim() -ne ""}|Set-Content -LiteralPath "$stuff" -Force -Encoding Ascii        "$stuff"|add-Content -LiteralPath "$combinedFile" -Force -Encoding Ascii        (Get-Content $stuff)|Add-Content -LiteralPath "$combinedFile" -Force -Encoding Ascii    }    $from = "EifaHelpDesk@expeditors.com"    $to = "david.weber@expeditors.com"    $subject = "End Of Month results"    $body = @(Get-Content $combinedFile)    $smtp = "exch-smtp.expeditors.com"    Send-MailMessage -From "$from" -To "$to" -Subject "$subject" -Attachments "$combinedFile" -SmtpServer "$smtp" -Body "$body"}
#RUN THROUGH FUNCTIONS AND LOOP
Setup-LogFiles
sleep 1
date-get
sleep 1
if(!(Get-Process -Name Desktop)){
    $passWord = Read-Host "password"
    Start-DesktopSession
    }
Foreach($element in $braches){
    $branch = "$element"
    "$branch" |Add-Content -LiteralPath "$executingScriptDirectory\$logFile" -Force -Encoding Ascii
    Branch-PopCtrl
    sleep 5
    }
Foreach($element in $close){
    $branch = "$element"
    "$branch" |Add-Content -LiteralPath "$executingScriptDirectory\$logFile" -Force -Encoding Ascii
    Branch-Close
    Sleep-5
    }
if($hour -ge 20){
    Send-Log
    }
# SIG # Begin signature block
# MIIOXQYJKoZIhvcNAQcCoIIOTjCCDkoCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUmdyj7tx1G+E5mlJ9PWUGh2OC
# v6ygggvEMIIFUDCCAzigAwIBAgIBCzANBgkqhkiG9w0BAQsFADBdMQswCQYDVQQG
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
# BgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRIICGY9qJeJvkpSTxF771nadRGCzAN
# BgkqhkiG9w0BAQEFAASCAQCTv7+4v0VNqAOLK8mYFTTRAjT7xOyHLb+OKuh1m+AX
# au3LoID2mzopvriZ72pV1znq2pR7e1K7YYdA09eGwGaXRN0x2hVXd7IXVeVglLLy
# oAqh7iMBTPXxuEAik99h2qfIm4Q7/MFQCvdOemvy/2qZZ83kKNrVoXa0BuiWly+r
# pv6EV3qq3mgQb137eU4LiQ1/E2HhNovvrdRj3JiVlvG36CssuYql1ml7f0qn24rJ
# 4Svei+tT1l/XHjtvyGjkX6hu6xMTbn6aQCbwd92ms38kUZgeF2LKkqtspVFCjHVL
# ymJNfUHESzsLlvW/ZVCwu/KLiop4Gn1UfWAgRe+9DhFe
# SIG # End signature block
