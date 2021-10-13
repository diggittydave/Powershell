param(
    [string]$branch,
    [array]$job,
    $credential,
    [string]$resultsfolder
)

Get-PSSnapin -Registered | Add-PSSnapin -PassThru

Add-Type -AssemblyName PresentationFramework


$fso= new-object -ComObject scripting.filesystemobject

if(Test-Connection -ComputerName "$branch" -Quiet){
    $session = "$branch"
    $results = "$resultsfolder\User_Audit_Results_$session.txt"
    New-SSHSession -ComputerName "$branch" -Credential $credential -port 22 -AcceptKey
    $h = @(Get-SSHSession -ComputerName "$session")
    $b = $h.SessionId
    foreach($element in $job){
        $command = "gzgrep '$element' /logs/tipsi/tipsi.log.*"
        $line = @(Invoke-SSHCommand -SessionId $b -timeout 9999 -Command "$command" |Select-Object -ExpandProperty Output)
            Foreach($element in $line){
                if($element -ne ""){Add-Content $element -literalPath $results -Force -Encoding Ascii}
            }
        }   
    Remove-SSHSession -SessionId $b
}

