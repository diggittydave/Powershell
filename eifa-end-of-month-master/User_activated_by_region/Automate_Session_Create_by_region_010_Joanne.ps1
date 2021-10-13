<#############++$i#################################################################################################################################
SCRIPT: EIFA_END_OF_MONTH.ps1
SYSTEM: Windows/Eifa
DESC: CREATES AND INTERACTS WITH MULTIPLE DESKTOP SESSIONS TO PERFORM MONTH END POPULATION CONTROL ACROSS ALL EIFA SITES
LIMITS:
SCRIPT_ID"

AUTHOR        DATE          STATUS

chq-davidwe   01/22/2019    Initial write up
chq-davidwe   01/25/2019    Creation of sessions loop
chq-davidwe   02/07/2019    Creation of date-get function to check the current date and build arrays based on branch time zone
chq-davidwe   02/07/2019    Thoroughly create notes for individual functions
chq-davidwe   02/07/2019    Rename functions and create Branch-Close function and loop
chq-davidwe   02/07/2019    Added log file functionality.
chq-davidwe   02/12/2019    Added full email functionality
chq-davidwe   04/24/2019    Updated logging function to write to generic folder on C drive.
chq-davidwe   05/10/2019    Updated date math functionality. Re-wrote email functionality.
chq-davidwe   05/31/2019    Rewrote to run using regions and script type input by user.
chq-davidwe   07/10/2019    Removed email function. Logging is now dropped directly into nas folder.
chq-davidwe   08/28/2019    Made changes to closePeriod script path and adjusted to run in production.
###############################################################################################################################################>
#define variables.
$executingScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent #allows execution of script from any directory
$resend = "F:\IMPORT SUPPORT SHARED\David\Eifa_End_of_Month\User_activated_by_region\Eifa_end_of_Month_Resend_003.eds" #sets the base desktop script file.
$closePeriod = "F:\IMPORT SUPPORT SHARED\David\Eifa_End_of_Month\User_activated_by_region\Eifa_end_of_Month_Close_Period_004.eds"
$user = $env:USERNAME #gets current logged in username to add to log files.
$date = Get-Date -UFormat %y%m%d%H #gets the date in YYMMDDHH format useable in file naming.
$branches = @() #creates an empty array for the date-get funtion to add too for the Branch-Windows function to run against.
$csv = @(Import-Csv 'F:\IMPORT SUPPORT SHARED\David\Eifa_End_of_Month\User_activated_by_region\branch_time.csv') #csv containing the branch code and the associated GMT zone.
$hour = ((get-date).ToUniversalTime().ToString("HH")).ToInt32($null)#gets the current hour of the day and sets it to an integer.
$day = ((get-date).ToUniversalTime().AddDays(1).ToString("dd")).ToInt32($null) #gets the current day of the month and sets it to an integer.
$minute =((get-date).ToUniversalTime().ToString("mm")).ToInt32($null)
$path = "F:\IMPORT SUPPORT SHARED\David\Eifa_End_of_Month\User_activated_by_region\Logs"
$logFile = "MONTH_END_LOG_FILE.txt" #sets logfile name.
$log = "F:\IMPORT SUPPORT SHARED\David\Eifa_End_of_Month\User_activated_by_region\Logs\$logFile"
$from = "EfiaHelpDesk@expeditors.com"
$to = "david.weber@expeditors.com"
$subject = "End of Month Results"
$smtp = "exch-smtp.expeditors.com"
###########################################Functions setups###################################################################################
[void] [System.Reflection.Assembly]::LoadWithPartialName("system.drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("system.windows.forms")
Function branch-Get{
    param(
    [string]$region)
    $i=0
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
    #great new shell object
    $wshell = New-Object -ComObject wscript.shell
    <#
    NOTE NOTE NOTE
    Open DESKTOP APPLICATION and grab the handle for the app windows
    This line will need to changed to be specific to the PC where the script is run
    Alternatively, this could be configured to read a config file
    NOTE NOTE NOTE
    #>
    $app = Start-Process "C:\Program Files (x86)\Expeditors\Desktop\Desktop.exe" "http://chq.chq.ei:8008/desktop/DesktopServlet" -passthru
    #Login. Wait 4 seconds for Desktop to process login information before moving on
    $wshell.AppActivate($app.Id)
    sleep 5
    $wshell.SendKeys("$passWord{ENTER}")
    sleep 4
}
#creates sessions based on the $branches array. Kicks off the .eds script on the session and closes when finished.
Function Branch-PopCtrl{
    param(
    [string]$branch,
    [string]$popCtrl
    )
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
    $y = 320
    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($x, $y)
    #click to open launch item
    [W.U32]::mouse_event(6,370,80,0,0)
    #wait for item to open
    sleep 4
    [void][System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
    $wshell.AppActivate($app.Id)
    #enter credential and template
    $wshell.SendKeys("$branch{ENTER}")#change {tab} to {Enter} for prod
    sleep 5
    #open script prompt un comment when finished coding loop
    $wshell.SendKeys("^{p}")
    sleep 2
    #run script and wait for completion
    $wshell.AppActivate($app.Id)
    $wshell.SendKeys("$popCtrl")
    sleep 1
    $wshell.SendKeys("{ENTER}")
    sleep 120
    ####################################
    #exit screen
    $wshell.AppActivate($app.Id)
    $wshell.SendKeys("{F8}")
    sleep 1
    $wshell.SendKeys("{F8}")
    sleep 1
}
Function Send-Logs{
    param(
    [sting]$From,
    [string]$To,
    [string]$Subject,
    [string]$Log
    )
    $body = @(Get-Content $Log)
    Send-MailMessage -from "$from" -to "$to" -Subject "$subject" -SmtpServer "$smtp" -Body "$body"
}
Function Compress-logs{
    param(
    [string]$path
    )
    $files = @(ls -Path $path -Name *.txt)
    Foreach($element in $files){
        $stuff = $element
        (Get-Content "$path\$stuff")|?{$_.trim() -ne ""}|Set-Content -LiteralPath "$path\$stuff" -Force -Encoding Ascii
    }
}
Function Log-Cleanup{
    param(
    [string]$path
    )
    Compress-Archive -Path $path\*.txt -DestinationPath $path\History.zip -CompressionLevel Optimal -Update
    Remove-Item -Path $path\*.txt 
}

###################################### ACTUAL WORK IS DONE HERE##############################################################################
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

