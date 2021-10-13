<#############++$i#################################################################################################################################SCRIPT: EIFA_END_OF_MONTH.ps1SYSTEM: Windows/EifaDESC: CREATES AND INTERACTS WITH MULTIPLE DESKTOP SESSIONS TO PERFORM MONTH END POPULATION CONTROL ACROSS ALL EIFA SITESLIMITS:SCRIPT_ID"AUTHOR        DATE          STATUSchq-davidwe   01/22/2019    Initial write upchq-davidwe   01/25/2019    Creation of sessions loopchq-davidwe   02/07/2019    Creation of date-get function to check the current date and build arrays based on branch time zonechq-davidwe   02/07/2019    Thoroughly create notes for individual functionschq-davidwe   02/07/2019    Rename functions and create Branch-Close function and loopchq-davidwe   02/07/2019    Added log file functionality.chq-davidwe   02/12/2019    Added full email functionalitychq-davidwe   04/24/2019    Updated logging function to write to generic folder on C drive.chq-davidwe   05/10/2019    Updated date math functionality. Re-wrote email functionality.chq-davidwe   05/31/2019    Rewrote to run using regions and script type input by user.chq-davidwe   07/10/2019    Removed email function. Logging is now dropped directly into nas folder.chq-davidwe   08/28/2019    Made changes to closePeriod script path and adjusted to run in production.###############################################################################################################################################>#define variables.$executingScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent #allows execution of script from any directory$resend = "F:\IMPORT SUPPORT SHARED\David\Eifa_End_of_Month\User_activated_by_region\Eifa_end_of_Month_Resend_003.eds" #sets the base desktop script file.$closePeriod = "F:\IMPORT SUPPORT SHARED\David\Eifa_End_of_Month\User_activated_by_region\Eifa_end_of_Month_Close_Period_004.eds"$user = $env:USERNAME #gets current logged in username to add to log files.$date = Get-Date -UFormat %y%m%d%H #gets the date in YYMMDDHH format useable in file naming.$branches = @() #creates an empty array for the date-get funtion to add too for the Branch-Windows function to run against.
$csv = @(Import-Csv 'F:\IMPORT SUPPORT SHARED\David\Eifa_End_of_Month\User_activated_by_region\branch_time.csv') #csv containing the branch code and the associated GMT zone.
$hour = ((get-date).ToUniversalTime().ToString("HH")).ToInt32($null)#gets the current hour of the day and sets it to an integer.
$day = ((get-date).ToUniversalTime().AddDays(1).ToString("dd")).ToInt32($null) #gets the current day of the month and sets it to an integer.
$minute =((get-date).ToUniversalTime().ToString("mm")).ToInt32($null)
$path = "F:\IMPORT SUPPORT SHARED\David\Eifa_End_of_Month\User_activated_by_region\Logs"
$logFile = "MONTH_END_LOG_FILE.txt" #sets logfile name.$log = "F:\IMPORT SUPPORT SHARED\David\Eifa_End_of_Month\User_activated_by_region\Logs\$logFile"
$from = "EfiaHelpDesk@expeditors.com"
$to = "david.weber@expeditors.com"
$subject = "End of Month Results"
$smtp = "exch-smtp.expeditors.com"
###########################################Functions setups###################################################################################[void] [System.Reflection.Assembly]::LoadWithPartialName("system.drawing")[void] [System.Reflection.Assembly]::LoadWithPartialName("system.windows.forms")Function branch-Get{    param(    [string]$region)    $i=0
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
Function Start-DesktopSession{    #great new shell object    $wshell = New-Object -ComObject wscript.shell    <#    NOTE NOTE NOTE    Open DESKTOP APPLICATION and grab the handle for the app windows    This line will need to changed to be specific to the PC where the script is run    Alternatively, this could be configured to read a config file    NOTE NOTE NOTE    #>    $app = Start-Process "C:\Program Files (x86)\Expeditors\Desktop\Desktop.exe" "http://chq.chq.ei:8008/desktop/DesktopServlet" -passthru    #Login. Wait 4 seconds for Desktop to process login information before moving on    $wshell.AppActivate($app.Id)    sleep 5    $wshell.SendKeys("$passWord{ENTER}")    sleep 4
}
#creates sessions based on the $branches array. Kicks off the .eds script on the session and closes when finished.
Function Branch-PopCtrl{    param(    [string]$branch,    [string]$popCtrl    )    $wshell = New-Object -ComObject wscript.shell    $Pos = [System.Windows.Forms.Cursor]::Position    $x = 370    $y = 10    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($x, $y)
    #Import user32.dll to simulate moust clicks
    Add-Type -MemberDefinition '[DllImport("user32.dll")] public static extern void mouse_event(int flags, int dx, int dy, int cButtons, int info);' -Name U32 -Namespace W;
    #click mouse to open luanch item menu
    [W.U32]::mouse_event(6,370,10,0,0)
    #wait for menu to load
    sleep 1
    #position mouse of "EIFA Configurable" Launch item
    $Pos = [System.Windows.Forms.Cursor]::Position    $x = 370    $y = 315    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($x, $y)
    #click to open launch item
    [W.U32]::mouse_event(6,370,80,0,0)
    #wait for item to open
    sleep 4
    [void][System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
    $wshell.AppActivate($app.Id)
    #enter credential and template
    $wshell.SendKeys("$branch{ENTER}")#change {tab} to {Enter} for prod    sleep 5
    #open script prompt un comment when finished coding loop
    $wshell.SendKeys("^{p}")    sleep 2
    #run script and wait for completion    $wshell.AppActivate($app.Id)    $wshell.SendKeys("$popCtrl")    sleep 1    $wshell.SendKeys("{ENTER}")    sleep 120    ####################################
    #exit screen
    $wshell.AppActivate($app.Id)
    $wshell.SendKeys("{F8}")    sleep 1    $wshell.SendKeys("{F8}")    sleep 1
}Function Compress-logs{    param(    [string]$path    )    $files = @(ls -Path $path -Name *.txt)
    Foreach($element in $files){
        $stuff = $element
        (Get-Content "$path\$stuff")|?{$_.trim() -ne ""}|Set-Content -LiteralPath "$path\$stuff" -Force -Encoding Ascii
    }}Function Log-Cleanup{    param(    [string]$path    )    Compress-Archive -Path $path\*.txt -DestinationPath $path\History.zip -CompressionLevel Optimal -Update    Remove-Item -Path $path\*.txt }###################################### ACTUAL WORK IS DONE HERE##############################################################################
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUHUxX4NrcUBYtmiQbH5dNH/PP
# XcGgggvEMIIFUDCCAzigAwIBAgIBCzANBgkqhkiG9w0BAQsFADBdMQswCQYDVQQG
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
# BgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTuklmz5yjWaM7yxz/a8B3kG+GPRzAN
# BgkqhkiG9w0BAQEFAASCAQBWBkfVjTT7tnxO6i3XJrWpC0w29BwDiJbvcDmnSgHn
# Hp36q5bCSI+92vtFtwuOs7jK/392c5dyfU0pdZ+gsyv1SD3vj2SWJ98OkL2GaXUh
# HU/4+U4PTg1G77GTqvu67uG/7NMvpz2O/k9aI+wFFmL0Vf0uJEmP/0VfllnTXpQk
# 5X1bEmDyV4lDEbVUMy/Pm8T2a4jmvV9SnOujKQXbgdugp0M+4p8Xqw9k57i1t6tl
# nzbJlAhL2u9+I82Goe7jhDJvJdzkvsPwq88LqTPpMM9F0+y4gXdAaZhRlmFDCNWa
# h5d9UMUqzni1O7YwITFxPq8W48ighSDWu42eP2xvkYBo
# SIG # End signature block
