<#
.SYNOPSIS
    Creates and Upload files and folders to Azure Storage.
.DESCRIPTION
    This script is intended to create Azure Storage Account and Container if not created and upload files and folders.
.EXAMPLE
    PS C:\>Publish-ARMLibrary.ps1 -ResourceGroup "pdp-eus-d1-operations-rg" -StorageAccount "pdpeusd1artifactstg" -Container "armartifacts" -LiteralPath "C:\Users\shabuddinkhan\Downloads\Repos\Spectrum-ARM-Library" -IgnoredFiles *.metadata.json, *.ps1, *.parameters.json, *.log, *.vsdx, *.csv, *.md, *.png

    Explanation of what the example does
.EXAMPLE
    PS C:\>Publish-ARMLibrary.ps1 -ResourceGroup "pdp-eus-d1-operations-rg" -StorageAccount "pdpeusd1artifactstg" -Container "armartifacts" -LiteralPath "C:\Users\shabuddinkhan\Downloads\Repos\Spectrum-ARM-Library", "C:\Users\shabuddinkhan\Downloads\Repos\Spectrum_PDP_Infra" -IgnoredFiles *.metadata.json, *.parameters.json,*.log, *.vsdx, *.csv, *.md, *.png

    Explanation of what the example does
.EXAMPLE
    PS C:\>Publish-ARMLibrary.ps1 -ResourceGroup "pdp-eus-d1-operations-rg" -StorageAccount "pdpeusd1artifactstg" -Container "armartifacts" -LiteralPath "C:\Users\shabuddinkhan\Downloads\Repos\Spectrum-ARM-Library" -IgnoredFiles *.metadata.json, *.ps1, *.parameters.json, *.log, *.vsdx, *.csv, *.md, *.png

    Explanation of what the example does
.INPUTS
    Inputs (if any
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>

[CmdletBinding()]
param (
    # Name of Storage Account.
    [Parameter(Mandatory = $true)]
    [string]
    $StorageAccount,

    # Container Namme.
    [Parameter(Mandatory = $true)]
    [string]
    $Container,

    # Specifies a path to one or more locations of artifacts. The value of the LiteralPath parameter is
    # used exactly as it is typed. No characters are interpreted as wildcards. If the path includes escape characters,
    # enclose it in single quotation marks. Single quotation marks tell Windows PowerShell not to interpret any
    # characters as escape sequences.
    [Parameter(Mandatory = $true,
        HelpMessage = "Literal path to one or more locations.")]
    [Alias("Path")]
    [ValidateNotNullOrEmpty()]
    [string[]]
    $LiteralPath,

    # Ignored files
    [Parameter(Mandatory = $false)]
    [array]
    $IgnoredFiles,

    # Clear exisiting blobs from the container
    [Parameter(Mandatory = $false)]
    [switch]
    $DeleteOldArtifacts,

    # List artifacts before uploading to storage account.
    [Parameter(Mandatory = $false)]
    [switch]
    $ListArtifactsBeforeUpload
)
    
begin {

    # Starting timer to calculate script execution time
    $networkTime = [diagnostics.stopwatch]::StartNew() 
    
    # Session configuration
    Write-Host "Setting up session configuration."
    $ErrorActionPreference = "Stop"
    Set-StrictMode -Version Latest
    
    # Set Variables
    $rootFolder = $Script:PSScriptRoot
    $transcriptFolder = "$rootFolder\logs"
    $localTimeStamp = (Get-Date).ToString('ddMMyy-HHmmss')

    # Start transcript
    Start-Transcript -Path "$transcriptFolder\$localTimeStamp.log" -NoClobber

    "`nFollowing files will be ignored during the publish."
    $IgnoredFiles
      
}
    
process {
    Write-Host "`nVerify if provided storage account exist in the subscription."
    $_artifactsstgacc = Get-AzResource -Name $StorageAccount -ResourceType Microsoft.Storage/storageAccounts

    if ($_artifactsstgacc) {
        Write-Host "Provided storage account found. Retrieving storage account context."
        $storageObj = Get-AzStorageAccount -StorageAccountName $_artifactsstgacc.Name -ResourceGroupName $_artifactsstgacc.ResourceGroupName
        try {
            "Check if container exists."
            Get-AzStorageContainer -Name $Container -Context $storageObj.Context -ErrorAction Stop
        }
        catch {
            Write-Host "`nContainer '$Container' cannot be found. Creating storage container '$Container'."
            # Create a new container
            New-AzStorageContainer -Name $Container -Context $storageObj.Context -Permission Off -ErrorAction Stop
        }
    }
    else {
        Write-Error -Message "Storage account $StorageAccount does not exist." `
            -Category ResourceUnavailable `
            -RecommendedAction "Create storage account with name $StorageAccount."
    }

    # Publish Artifacts.
    Write-Host "`nPublish directories from $LiteralPath to storage account."
    $filePaths = @()

    # Copy files from the local storage staging location to the storage account container
    foreach ($Directory in $LiteralPath) {
        $filePaths += Get-ChildItem $Directory -Recurse -File -Exclude $IgnoredFiles | ForEach-Object -Process { $_.FullName }
    }

    if ($ListArtifactsBeforeUpload) {
        "`nFollowing files will be published to artifacts storage account."
        $filePaths
        Pause 
    }

    if ($DeleteOldArtifacts) {
        # Delete old artifacts.
        "`nDeleting old artifacts from the container."
        Get-AzStorageBlob -Container $Container -Context $storageObj.Context | Remove-AzStorageBlob -Force
    }

    "`nPublish files to storage account."
    foreach ($filePath in $filePaths) {
        if ($filePath -match '.json') {
            Set-AzStorageBlobContent -File $filePath `
                -Blob $filePath.Substring((Split-Path($LiteralPath)).length + 1) `
                -Container $Container `
                -Context $storageObj.Context `
                -Properties @{"ContentType" = "application/json" } `
                -Force -AsJob
        }
        else {
            Set-AzStorageBlobContent -File $filePath -Blob $filePath.Substring((Split-Path($LiteralPath)).length + 1) `
                -Container $Container -Context $storageObj.Context -Force -AsJob
        }

    }

    Get-Job | Wait-Job | Select-Object Id, State | Format-Table
}
    
end {

    # Remove all jobs
    "`nClean all background jobs"
    Get-Job | Remove-Job -Force
    
    # Stop Timer
    Write-Host "Record total script execution time."
    "Total Script Execution Time = $($networkTime.Elapsed.ToString())"

    # Stop transcript.
    Write-Host "Stopping transcript."
    Stop-Transcript

    # Exit Powershell
    Write-Host "Exiting session."
    Exit
        
}
