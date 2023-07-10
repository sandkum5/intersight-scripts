# Function to Create Intersight Organization
# Arguments:
# Name: Organization Name
# Description: Organization Description
# RGs: Resource Group Name (Array)
Function CreateOrg {
    [CmdletBinding()]
    [OutputType()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $false)]
        [string]$Description,
        [Parameter(Mandatory = $false)]
        [array]$RGs
    )
    # Create Resource Group Relationship Object
    $RGList = [System.Collections.ArrayList]@()
    foreach ($RG in $RGs) {
        $RGRel = Get-IntersightResourceGroup -Name $RG | Get-IntersightMoMoRef
        if ($null -eq $RGRel) {
            $RGList.Add($RGRel) | Out-Null
        }
    }

    # Verify if an Org with the same name exists
    $VerifyOrg = Get-IntersightOrganizationOrganization -Name $Name

    if ($null -eq $VerifyOrg) {
        # Create Organization
        $NewOrg = New-IntersightOrganizationOrganization -Name $Name -Description $Description -ResourceGroups $RGList

        # Write Output Message
        Write-Host "$($NewOrg.Name) Created Successfully!" -ForegroundColor Green

    } elseif ($VerifyOrg.Name -eq $Name) {
        Write-Host "Org $($Name) already Exists!" -ForegroundColor Red
    }
}
