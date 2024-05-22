$DmgcmdPath = "C:\Program Files\Microsoft Integration Runtime\5.0\Shared\dmgcmd.exe"

function Check-Node-Connection() {
    $outputFile = "C:\SHIR\status-check-$([guid]::NewGuid().ToString()).txt"
    Start-Process $DmgcmdPath -Wait -ArgumentList "-cgc" -RedirectStandardOutput $outputFile
    $ConnectionResult = Get-Content $outputFile
    Remove-Item -Force $outputFile

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