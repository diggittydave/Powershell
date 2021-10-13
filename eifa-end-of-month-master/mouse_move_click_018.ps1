##############################################################################################################################################
#SCRIPT: EIFA_END_OF_MONTH.ps1
#SYSTEM: Windows/Eifa
#DESC: CREATES AND INTERACTS WITH MULTIPLE DESKTOP SESSIONS TO PERFORM MONTH END POPULATION CONTROL ACROSS ALL EIFA SITES
#LIMITS:
#SCRIPT_ID"
#AUTHOR        DATE          STATUS
#
#chq-davidwe   01/22/2019    initial write up
#chq-davidwe   01/25/2019    creation of sessions loop
#chq-davidwe   02/07/2019    creation of date-get function to check the current date and build arrays based on branch time zone
#chq-davidwe   02/07/2019    thoroughly create notes for individual functions
#chq-davidwe   02/07/2019    Rename functions and create Branch-Close function and loop
#chq-davidwe   02/07/2019    added log file functionality.
#chq-davidwe   02/12/2019    added full email functionality
###############################################################################################################################################
#define variables.
$executingScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent #allows execution of script from any directory
$popCtrl = "$executingScriptDirectory\Eifa_end_of_Month_012.eds" #sets the base desktop script file.
$closePeriod = "$executingScriptDirectory\Eifa_Close_Period_004.eds" #sets the base close period script file.
$user = $env:USERNAME #gets current logged in username to add to log files.
$date = Get-Date -UFormat %y%m%d%H #gets the date in YYMMDDHH format useable in file naming.
$logFile = "MONTH_END_LOG_FILE_$hour.txt" #sets logfile name.
$i=0 #counting integer.
$csv = @(Import-Csv $executingScriptDirectory\branch_time.csv) #csv containing the branch code and the associated GMT zone.
$branches = @() #creates an empty array for the date-get funtion to add too for the Branch-Windows function to run against.
$close = @() #creates empty array for for the date-get function to add too for the close-period function to run against.
$hour = ((get-date).ToUniversalTime().ToString("HH")).ToInt32($null)#gets the current hour of the day and sets it to an integer.
$day = ((get-date).ToUniversalTime().ToString("dd")).ToInt32($null) #gets the current day of the month and sets it to an integer.
$minute =((get-date).ToUniversalTime().ToString("mm")).ToInt32($null)
###########################################Functions setups###################################################################################
Function Date-Get{
    #check if utc day is = 1 meaning first of the month.
    if($day -eq 5){
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
Function Start-DesktopSession{
    #great new shell object
    $wshell = New-Object -ComObject wscript.shell
    #open DESKTOP APPLICATION and grab the handle for the app windows
    #NOTE NOTE NOTE
    #This line will need to changed to be specific to the PC where the script is run
    #Alternatively, this could be configured to read a config file
    #NOTE NOTE NOTE
    $app = Start-Process "C:\Program Files (x86)\Expeditors\Desktop\Desktop.exe" "http://qa1.chq.ei:8008/desktop/DesktopServlet" -passthru
    #Login. Wait 4 seconds for Desktop to process login information before moving on
    $wshell.AppActivate($app.Id)
    sleep 5
    $pass = ConvertFrom-SecureString 
    $wshell.SendKeys("$passWord{ENTER}")
    sleep 4
}
#creates sessions based on the $branches array. Kicks off the .eds script on the session and closes when finished.
Function Branch-PopCtrl{
    $wshell = New-Object -ComObject wscript.shell
    $Pos = [System.Windows.Forms.Cursor]::Position
    $x = 370
    $y = 10
    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($x, $y)
    #Import user32.dll to simulate moust clicks
    Add-Type -MemberDefinition '[DllImport("user32.dll")] public static extern void mouse_event(int flags, int dx, int dy, int cButtons, int info);' -Name U32 -Namespace W;
    #click mouse to open luanch item menu
    [W.U32]::mouse_event(6,370,10,0,0)
    #wait for menu to load
    sleep 1
    #position mouse of "EIFA Configurable" Launch item
    $Pos = [System.Windows.Forms.Cursor]::Position
    $x = 370
    $y = 100
    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($x, $y)
    #click to open launch item
    [W.U32]::mouse_event(6,370,80,0,0)
    #wait for item to open
    sleep 4
    [void][System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
    $wshell.AppActivate($app.Id)
    #enter credential and template
    $wshell.SendKeys("$branch{TAB}")
    sleep 1
    $wshell.SendKeys("mgr{TAB}")
    sleep 1
    $wshell.SendKeys("{TAB}")
    sleep 1
    $wshell.SendKeys("eifa{ENTER}")
    sleep 5
    #open script prompt un comment when finished coding loop
    $wshell.SendKeys("^{p}")
    sleep 5
    #run script and wait for completion
    $wshell.SendKeys("Eifa_end_of_Month_011.eds")
    sleep 1
    $wshell.SendKeys("{ENTER}")
    sleep 20
    ####################################
    #exit screen
    $wshell.SendKeys("{F8}")
    sleep 3
}
#creates sessions based on the $close array. Kicks off the .eds script on the session and closes when finished.
Function Branch-Close{
    $wshell = New-Object -ComObject wscript.shell
    $Pos = [System.Windows.Forms.Cursor]::Position
    $x = 370
    $y = 10
    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($x, $y)
    #Import user32.dll to simulate moust clicks
    Add-Type -MemberDefinition '[DllImport("user32.dll")] public static extern void mouse_event(int flags, int dx, int dy, int cButtons, int info);' -Name U32 -Namespace W;
    #click mouse to open luanch item menu
    [W.U32]::mouse_event(6,370,10,0,0)
    #wait for menu to load
    sleep 1
    #position mouse of "EIFA Configurable" Launch item
    $Pos = [System.Windows.Forms.Cursor]::Position
    $x = 370
    $y = 100
    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($x, $y)
    #click to open launch item
    [W.U32]::mouse_event(6,370,80,0,0)
    #wait for item to open
    sleep 4
    [void][System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
    $wshell.AppActivate($app.Id)
    #enter credential and template
    $wshell.SendKeys("$branch{TAB}")
    sleep 1
    $wshell.SendKeys("mgr{TAB}")
    sleep 1
    $wshell.SendKeys("{TAB}")
    sleep 1
    $wshell.SendKeys("eifa{ENTER}")
    sleep 5
    #open script prompt un comment when finished coding loop
    $wshell.SendKeys("^{p}")
    sleep 5
    #run script and wait for completion
    #this will need to be updated to match the "close_period" script.
    $wshell.SendKeys("EIFA_Close_Period_002.eds")      
    sleep 1
    $wshell.SendKeys("{ENTER}")
    sleep 20
    ####################################
    #exit screen
    $wshell.SendKeys("{F8}")
    sleep 3
}
#creates log file and updates the script to match.
Function Setup-LogFiles{
    New-Item -Path $executingScriptDirectory -Name "$logFile" -ItemType "file" -Force
}

#Condenses and creates a single log file and emails.
Function Send-Log{
    $files = @(ls -Path $executingScriptDirectory -Name *.txt)
    $combinedFile = "$executingScriptDirectory\MonthEndReport.txt"
    foreach($element in $files){
        $stuff = $element
        (Get-Content "$stuff")|?{$_.trim() -ne ""}|Set-Content -LiteralPath "$stuff" -Force -Encoding Ascii
        "$stuff"|add-Content -LiteralPath "$combinedFile" -Force -Encoding Ascii
        (Get-Content $stuff)|Add-Content -LiteralPath "$combinedFile" -Force -Encoding Ascii
    }
    $from = "EifaHelpDesk@expeditors.com"
    $to = "david.weber@expeditors.com"
    $subject = "End Of Month results"
    $body = @(Get-Content $combinedFile)
    $smtp = "exch-smtp.expeditors.com"
    Send-MailMessage -From "$from" -To "$to" -Subject "$subject" -Attachments "$combinedFile" -SmtpServer "$smtp" -Body "$body"
}

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
