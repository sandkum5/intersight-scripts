<#
    Clone Chassis Profile
    Note:
        At present, This script only works when the current and target Organization are same.
        Still a Work-in-progress
#>

Function Invoke-CloneChassisProfile {
    Param (
        # Default Values
        $OrgName = 'default',
        $NewOrgName = 'default',
        $ChassisProfileName = 'Chassis-Profile',
        $NewChassisProfileName = 'clone-profile-1'
    )

    # Get Orgs
    $Org = Get-IntersightOrganizationOrganization -Name $OrgName
    $OrgObj = $org | Get-IntersightMoMoRef
    $NewOrg = Get-IntersightOrganizationOrganization -Name $NewOrgName
    $NewOrgObj = $newOrg | Get-IntersightMoMoRef

    # Get Chassis Profile Info
    $ChassisProfile = Get-IntersightChassisProfile -Name $ChassisProfileName -Organization $OrgObj
    $ChassisProfileNewOrg = Get-IntersightChassisProfile -Name $NewChassisProfileName -Organization $NewOrgObj

    if ($ChassisProfileNewOrg) {
        Write-Host "Chassis Profile $NewChassisProfileName, Moid: $($ChassisProfileNewOrg.Moid) already exits under Org: $NewOrg" -ForegroundColor Green
        
        return $ChassisProfileNewOrg
    } else {
        # Initialize Port Policy Source
        $ChassisProfileSrc = Initialize-IntersightMoBaseMo -ClassId "ChassisProfile" -ObjectType "ChassisProfile" -Moid $ChassisProfile.Moid

        # Initialize Port Policy Target
        $ChassisProfileTarget = Initialize-IntersightChassisProfile -Name $NewChassisProfileName -Organization $NewOrgObj

        # Create Port Policy Clone
        New-IntersightBulkMoCloner -Sources $ChassisProfileSrc -Targets $ChassisProfileTarget -Organization $NewOrgObj

        $ChassisProfileNewOrg = Get-IntersightChassisProfile -Name $NewChassisProfileName -Organization $NewOrgObj

        if ($ChassisProfileNewOrg) {
            Write-Host "Chassis Profile $NewChassisProfileName, Moid: $($ChassisProfileNewOrg.Moid) created under Org: $NewOrgName" -ForegroundColor Yellow

            return $ChassisProfileNewOrg
        }
    }
}


$ApiParams = @{
    BasePath          = "https://intersight.com"
    ApiKeyId          = Get-Content -Path "./apiKey.txt" -Raw
    ApiKeyFilePath    = $pwd.Path + "/SecretKey.txt"
    HttpSigningHeader = @("(request-target)", "Host", "Date", "Digest")
}

Set-IntersightConfiguration @ApiParams

# Run the Function
Invoke-CloneChassisProfile -OrgName 'default' -NewOrgName 'default' -ChassisProfileName 'Chassis-Profile' -NewChassisProfileName 'clone-lab-profile-2'
