# Script to create User Groups
# Two Step process
# Step-1: Create Group
# Step-2: Create Qualifier

$GroupName = "pwsh_demo1"

# IdP Reference
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

# Create Group
New-IntersightIamUserGroup -Name $GroupName -Idpreference $IdpRel -Permissions $RoleList
# Permissions is nothing but list of role names

# Qualifier - The qualifier defines how a user qualifies to be part of a user group.
# Group Relationship
$GroupRel = Get-IntersightIamUserGroup -Name $GroupName | Get-IntersightMoMoRef

# Group list
$GroupList = [System.Collections.ArrayList]@()
$GroupList.Add($GroupName) | Out-Null

# Create Qualifier
New-IntersightIamQualifier -Usergroup $GroupRel -Value $GroupList
