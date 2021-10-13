Get-PSSnapin -Registered | Add-PSSnapin -PassThru
Add-Type -AssemblyName PresentationFramework
$executingScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$fso= new-object -ComObject scripting.filesystemobject
$resultsPath = "$executingScriptDirectory\Results"
$who = $ENV:USERNAME
#####################################################
function Install-Posh                               #
{                                                   #
$modules = @(Get-Module -ListAvailable)             #
if ($modules.Name -ccontains "Posh-SSH")            #
    {                                               #
    Write-host "Posh-SSH Found, Moving On"          #
    }                                               #
Else                                                #
    {Install-Module Posh-SSH}                       #
}                                                   #
#####################################################
Function stream-jobs #creates the multiple threads to contact the individual branches. Each thread creates a text file with results.
{
    $maxThreads = 10
    ForEach($element in $Branches){
        while((Get-Job -State Running).count -ge $maxThreads){start-sleep 1}
        $branch = "$element"
        Start-Job -ScriptBlock { . $args[4] -branch $args[0] -job $args[1] -credential $args[2] -resultsfolder $args[3]} -ArgumentList "$branch", $multi_user, $credential, "$resultspath", "$executingScriptDirectory\User_audit_job_003.ps1"
        Write-Host "running on $branch"
    }
}

Function Create-Csv #Uses the text results from the individual threads and creates a csv. Removes original txt for less confusion.
{
    #Identify text files available
    $files = @(ls -Path $resultsPath -Name *.txt)
    #edit the text files to csv's
    foreach($element in $files){
        $stuff = "$resultsPath\$element"
        (Get-Content "$stuff")|?{$_.trim() -ne ""}|Set-Content -LiteralPath "$stuff" -Force -Encoding Ascii
        (Get-Content "$stuff")|Foreach-Object{$_ -replace ' {2,}',','}|Set-Content "$stuff" -Force -Encoding ASCII
        (Get-Content "$stuff")|Foreach-Object{$_ -replace ' ',','}|Set-Content "$stuff.csv" -Force -Encoding ASCII
    }
    #header names
    $h1="File";$h2="Time";$h3="pid";$h4="action";$h5="user";$h6="SystemUser";
    $h7="SystemInitials";$h8="Delete1";$h9="Delete2";$h10="Program";
    #gets the orignal csvs and edits them down to useable columns/data.
    $csvs = @(ls -Path $resultsPath -name *.csv)
    foreach($element in $csvs){
        $thing = "$resultsPath\$element"
        (Import-Csv $thing -Header $h1,$h2,$h3,$h4,$h5,$h6,$h7,$h8,$h9,$h10)|Export-Csv $thing -NoTypeInformation -Force
    }
    Start-Sleep 1
    #remove the old text files
    Foreach($element in $files){
        $delete = "$resultsPath\$element"
        Remove-Item -LiteralPath "$delete" -Force
    }
}
Function Merge-CSVFiles{
    Param(
    $CSVPath = "$resultsPath", ## Soruce CSV Folder
    $XLOutput= "$resultsPath\CombinedResults.xlsx" ## Output file name
    )
    $csvFiles = Get-ChildItem ("$CSVPath\*") -Include *.csv
    $Excel = New-Object -ComObject excel.application 
    $Excel.visible = $false
    $Excel.sheetsInNewWorkbook = $csvFiles.Count
    $workbooks = $excel.Workbooks.Add()
    $CSVSheet = 1
    Foreach ($CSV in $Csvfiles){
        $worksheets = $workbooks.worksheets
        $CSVFullPath = $CSV.FullName
        $SheetName = ($CSV.name -split "\.")[0]
        $worksheet = $worksheets.Item($CSVSheet)
        $worksheet.Name = $SheetName
        $TxtConnector = ("TEXT;" + $CSVFullPath)
        $CellRef = $worksheet.Range("A1")
        $Connector = $worksheet.QueryTables.add($TxtConnector,$CellRef)
        $worksheet.QueryTables.item($Connector.name).TextFileCommaDelimiter = $True
        $worksheet.QueryTables.item($Connector.name).TextFileParseType  = 1
        $worksheet.QueryTables.item($Connector.name).Refresh()
        $worksheet.QueryTables.item($Connector.name).delete()
        $worksheet.UsedRange.EntireColumn.AutoFit()
        $CSVSheet++
        }
    $workbooks.SaveAs($XLOutput,51)
    $workbooks.Saved = $true
    $workbooks.Close()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbooks) | Out-Null
    $excel.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    start-sleep 1
    ForEach($element in $csvFiles){
        $deleteCsv = "$element"
        Remove-Item -LiteralPath "$deleteCsv" -Force
    }
    Start-Sleep 1
    Copy-Item -Path "$resultsPath\CombinedResults.xlsx" -Destination "C:\Users\$env:USERNAME\Desktop\CombinedResults.xlsx" -Force
    start-sleep 1
    Remove-Item -path "$resultsPath\CombinedResults.xlsx" -Force
}
Function Closing-Message{
    $messageBox = [System.Windows.MessageBox]::show('Your results are located at C:\Users\'+$env:USERNAME+'\Desktop\CombinedResults.xlsx.','MESSAGE','Ok','Error')
    switch ($msgBoxInput)
        {
            'Ok'
            {
                exit
            }
        }
}

##################  work block ##############################
#check for and install ssh function
Install-Posh

#gets the users login credentials as an object. This is only available while the 
$credential = Get-Credential

#initialize user array
$multi_user= @()

do{
    $input =(read-host "list the usernames. Hit enter after each name.")
    if($input -ne ''){
        $multi_user += $input
    }      
}
until($input -eq '')
$Branches = @(get-content "$executingScriptDirectory\allProdEtmsServers.txt")
$resultsPath = "$executingScriptDirectory\Results"
stream-jobs
while((get-job -State Running) -ne $null){start-sleep 1}
Create-Csv
start-sleep 1
Merge-CSVFiles
Start-Sleep 1
Closing-Message
start-sleep 1
# SIG # Begin signature block
# MIIOXQYJKoZIhvcNAQcCoIIOTjCCDkoCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU/yEquorvK0/yG+qLy6qbPqP/
# Dv2gggvEMIIFUDCCAzigAwIBAgIBCzANBgkqhkiG9w0BAQsFADBdMQswCQYDVQQG
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
# BgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQXzI1HDcEFR1pBHszcqpU4g4kDZzAN
# BgkqhkiG9w0BAQEFAASCAQBYl7fIJQDRbpzq/UOuWdt8MQnM2cK34yitlvBe7yuL
# XPP9sEmDFpffc0XH+EKCWyaXwvlX7qUr024vXDq/exj3S2DQAgE+0CyoYVon49Vq
# WAzcXVgaaawctS7jMSaohxyjLMWb6zrYeN/Rr/tVkUADzGk5Wm/afXrWIMZxTuds
# 7Pyk5RT2VNRKyVVeI9onmGJfxQix1KgMCKOeCdp+NLVISy3zd4l9eHREw6C3uhag
# /rS/gBtKeJrPx/krUVQJpcdAAmY1/IJ7m15LiLZnyscKFuNg1ohDVgtGogEqWrqU
# OYl1+gBcfHbghlJbZCfIE9Z12prXtm69wTaUCLjN76I5
# SIG # End signature block
