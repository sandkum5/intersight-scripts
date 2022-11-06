<#
    Clone Ethernet Network Control Policy
#>

Function Invoke-CloneEthNetControlPolicy {
    Param (
        # Variables
        $OrgName,
        $NewOrgName,
        $PolicyName
    )
    # Get Orgs
    $org = Get-IntersightOrganizationOrganization -Name $OrgName
    $orgObj = $org | Get-IntersightMoMoRef
    $NewOrg = Get-IntersightOrganizationOrganization -Name $newOrgName
    $newOrgObj = $newOrg | Get-IntersightMoMoRef

    <#
    Verify if a policy with Policy name exist in newOrg.
    iP $policyName exist in $newOrgName:
        Get existing policy moid/object
    iP $policyName doesn't exist in $newOrgName:
        Create a clone
    #>

    $ethNetControlPolicy = Get-IntersightFabricEthNetworkControlPolicy -Name $policyName -Organization $orgObj

    $ethNetControlPolicyNewOrg = Get-IntersightFabricEthNetworkControlPolicy -Name $policyName -Organization $newOrgObj

    if ($ethNetControlPolicyNewOrg) {
        # $ethNetControlPolicyObj = $ethNetControlPolicyNewOrg | Get-IntersightMoMoRef

        Write-Host "Ethernet Network Control Policy $policyName, Moid: $($ethNetControlPolicyNewOrg.Moid) already exits under Org: $NewOrgName" -ForegroundColor Green

        return $ethNetControlPolicyNewOrg
    } else {
        # Initialize Port Policy Source
        $ethNetControlPolicySrc = Initialize-IntersightMoBaseMo -ClassId "FabricEthNetworkControlPolicy" -ObjectType "FabricEthNetworkControlPolicy" -Moid $ethNetControlPolicy.Moid

        # Initialize Port Policy Target
        $ethNetControlPolicyTarget = Initialize-IntersightFabricEthNetworkControlPolicy -Name $PolicyName -Organization $newOrgObj

        # Create Port Policy Clone
        New-IntersightBulkMoCloner -Sources $ethNetControlPolicySrc -Targets $ethNetControlPolicyTarget -Organization $newOrgObj

        $ethNetControlPolicyNewOrg = Get-IntersightFabricEthNetworkControlPolicy -Name $policyName -Organization $newOrgObj

        if ($ethNetControlPolicyNewOrg) {
            # $ethNetControlPolicyObj = $ethNetControlPolicy | Get-IntersightMoMoRef
            Write-Host "Ethernet Network Control Policy $policyName, Moid: $($ethNetControlPolicyNewOrg.Moid) created under Org: $NewOrgName" -ForegroundColor Yellow

            return $ethNetControlPolicyNewOrg
        }
    }
}




