#EDI CDF UPDATE TOOL
# This script was written by David Weber for the EDI Support team completed on 12/5/2018
# This script is intended to help automate the CDF update process and reduce workload
# For issues, please contact david.weber@expeditors.com
#Previous versions are available in the SVN repository
#Debug mode line follows.
#comment out the debug line when in production
#Set-PSDebug -ErrorAction SilentlyContinue
#Primary script setup
Get-PSSnapin -Registered | Add-PSSnapin -PassThru #add in the cmdlet snapin for warning and error popups
Add-Type -AssemblyName PresentationFramework #add in the cmdlet snapin for warning and error popups
$executingScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent #this line allows the script to be run from any directory or as a shortcut
$fso= new-object -ComObject scripting.filesystemobject #this line allows for the creation of new folders if needed.
####################### Function setups ####################################################################################
Function Select-UpdateFile # Selects the update CSV via file browser
{
    $openFileDialog = New-Object windows.forms.openfiledialog   
    $openFileDialog.initialDirectory = [System.IO.Directory]::GetCurrentDirectory()   
    $openFileDialog.title = "Select the CSV File to Import"   
    $openFileDialog.filter = "All files (*.*)| *.*"   
    $openFileDialog.filter = "PublishSettings Files|*.csv|All Files|*.*" 
    $openFileDialog.ShowHelp = $True   
    Write-Host "Select GL Codes update CSV File... (see FileOpen Dialog)" -ForegroundColor Green  
    $result = $openFileDialog.ShowDialog()   # Display the Dialog / Wait for user response 
    # in ISE you may have to alt-tab or minimize ISE to see dialog box 
    #$result
    If($result -eq "OK")    
        {    
        $openFileDialog.filename   
        $OpenFileDialog.CheckFileExists    
        Write-Host "You're GL Codes file has been set!" -ForegroundColor Green 
        Write-Host "To reset this file, exit and restart the script" -ForegroundColor Green
        Start-Sleep 2        
        }
    Else
        {
        Write-Host "GL CODE FILE NOT FOUND" -ForegroundColor Red
        Write-Host "EXITING IN 5 SECONDS" -ForegroundColor Red
        start-sleep 5
        exit
        }
    
} 
Function Find-WorkingCopyFolder # selects your working copy path. Currently this is how Gen or Web is determined
{
    [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    [System.Windows.Forms.Application]::EnableVisualStyles()
    $browse = New-Object System.Windows.Forms.FolderBrowserDialog
    $browse.SelectedPath = "$PATH"
    $browse.ShowNewFolderButton = $true
    $browse.Description = "Select a directory"
    Write-Host "Select Working Copy Folder...(see FolderOpen box)" -ForegroundColor Green
    $loop = $true
    while($loop)
    {
        If ($browse.ShowDialog() -eq "OK")
        {
        $loop = $false
		#Insert your script here
		}
        Else
            {
            $res = [System.Windows.Forms.MessageBox]::Show("You clicked Cancel. Would you like to try again or exit?", "Select a location", [System.Windows.Forms.MessageBoxButtons]::RetryCancel)
            If($res -eq "Cancel")
            {
                #Ends script
                exit
            }
        }
    }
    $browse.SelectedPath
    $browse.Dispose()
}
Function Pause # push to continue process so users can see log of what just occured
{
[void](Read-host "Press Enter to continue...") 
} 
Function Update-WorkingCopy # updates your local working copy to the prod version
{
    svn info $WorkingCopy
    svn update $WorkingCopy
    } 
Function Commit-Changes # Sends the changes to the repository
{
ForEach ($element in $MASTERLIST)
    {
    $item = $element
    svn commit -m "Changes made for ticket or request number $ticket by user $user" -N "$WorkingCopy\$item"
    }
}
Function Release-Lock # releases the lock.
{
ForEach($element in $MASTERLIST)
    {
    $unlock = "$element"
    svn unlock "$WorkingCopy\$unlock"
    }
}
Function Revert-Changes # will revert any changes made If process is exited early
{
    svn status -v "$WorkingCopy"
    svn revert -R "$WorkingCopy\*"
    Write-Host "Files have been restored to the previous version"
    Start-sleep 2
    } 
Function Lock-Files # locks all files checked out of repository.
{
    ForEach($element in $MASTERLIST)
        {        
        $lock = "$element"
        svn lock -m "Locked for Billing Update" $WorkingCopy\$lock
        #"$lock was locked for billing update on $date">>$logname
        }
} 
Function Verify-files # Verifies the files in the update request also exist in the repository
{
ForEach($element in $MASTERLIST)
    {
    $trace = "$WorkingCopy\$element"
    if (ls -Path $trace -ErrorAction SilentlyContinue)
        {
        Write-Host "$trace found" -ForegroundColor Green
        Write-Host "moving on" -ForegroundColor Green
        Continue
        }
    Else
        {
        $msgBoxInput = [System.Windows.MessageBox]::show('WARNING: FILE '+$trace+' NOT FOUND. DO YOU WANT TO CONTINUE?','ERROR-MESSAGE','YesNo','Error')
        switch ($msgBoxInput)
            {
            'Yes'
                {
                write-host "$trace not found in working copy">> $logname -ForegroundColor Black -BackgroundColor Red
                Continue
                }
            'No'
                {
                Exit
                }
            }
        }
    }
}
Function WriteTo-Files # writes descriptions from csv into each cdf
{
$J = $MASTERLIST.COUNT
$K = $UPDATEFILE.COUNT
$L = $DESCRIPTION.COUNT
$I = 0
$A = 0
WHILE ($I -LE $K)
    {
    If($UPDATEFILE[$I] -ccontains $MASTERLIST[$A])
        {
        $UPDATE = $UPDATEFILE[$I]
        $DESC = $DESCRIPTION[$I]
        $literalpath = "$WorkingCopy\$UPDATE"
        Add-Content -Value $DESCRIPTION[$I] -Path $literalpath -Encoding Ascii
        "$DESC has been added to $UPDATE" >> $logname
        $I++
        If($UPDATEFILE[$I] -cnotcontains $MASTERLIST[$A])
            {
            $ITEM = $MASTERLIST[$A]
            WRITE-HOST "DONE WITH $ITEM"
            "DONE WITH "+$ITEM+" @ "+(Get-Date)+" By User:"+$user >> $logname
            $A++
            }
        }
    Else
        {
        $I++
        }
    }
}
Function Sort-CDFData # Sorts the CDF based on the first column header
{    
    ForEach($element in $MASTERLIST)
        {
        $UPDATE= "$element"
        $file = "$workingCopy\$UPDATE"
        $d = @(get-content $file)
        $matchBefore = Select-String -InputObject $d -Pattern "," -AllMatches
        $commasBefore = $matchBefore.Matches.Count
        Write-Host "Commas Before $commasBefore"
        $CONTENT = @(import-csv "$file")
        $HEADERS = $CONTENT[0].PSOBJECT.PROPERTIES | ForEach{$_.NAME}
        $SORT = $HEADERS[0]
        $CONTENT | Sort-Object -Property $SORT | Export-Csv "$file" -NoTypeInformation
        (Get-Content "$file" )|ForEach-Object{$_ -replace '"',''}| Set-Content "$file" -Force -Encoding Ascii ##stripping closing commas
        $f = @(Get-Content $WorkingCopy\$update)
        $matchAfter = select-string -InputObject $f -Pattern "," -AllMatches
        $commasAfter = $matchAfter.Matches.Count
        Write-Host "commas after $commasAfter"
        if ($commasBefore -gt $commasAfter)#adds commas if they were stripped
            {(get-content "$file")|ForEach-Object{$string="$_";$string.Replace("$string","$string,")}|set-content "$file" -Force -Encoding Ascii}
        Write-Host "$UPDATE is now sorted"
        Write-Host "Continuing on"
        }
    }
Function Show-MainMenu # menu function
{
    param (
           [string]$Title = "EDI'S SECRET CDF UPDATE TOOL"
          )
     cls
     Write-Host "================ $Title ================" -BackgroundColor Black
     
     write-host "Your working copy is:                                                " -ForegroundColor black -BackgroundColor green
     write-host "$WorkingCopy" -ForegroundColor black -BackgroundColor yellow
     
     Write-host "Your GL Code file is:                                                " -ForegroundColor black -backgroundcolor green
     write-host  $GLCodes[0] -ForegroundColor black -BackgroundColor Yellow
     write-host "                                                                     " -BackgroundColor Black
     write-host "                                                                     " -BackgroundColor Black
     Write-Host "U: Press 'U' to update your current working copy.                    " -ForegroundColor Yellow -BackgroundColor Black
     write-host "                                                                     " -BackgroundColor Black
     Write-Host "1: Press '1' to VerIfy Files.                                        " -ForegroundColor Green -BackgroundColor Black
     Write-Host "2: Press '2' to lock the files needing update.                       " -ForegroundColor Green -BackgroundColor Black
     write-host "                                                                     " -BackgroundColor Black
     write-host "                                                                     " -BackgroundColor Black
     Write-Host "4: Press '4' to write changes to files                               " -ForegroundColor Yellow -BackgroundColor Black
     Write-Host "5: Press '5' to Sort the file data                                   " -ForegroundColor Yellow -BackgroundColor Black
     write-host "                                                                     " -BackgroundColor Black
     Write-Host "6: Press '6' to commit the changes to the repository                 " -ForegroundColor black -BackgroundColor Red
     write-host "                                                                     " -BackgroundColor Black
     Write-Host "0: Press '0' to release the locks on the files.                      " -ForegroundColor Green -BackgroundColor Black
     write-host "                                                                     " -BackgroundColor Black
     Write-Host "R: Press 'R' to revert all changes. This only works before commiting." -ForegroundColor Black -BackgroundColor Red
     write-host "                                                                     " -BackgroundColor Black
     Write-Host "Q: Press 'Q' to quit.                                                " -BackgroundColor Black
}
######################## Set up primary variables and get input data################################
$date = Get-Date -uformat %y%m%d
$user = $env:USERNAME
$ticket = Read-host "What ticket or request number are you working on?"
$PATH = $executingScriptDirectory
$logname = "C:\Users\$user\Documents\$date.$ticket.log"
Get-Date >> $logname
$PATH >> $logname
$user >> $logname
$WorkingCopy = Find-WorkingCopyFolder
$glCodes = Select-UpdateFile
$glCodes[0]>>$logname
$CSV = import-csv ($glCodes[0])
$MASTERLIST = @($CSV.CDF_TO_UPDATE_MASTER_LIST | ? {$_})
$UPDATEFILE = @($CSV.CDF_TO_UPDATE)
$DESCRIPTION= @($CSV.DESCRIPTIONS_TO_ADD)
############################  Execute menu functions########################################
Do #primary function loop
{
Show-MainMenu 
$input = read-host "Please make a selection."
switch($input) #switch options for menu
    {
    'u'#update working copy
        {
        Update-WorkingCopy
        Pause
        }
    '1'#VerIfy files
        {
        Verify-files
        WRITE-HOST "FILES HAVE BEEN VERIfIED" -ForegroundColor Green
        Pause
        }
    '2'#Lock files
        {
        Lock-Files
        Pause
        }
    '4'#make the changes to the cdfs
        {
        WriteTo-Files    
        Pause
        }
    '5'#sort the changes into the proper places
        {
        Sort-CDFData
        Pause       
        }
    '6'#Commit changes to the repository
        {
        Commit-Changes -foreground
        Pause -foregroundcolor GREEN
        }
    '0'#Release locks
        {
        Release-Lock
        Pause
        }
    'r'#Revert changes If mistakes are made
        {
        Revert-Changes
        Pause
        }
    }
}
While($input -ne 'q')
