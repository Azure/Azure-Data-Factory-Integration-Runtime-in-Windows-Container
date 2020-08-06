$DmgcmdPath = "C:\Program Files\Microsoft Integration Runtime\4.0\Shared\dmgcmd.exe"

function Check-Node-Connection() {
    Start-Process $DmgcmdPath -Wait -ArgumentList "-cgc" -RedirectStandardOutput "C:\SHIR\status-check.txt"
    $ConnectionResult = Get-Content "C:\SHIR\status-check.txt"
    Remove-Item -Force "C:\SHIR\status-check.txt"

    if ($ConnectionResult -like "Connected") {
        return $TRUE
    }
    else {
        exit 1
    }
}

if (Check-Node-Connection) {   
    exit 0
}