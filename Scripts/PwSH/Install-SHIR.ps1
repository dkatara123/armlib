param(
$authKey = "",
$path = "C:\Softwares",
$outFilePath = "$path\IntegrationRuntime_5.12.7984.1.msi",
$installerURL = "https://download.microsoft.com/download/E/4/7/E4771905-1079-445B-8BF9-8A1A075D8A10/IntegrationRuntime_5.12.7984.1.msi"
)


function Download-Gateway()
{
    If(!(test-path $path))
    {
      New-Item -ItemType Directory -Force -Path $path
    }
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $installerURL -OutFile $outFilePath
}

function Install-Gateway([string] $gwPath)
{
    # uninstall any existing gateway
    UnInstall-Gateway

    Write-Host "Start Microsoft Integration Runtime installation"
    
    $process = Start-Process "msiexec.exe" "/i $outFilePath /quiet /passive" -Wait -PassThru
    if ($process.ExitCode -ne 0)
    {
        throw "Failed to install Microsoft Integration Runtime. msiexec exit code: $($process.ExitCode)"
    }
    Start-Sleep -Seconds 30	

    Write-Host "Succeed to install Microsoft Integration Runtime"
}

function Register-Gateway([string] $key)
{
    $cmd = Get-CmdFilePath
    Write-Host "Start to register Microsoft Integration Runtime with key: $key."
    $process = Start-Process $cmd "-k $key" -Wait -PassThru -NoNewWindow
    if ($process.ExitCode -ne 0)
    {
        throw "Failed to register Microsoft Integration Runtime. Exit code: $($process.ExitCode)"
    }
    Write-Host "Succeed to register Microsoft Integration Runtime."
}

function Check-WhetherGatewayInstalled([string]$name)
{
    $installedSoftwares = Get-ChildItem "hklm:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
    foreach ($installedSoftware in $installedSoftwares)
    {
        $displayName = $installedSoftware.GetValue("DisplayName")
        if($DisplayName -eq "$name Preview" -or  $DisplayName -eq "$name")
        {
            return $true
        }
    }

    return $false
}


function UnInstall-Gateway()
{
    $installed = $false
    if (Check-WhetherGatewayInstalled("Microsoft Integration Runtime"))
    {
        [void](Get-WmiObject -Class Win32_Product -Filter "Name='Microsoft Integration Runtime Preview' or Name='Microsoft Integration Runtime'" -ComputerName $env:COMPUTERNAME).Uninstall()
        $installed = $true
    }

    if (Check-WhetherGatewayInstalled("Microsoft Integration Runtime"))
    {
        [void](Get-WmiObject -Class Win32_Product -Filter "Name='Microsoft Integration Runtime Preview' or Name='Microsoft Integration Runtime'" -ComputerName $env:COMPUTERNAME).Uninstall()
        $installed = $true
    }

    if ($installed -eq $false)
    {
        Write-Host "Microsoft Integration Runtime is not installed."
        return
    }

    Write-Host "Microsoft Integration Runtime has been uninstalled from this machine."
}

function Get-CmdFilePath()
{
    $filePath = Get-ItemPropertyValue "hklm:\Software\Microsoft\DataTransfer\DataManagementGateway\ConfigurationManager" "DiacmdPath"
    if ([string]::IsNullOrEmpty($filePath))
    {
        throw "Get-InstalledFilePath: Cannot find installed File Path"
    }

    return (Split-Path -Parent $filePath) + "\dmgcmd.exe"
}
Download-Gateway
Install-Gateway $outFilePath
Register-Gateway $authKey