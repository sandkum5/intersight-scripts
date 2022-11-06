<#
    Clone Flow Control Policy
#>

Function Invoke-CloneFlowControlPolicy {
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

    $flowControlPolicy = Get-IntersightFabricFlowControlPolicy -Name $PolicyName -Organization $orgObj

    $flowControlPolicyNewOrg = Get-IntersightFabricFlowControlPolicy -Name $PolicyName -Organization $newOrgObj

    if ($flowControlPolicyNewOrg) {
        # $flowControlPolicyObj = $flowControlPolicyNewOrg | Get-IntersightMoMoRef

        Write-Host "Flow Control Policy $PolicyName, Moid: $($flowControlPolicyNewOrg.Moid) already exits under Org: $NewOrgName" -ForegroundColor Green

        return $flowControlPolicyNewOrg
    } else {
        # Initialize Port Policy Source
        $flowControlPolicySrc = Initialize-IntersightMoBaseMo -ClassId "FabricFlowControlPolicy" -ObjectType "FabricFlowControlPolicy" -Moid $flowControlPolicy.Moid

        # Initialize Port Policy Target
        $flowControlPolicyTarget = Initialize-IntersightFabricFlowControlPolicy -Name $PolicyName -Organization $newOrgObj

        # Create Port Policy Clone
        New-IntersightBulkMoCloner -Sources $flowControlPolicySrc -Targets $flowControlPolicyTarget -Organization $newOrgObj

        $flowControlPolicyNewOrg = Get-IntersightFabricFlowControlPolicy -Name $PolicyName -Organization $newOrgObj

        if ($flowControlPolicyNewOrg) {
            # $flowControlPolicyObj = $flowControlPolicy | Get-IntersightMoMoRef
            Write-Host "Flow Control Policy $PolicyName, Moid: $($flowControlPolicyNewOrg.Moid) created under Org: $NewOrgName" -ForegroundColor Yellow

            return $flowControlPolicyNewOrg
        }
    }
}
