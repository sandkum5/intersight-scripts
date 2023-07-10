# Function to Create Intersight Roles
# NOTE: With API, Role is created using IamPermission and Permissions are created using IamResourceRoles
Function CreateRole {
    [CmdletBinding()]
    [OutputType()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [string]$Description,
        [Parameter(Mandatory = $false)]
        [hashtable]$SessionLimits,
        [Parameter(Mandatory = $false)]
        [array]$AccessControl
    )

    # Verify if a Role already exists
    $VerifyRole = Get-IntersightIamPermission -Name $Name

    # Create Role
    if ($null -eq $VerifyRole) {
        $NewRole = New-IntersightIamPermission -Name $Name -Description $Description
    } else {
        Write-Host "Role $($Name) already exists!" -ForegroundColor Red
    }

    # Create Session Limits and associated to Role
    if ($NewRole) {
        Write-Host "Created Role: $($Name) Successfully!" -ForegroundColor Green
        # Default Session Timeout Values
        # IdleTimeOut    : 1800
        # MaximumLimit   : 128
        # SessionTimeOut : 57600
        # PerUserLimit   : 32
        $NewSessionLimit = New-IntersightIamSessionLimits -IdleTimeOut 1800 -MaximumLimit 128 -SessionTimeOut 57600 -Permission ($NewRole | Get-IntersightMoMoRef)
        if ($NewSessionLimit) {
            Write-Host "Session Limits Applied Successfully!" -ForegroundColor Green
        }
    }

    foreach ($Access in $AccessControl) {
        # Get Org Relationship
        $OrgRel = Get-IntersightOrganizationOrganization -Name $Access.OrgName | Get-IntersightMoMoRef

        $PermissionsList = [System.Collections.ArrayList]@()
        foreach ($Permission in $Access.Permissions) {
            $PermissionRel = Get-IntersightIamRole -Name $Permission | Get-IntersightMoMoRef
            $PermissionsList.Add($PermissionRel) | Out-Null
        }

        # Assign Org to Permissions
        if ($OrgRel -and $PermissionsList -and $NewRole) {
            $ApplyPermissions = New-IntersightIamResourceRoles -Permission ($NewRole | Get-IntersightMoMoRef) -Resource $OrgRel -Roles $PermissionsList
            if ($ApplyPermissions) {
                Write-Host "Org Permissions Applied Successfully to the Role!" -ForegroundColor Green
            }
        }
    }
}
