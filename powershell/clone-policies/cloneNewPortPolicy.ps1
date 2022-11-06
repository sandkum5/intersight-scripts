<#
    Clone a Port Policy
#>

$ApiParams = @{
    BasePath          = "https://intersight.com"
    ApiKeyId          = Get-Content -Path "./sankey.txt" -Raw
    ApiKeyFilePath    = $pwd.Path + "/sanSecretKey.txt"
    HttpSigningHeader = @("(request-target)", "Host", "Date", "Digest")
}

Set-IntersightConfiguration @ApiParams

Function Invoke-ClonePortPolicy {
    Param (
        # Variables
        $orgName = "default",
        $newOrgName = "prod",
        $policyName = "oldport"
    )
    # Get Orgs
    $org = Get-IntersightOrganizationOrganization -Name $orgName
    $orgObj = $org | Get-IntersightMoMoRef
    $newOrg = Get-IntersightOrganizationOrganization -Name $newOrgName
    $newOrgObj = $newOrg | Get-IntersightMoMoRef

    <#
    Verify if a policy with Policy name exist in newOrg.
    if $policyName exist in $newOrgName:
        Get existing policy moid/object
    if $policyName doesn't exist in $newOrgName:
        Create a clone
    #>

    $portPolicy = Get-IntersightFabricPortPolicy -Name $policyName -Organization $orgObj

    $portPolicyNewOrg = Get-IntersightFabricPortPolicy -Name $policyName -Organization $newOrgObj

    if ($portPolicyNewOrg) {
        # $portPolicyObj = $portPolicyNewOrg | Get-IntersightMoMoRef

        Write-Host "Port Policy $policyName, Moid: $($portPolicyNewOrg.Moid) already exits under Org: $newOrgName" -ForegroundColor Green

        return $portPolicyNewOrg
    } else {
        # Initialize Port Policy Source
        $portPolicySrc = Initialize-IntersightMoBaseMo -ClassId "FabricPortPolicy" -ObjectType "FabricPortPolicy" -Moid $portPolicy.Moid

        # Initialize Port Policy Target
        $portPolicyTarget = Initialize-IntersightFabricPortPolicy -Name $policyName -Organization $newOrgObj

        # Create Port Policy Clone
        New-IntersightBulkMoCloner -Sources $portPolicySrc -Targets $portPolicyTarget -Organization $newOrgObj

        $portPolicyNewOrg = Get-IntersightFabricPortPolicy -Name $policyName -Organization $newOrgObj

        if ($portPolicyNewOrg) {
            # $portPolicyObj = $portPolicy | Get-IntersightMoMoRef
            Write-Host "Port Policy $policyName, Moid: $($portPolicyNewOrg.Moid) created under Org: $newOrgName" -ForegroundColor Yellow

            return $portPolicyNewOrg
        }
    }
}
