function Is-64BitSystem
{
     $computerName = $env:COMPUTERNAME
     $osBit = (get-wmiobject win32_processor -computername $computerName).AddressWidth
     return $osBit -eq '64'
}

function Get-RegistryKeyValue
{
     param($registryPath)

     $is64Bits = Is-64BitSystem
     if($is64Bits)
     {
          $baseKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry64)
          return $baseKey.OpenSubKey($registryPath)
     }
     else
     {
          $baseKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry32)
          return $baseKey.OpenSubKey($registryPath)
     }
}

function Get-CmdFilePath()
{
    $filePath = Get-ItemPropertyValue "hklm:\Software\Microsoft\DataTransfer\DataManagementGateway\ConfigurationManager" "DiacmdPath"
    if ([string]::IsNullOrEmpty($filePath))
    {
        throw "Get-InstalledFilePath: Cannot find installed File Path"
    }

    # dmgcmd performs the same functions but has return error messages and exit codes and is the preferred cmd to use.
    $filePath = $filePath -replace "diacmd","dmgcmd"
    return $filePath
}

function Get-RedirectedUrl 
{
    # SHIR 5.4.7749.1
    $URL = "https://go.microsoft.com/fwlink/?linkid=839822"
 
    $request = [System.Net.WebRequest]::Create($url)
    $request.AllowAutoRedirect=$false
    $response=$request.GetResponse()
 
    If ($response.StatusCode -eq "Found")
    {
        $response.GetResponseHeader("Location")
    }
}

function Populate-Url
{
    Param (
        [Parameter(Mandatory=$true)]
        [String]$version
    )
    
    $uri = Get-RedirectedUrl
    $uri = $uri.Substring(0, $uri.LastIndexOf('/') + 1)
    $uri += "IntegrationRuntime_$version"
    $uri += ".msi"

    return $uri
}

function Download-GatewayInstaller
{
    Param (
        [Parameter(Mandatory=$true)]
        [String]$version
    )

    Write-Host "Start to download MSI"
    $uri = Populate-Url $version
    $output = "$PSScriptRoot\IntegrationRuntime.msi"
    Write-Host $uri
    (New-Object System.Net.WebClient).DownloadFile($uri, $output)

    $exist = Test-Path($output)
    if ( $exist -eq $false)
    {
        throw "Cannot download specified MSI"
    }

    $msg = "New gateway MSI has been downloaded to " + $output
    Write-Host $msg
    return $output
}

function Get-LatestGatewayVersion()
{
    $latestGateway = Get-RedirectedUrl "https://go.microsoft.com/fwlink/?linkid=839822"
    $item = $latestGateway.split("/") | Select-Object -Last 1
    if ($null -eq $item -or $item -notlike "IntegrationRuntime*")
    {
        throw "Can't get latest gateway info"
    }

    $regexp = '^IntegrationRuntime_(\d+\.\d+\.\d+\.\d+)\.msi$'

    $version = [regex]::Match($item, $regexp).Groups[1].Value
    if (!$version)
    {
        throw "Can't get version from gateway download uri"
    }

    $msg = "Latest gateway: " + $version
    Write-Host $msg
    return $version
}