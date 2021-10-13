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

