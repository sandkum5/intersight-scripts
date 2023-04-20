<#
    Clone Intersight Bios Policy within Same or Different Org
#>

Function Invoke-CloneBiosPolicy {
    Param (
        # Variables
        $OrgName,
        $NewOrgName,
        $PolicyName,
        $NewPolicyName
    )
    # Get Org
    if ($OrgName -ne $NewOrgName) {
        $Org = Get-IntersightOrganizationOrganization -Name $OrgName
        $OrgObj = $Org | Get-IntersightMoMoRef
        $NewOrg = Get-IntersightOrganizationOrganization -Name $NewOrgName
        $NewOrgObj = $NewOrg | Get-IntersightMoMoRef
    } else {
        $Org = Get-IntersightOrganizationOrganization -Name $OrgName
        $NewOrgObj = $OrgObj = $Org | Get-IntersightMoMoRef
    }

    # Get Policy
    $ExistingPolicy = Get-IntersightBiosPolicy -Name $PolicyName -Organization $OrgObj
    $NewPolicy = Get-IntersightBiosPolicy -Name $NewPolicyName -Organization $NewOrgObj

    if ($NewPolicy) {
        # Policy Already Exist with same name under the Target Org
        Write-Host "Bios Policy $PolicyName, Moid: $($NewPolicy.Moid) already exits under Org: $NewOrgName" -ForegroundColor Green

        # return $NewPolicy
    } else {
        # Initialize Port Policy Source
        $PolicySrc = Initialize-IntersightMoBaseMo -ClassId "BiosPolicy" -ObjectType "BiosPolicy" -Moid $ExistingPolicy.Moid

        # Initialize Port Policy Target
        $PolicyTarget = Initialize-IntersightBiosPolicy -Name $NewPolicyName -Organization $NewOrgObj

        # Create Port Policy Clone
        New-IntersightBulkMoCloner -Sources $PolicySrc -Targets $PolicyTarget -Organization $NewOrgObj

        $GetClonedPolicy = Get-IntersightBiosPolicy -Name $NewPolicyName -Organization $NewOrgObj
        if ($GetClonedPolicy) {
            Write-Host "Bios Policy: $NewPolicyName, Moid: $($ClonedPolicy.Moid) created under Org: $NewOrgName" -ForegroundColor Yellow

            # return $NewPolicy
        }
    }
}
