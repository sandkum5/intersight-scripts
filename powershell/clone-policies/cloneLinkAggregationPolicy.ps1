<#
    Clone Link Aggregation Policy
#>

$ApiParams = @{
    BasePath          = "https://intersight.com"
    ApiKeyId          = Get-Content -Path "./sankey.txt" -Raw
    ApiKeyFilePath    = $pwd.Path + "/sanSecretKey.txt"
    HttpSigningHeader = @("(request-target)", "Host", "Date", "Digest")
}

Set-IntersightConfiguration @ApiParams

Function Invoke-CloneLinkAggregationPolicy {
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
    iP $policyName exist in $NewOrgName:
        Get existing policy moid/object
    iP $policyName doesn't exist in $NewOrgName:
        Create a clone
    #>

    $linkAggregationPolicy = Get-IntersightFabricLinkAggregationPolicy -Name $policyName -Organization $orgObj

    $linkAggregationPolicyNewOrg = Get-IntersightFabricLinkAggregationPolicy -Name $policyName -Organization $newOrgObj

    if ($linkAggregationPolicyNewOrg) {
        # $linkAggregationPolicyObj = $linkAggregationPolicyNewOrg | Get-IntersightMoMoRef

        Write-Host "Link Aggregation policy $policyName, Moid: $($linkAggregationPolicyNewOrg.Moid) already exits under Org: $NewOrgName" -ForegroundColor Green

        return $linkAggregationPolicyNewOrg
    } else {
        # Initialize Port Policy Source
        $linkAggregationPolicySrc = Initialize-IntersightMoBaseMo -ClassId "FabricLinkAggregationPolicy" -ObjectType "FabricLinkAggregationPolicy" -Moid $linkAggregationPolicy.Moid

        # Initialize Port Policy Target
        $linkAggregationPolicyTarget = Initialize-IntersightFabricLinkAggregationPolicy -Name $PolicyName -Organization $newOrgObj

        # Create Port Policy Clone
        New-IntersightBulkMoCloner -Sources $linkAggregationPolicySrc -Targets $linkAggregationPolicyTarget -Organization $newOrgObj

        $linkAggregationPolicyNewOrg = Get-IntersightFabricLinkAggregationPolicy -Name $PolicyName -Organization $newOrgObj

        if ($linkAggregationPolicyNewOrg) {
            # $linkAggregationPolicyObj = $linkAggregationPolicy | Get-IntersightMoMoRef
            Write-Host "Link Aggregation policy $policyName, Moid: $($linkAggregationPolicyNewOrg.Moid) created under Org: $NewOrgName" -ForegroundColor Yellow

            return $linkAggregationPolicyNewOrg
        }
    }
}
