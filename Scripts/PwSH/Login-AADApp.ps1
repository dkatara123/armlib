<#

.DESCRIPTION

    Script to login to Azure Subscription through PowerShell using AAD App Registration.

.EXAMPLE
    <parent-folder-path>\Login-AADApp.ps1 -SubscriptionId "<subscription-id>" `
        -AADTenantId "<azure-tenant-id>" `
        -ServicePrincipalId "<aad-application-client-id>" `
        -ServicePrincipalPassword "<aad-application-client-key>"

#>

[CmdletBinding()]
param (

    # Azure Subscripition ID.
    [Parameter(Mandatory = $true)]
    [Alias("Subscription")]
    [guid]
    $SubscriptionId,

    # Azure AD Tenant ID.
    [Parameter(Mandatory = $true)]
    [Alias("Tenant")]
    [guid]
    $AADTenantId,

    # Service Principal Application ID.
    [Parameter(Mandatory = $true)]
    [guid]
    $ServicePrincipalId,

    # # Service Principal Key ID.
    [Parameter(Mandatory = $true)]
    [string]
    $ServicePrincipalPassword

)

# Login to subscription with AAD application
$securePassword = ConvertTo-SecureString -String $ServicePrincipalPassword -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential($ServicePrincipalId, $securePassword)
try {
    Write-Host "Login to Subscription - $subscriptionId"
    Add-AzAccount -Credential $credential -ServicePrincipal -Tenant $AADTenantId -SubscriptionId $SubscriptionId
    Write-Host "Login successful to Subscription  $subscriptionId"
}
catch {
    throw $_.Exception.Message
}