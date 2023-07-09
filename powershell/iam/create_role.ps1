# Sample Script to Create Intersight Roles
# NOTE: With API, Role is created using IamPermission and Permissions are created using IamResourceRoles

# Create Role
$RoleName = "pwsh_demo1"
$NewRole = New-IntersightIamPermission -Name $RoleName -Description "Role Created using Powershell"
# -SessionLimits <IamSessionLimitsRelationship> -Tags <System.Collections.Generic.List`1[MoTag]> -Roles <System.Collections.Generic.List`1[IamRoleRelationship]>

# Create Session Limits
New-IntersightIamSessionLimits -IdleTimeOut 1800 -MaximumLimit 128 -SessionTimeOut 57600 -Permission ($NewRole | Get-IntersightMoMoRef) | Out-Null
# Default Session Timeout Values
# IdleTimeOut    : 1800
# MaximumLimit   : 128
# SessionTimeOut : 57600
# PerUserLimit   : 32

# Get Org1 Relationship
$Org1 = "prod"
$Org1Rel = Get-IntersightOrganizationOrganization -Name $Org1 | Get-IntersightMoMoRef

# Get Org2 Relationship
$Org2 = "tfdemo"
$Org2Rel = Get-IntersightOrganizationOrganization -Name $Org2 | Get-IntersightMoMoRef

# Assign Org to Permissions
# $Orgs = Get-IntersightOrganizationOrganization -Select Name
# $Orgs.results | Where-Object {$_.Name -eq $Org1} | Get-IntersightMoMoRef
# Or

New-IntersightIamResourceRoles -Permission ($NewRole | Get-IntersightMoMoRef) -Resource $Org2Rel -Roles $PermissionsList

$PermissionsList = [System.Collections.ArrayList]@()

$r1 = Get-IntersightIamRole -Name 'Server Administrator' | Get-IntersightMoMoRef
$r2 = Get-IntersightIamRole -Name 'Device Administrator' | Get-IntersightMoMoRef
$PermissionsList.Add($r1) | Out-Null
$PermissionsList.Add($r2) | Out-Null

New-IntersightIamResourceRoles -Permission ($NewRole | Get-IntersightMoMoRef) -Resource $Org1Rel -Roles $PermissionsList
New-IntersightIamResourceRoles -Permission ($NewRole | Get-IntersightMoMoRef) -Resource $Org2Rel -Roles $PermissionsList
