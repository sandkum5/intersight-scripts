# Sample Script to create Users

$UserEmail = "test@lab.com"

# Idp Reference
$IdpName = "Cisco"
$IdpRel = Get-IntersightIamIdpReference -Name $IdpName | Get-IntersightMoMoRef

# Permissions(Roles) Reference
$RoleList = [System.Collections.ArrayList]@()
$role1 = "tfdemo"
$role2 = "Server Administrator"
$role1Rel = Get-IntersightIamPermission -Name $role1 | Get-IntersightMoMoRef
$role2Rel = Get-IntersightIamPermission -Name $role2 | Get-IntersightMoMoRef
$RoleList.Add($role1Rel) | Out-Null
$RoleList.Add($role2Rel) | Out-Null

# Create User
New-IntersightIamUser -Email $UserEmail -Idpreference $IdpRel -Permissions $RoleList
