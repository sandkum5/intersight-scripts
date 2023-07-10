# Workflow Script

. ./create_org.ps1
. ./create_role.ps1
. ./create_group.ps1
. ./create_user.ps1

# Read Yaml
# Install-Module PowerShell-yaml
$Data = Get-Content -Path './data.yaml' | ConvertFrom-Yaml


# Create Resource Groups
$RGData = $Data.intersight.iam.rgs
foreach ($RG in $RGData) {
    # Pending
}

# Create Organization
$OrgData = $Data.intersight.iam.orgs
foreach ($Org in $OrgData) {
    CreateOrg -Name $Org.Name -Description $Org.Description -RGs $Org.RGs
}

# Create Roles
$RoleData = $Data.intersight.iam.roles
foreach ($Role in $RoleData) {
    CreateRole -Name $Role.Name -Description $Role.Description -SessionLimits $Role.SessionLimits -AccessControl $Role.AccessControl
}

# Create Groups
$GroupData = $Data.intersight.iam.groups
foreach ($Group in $GroupData) {
    CreateGroup -GroupName $Group.Name -IdpName $Group.IdpName -Roles $Group.Roles
}

# Create Users
$UserData = $Data.intersight.iam.users
foreach ($User in $UserData) {
    CreateUser -UserEmail $User.UserEmail -IdpName $User.IdpName -Roles $User.Roles
}
