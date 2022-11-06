<#
    Clone Ethernet Network Group Policy
#>
Function Invoke-CloneEthNetGroupPolicy {
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

    $ethNetGroupPolicy = Get-IntersightFabricEthNetworkGroupPolicy -Name $PolicyName -Organization $orgObj

    $ethNetGroupPolicyNewOrg = Get-IntersightFabricEthNetworkGroupPolicy -Name $PolicyName -Organization $newOrgObj

    if ($ethNetGroupPolicyNewOrg) {
        # $ethNetGroupPolicyObj = $ethNetGroupPolicyNewOrg | Get-IntersightMoMoRef

        Write-Host "Ethernet Network Group Policy $PolicyName, Moid: $($ethNetGroupPolicyNewOrg.Moid) already exits under Org: $NewOrgName" -ForegroundColor Green

        return $ethNetGroupPolicyNewOrg
    } else {
        # Initialize Port Policy Source
        $ethNetGroupPolicySrc = Initialize-IntersightMoBaseMo -ClassId "FabricEthNetworkGroupPolicy" -ObjectType "FabricEthNetworkGroupPolicy" -Moid $ethNetGroupPolicy.Moid

        # Initialize Port Policy Target
        $ethNetGroupPolicyTarget = Initialize-IntersightFabricEthNetworkGroupPolicy -Name $PolicyName -Organization $newOrgObj

        # Create Port Policy Clone
        New-IntersightBulkMoCloner -Sources $ethNetGroupPolicySrc -Targets $ethNetGroupPolicyTarget -Organization $newOrgObj

        $ethNetGroupPolicyNewOrg = Get-IntersightFabricEthNetworkGroupPolicy -Name $PolicyName -Organization $newOrgObj

        if ($ethNetGroupPolicyNewOrg) {
            # $ethNetGroupPolicyObj = $ethNetGroupPolicy | Get-IntersightMoMoRef
            Write-Host "Ethernet Network Group Policy $PolicyName, Moid: $($ethNetGroupPolicyNewOrg.Moid) created under Org: $NewOrgName" -ForegroundColor Yellow

            return $ethNetGroupPolicyNewOrg
        }
    }
}




