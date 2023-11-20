$DmgcmdPath = "C:\Program Files\Microsoft Integration Runtime\5.0\Shared\dmgcmd.exe"

function Write-Log($Message) {
    function TS { Get-Date -Format 'MM/dd/yyyy HH:mm:ss' }
    Write-Host "[$(TS)] $Message"
}

function Check-Is-Registered() {
    $result = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\DataTransfer\DataManagementGateway\ConfigurationManager' -Name HaveRun -ErrorAction SilentlyContinue
    if (($result -ne $null) -and ($result.HaveRun -eq 'Mdw')) {
        return $TRUE
    }
    return $FALSE
}

function Check-Main-Process() {
    $ProcessResult = Get-WmiObject Win32_Process -Filter "name = 'diahost.exe'"
    
    if ($ProcessResult) {
        return $TRUE
    }

    Write-Log "diahost.exe is not running"
    return $FALSE
}


function RegisterNewNode {
    Param(
        $AUTH_KEY,
        $NODE_NAME,
        $ENABLE_HA,
        $HA_PORT,
        $ENABLE_AE,
        $AE_TIME
    )

    Write-Log "Start registering a new SHIR node"
    Write-Log "Registering SHIR node with the node key: $($AUTH_KEY)"

    if (!$NODE_NAME) {
        $NODE_NAME = $Env:COMPUTERNAME
    }
    Write-Log "Registering SHIR node with the node name: $($NODE_NAME)"

    if ($ENABLE_HA -eq "true") {
        Write-Log "Enable High Availability"
        $PORT = $HA_PORT
        if (!$HA_PORT) {
            $PORT = "8060"
        }
        Write-Log "Remote Access Port: $($PORT)"
        Start-Process $DmgcmdPath -Wait -ArgumentList "-EnableRemoteAccessInContainer", "$($PORT)" -RedirectStandardOutput "C:\SHIR\register-out.txt" -RedirectStandardError "C:\SHIR\register-error.txt"
        Start-Sleep -Seconds 15
    }

    if ($ENABLE_AE -eq "true") {
        Write-Log "Enable Offline Nodes Auto-Expiration"
        if (!$AE_TIME) {
            $AE_TIME = 600
        }

        Write-Log "Node Expiration Time In Seconds: $($AE_TIME)"
        Start-Process $DmgcmdPath -Wait -ArgumentList "-RegisterNewNode", "$($AUTH_KEY)", "$($NODE_NAME)", "$($AE_TIME)" -RedirectStandardOutput "C:\SHIR\register-out.txt" -RedirectStandardError "C:\SHIR\register-error.txt"
        Start-Sleep -Seconds 15
    } else {
        Start-Process $DmgcmdPath -Wait -ArgumentList "-RegisterNewNode", "$($AUTH_KEY)", "$($NODE_NAME)" -RedirectStandardOutput "C:\SHIR\register-out.txt" -RedirectStandardError "C:\SHIR\register-error.txt"
    }

    $StdOutResult = Get-Content "C:\SHIR\register-out.txt"
    $StdErrResult = Get-Content "C:\SHIR\register-error.txt"

    if ($StdOutResult)
    {
        Write-Log "Registration output:"
        $StdOutResult | ForEach-Object { Write-Log $_ }
    }

    if ($StdErrResult)
    {
        Write-Log "Registration errors:"
        $StdErrResult | ForEach-Object { Write-Log $_ }
    }
}

# Register SHIR with key from Env Variable: AUTH_KEY
if (Check-Is-Registered) {
    Write-Log "Restart the existing node"

    if ((Test-Path Env:ENABLE_HA) -and ($Env:ENABLE_HA -eq "true")) {
        Write-Log "Enable High Availability"
        $PORT = $Env:$HA_PORT
        if (!$Env:HA_PORT) {
            $PORT = "8060"
        }
        Write-Log "Remote Access Port: $($PORT)"
        Start-Process $DmgcmdPath -Wait -ArgumentList "-EnableRemoteAccessInContainer", "$($PORT)"
        Start-Sleep -Seconds 15
    }

    Start-Process $DmgcmdPath -Wait -ArgumentList "-Start"
} elseif (Test-Path Env:AUTH_KEY) {
    Start-Process $DmgcmdPath -Wait -ArgumentList "-Start"

    RegisterNewNode $Env:AUTH_KEY $Env:NODE_NAME $Env:ENABLE_HA $Env:HA_PORT $Env:ENABLE_AE $Env:AE_TIME
} else {
    Write-Log "Invalid AUTH_KEY Value"
    exit 1
}

Write-Log "Waiting 60 seconds for connecting"
Start-Sleep -Seconds 60

try {
    $COUNT = 0
    $IS_REGISTERED = $FALSE
    while ($TRUE) {
        if(!$IS_REGISTERED) {
            if (Check-Is-Registered) {
                $IS_REGISTERED = $TRUE
                Write-Log "Self-hosted Integration Runtime is connected to the cloud service"
            }
        }

        if (Check-Main-Process) {
            $COUNT = 0
        } else {
            $COUNT += 1
            if ($COUNT -gt 5) {
                throw "Diahost.exe is not running"  
            }
        }

        Start-Sleep -Seconds 60
    }
}
finally {
    Write-Log "Stop the node connection"
    Start-Process $DmgcmdPath -Wait -ArgumentList "-Stop"
    Write-Log "Stop the node connection successfully"
    exit 0
}

exit 1