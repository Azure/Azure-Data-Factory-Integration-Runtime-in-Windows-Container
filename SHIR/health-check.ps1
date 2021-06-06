$DmgcmdPath = "C:\Program Files\Microsoft Integration Runtime\5.0\Shared\dmgcmd.exe"

function Run-Process([string] $process, [string] $arguments)
{
	Write-Verbose "Run-Process: $process $arguments"
	
	$errorFile = "$env:tmp\tmp$pid.err"
	$outFile = "$env:tmp\tmp$pid.out"
	"" | Out-File $outFile
	"" | Out-File $errorFile	

	$errVariable = ""

	if ([string]::IsNullOrEmpty($arguments))
	{
		$proc = Start-Process -FilePath $process -Wait -Passthru -NoNewWindow `
			-RedirectStandardError $errorFile -RedirectStandardOutput $outFile -ErrorVariable errVariable
	}
	else
	{
		$proc = Start-Process -FilePath $process -ArgumentList $arguments -Wait -Passthru -NoNewWindow `
			-RedirectStandardError $errorFile -RedirectStandardOutput $outFile -ErrorVariable errVariable
	}
	
	$errContent = [string] (Get-Content -Path $errorFile -Delimiter "!!!DoesNotExist!!!")
	$outContent = [string] (Get-Content -Path $outFile -Delimiter "!!!DoesNotExist!!!")

	Remove-Item $errorFile
	Remove-Item $outFile

	if($proc.ExitCode -ne 0 -or $errVariable -ne "")
	{		
		Throw-Error "Failed to run process: exitCode=$($proc.ExitCode), errVariable=$errVariable, errContent=$errContent, outContent=$outContent."
	}

	if ([string]::IsNullOrEmpty($outContent))
	{
		return $outContent
	}

	return $outContent.Trim()
}
function Check-Node-Connection() {

    $ConnectionResult = Run-Process $DmgcmdPath "-cgc"

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