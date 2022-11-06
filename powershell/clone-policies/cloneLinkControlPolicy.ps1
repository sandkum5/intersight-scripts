<#
    Clone Link Control Policy
#>

Function Invoke-CloneLinkControlPolicy {
    Param (
        # Variables
        $OrgName,
        $NewOrgName,
        $PolicyName
    )
    # Get Orgs
    $org = Get-IntersightOrganizationOrganization -Name $OrgName
    $orgObj = $org | Get-IntersightMoMoRef
    $newOrg = Get-IntersightOrganizationOrganization -Name $NewOrgName
    $newOrgObj = $newOrg | Get-IntersightMoMoRef

    <#
    Verify if a policy with Policy name exist in newOrg.
    if $PolicyName exist in $NewOrgName:
        Get existing policy moid/object
    if $PolicyName doesn't exist in $NewOrgName:
        Create a clone
    #>

    $linkControlPolicy = Get-IntersightFabricLinkControlPolicy -Name $PolicyName -Organization $orgObj

    $linkControlPolicyNewOrg = Get-IntersightFabricLinkControlPolicy -Name $PolicyName -Organization $newOrgObj

    if ($linkControlPolicyNewOrg) {
        # $linkControlPolicyObj = $linkControlPolicyNewOrg | Get-IntersightMoMoRef

        Write-Host "Link Control Policy $PolicyName, Moid: $($linkControlPolicyNewOrg.Moid) already exits under Org: $NewOrgName" -ForegroundColor Green

        return $linkControlPolicyNewOrg
    } else {
        # Initialize Port Policy Source
        $linkControlPolicySrc = Initialize-IntersightMoBaseMo -ClassId "FabricLinkControlPolicy" -ObjectType "FabricLinkControlPolicy" -Moid $linkControlPolicy.Moid

        # Initialize Port Policy Target
        $linkControlPolicyTarget = Initialize-IntersightFabricLinkControlPolicy -Name $PolicyName -Organization $newOrgObj

        # Create Port Policy Clone
        New-IntersightBulkMoCloner -Sources $linkControlPolicySrc -Targets $linkControlPolicyTarget -Organization $newOrgObj

        $linkControlPolicyNewOrg = Get-IntersightFabricLinkControlPolicy -Name $PolicyName -Organization $newOrgObj

        if ($linkControlPolicyNewOrg) {
            # $linkControlPolicyObj = $linkControlPolicy | Get-IntersightMoMoRef
            Write-Host "Link Control Policy $PolicyName, Moid: $($linkControlPolicyNewOrg.Moid) created under Org: $NewOrgName" -ForegroundColor Yellow

            return $linkControlPolicyNewOrg
        }
    }
}
