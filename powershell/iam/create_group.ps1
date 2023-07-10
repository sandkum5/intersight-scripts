# Function to create User Groups
# Two Step process
# Step-1: Create Group
# Step-2: Create Qualifier

Function CreateGroup {
    [CmdletBinding()]
    [OutputType()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$GroupName,
        [Parameter(Mandatory = $true)]
        [string]$IdpName,
        [Parameter(Mandatory = $true)]
        [array]$Roles
    )

    $IdpRel = Get-IntersightIamIdpReference -Name $IdpName | Get-IntersightMoMoRef

    # Permissions(Roles) Reference
    $RoleList = [System.Collections.ArrayList]@()
    foreach ($Role in $Roles) {
        $RoleRel = Get-IntersightIamPermission -Name $Role | Get-IntersightMoMoRef
        if ($null -eq $RoleRel) {
            $RoleList.Add($RoleRel) | Out-Null
        }
    }

    # Verify if a Role already exists
    $VerifyGroup = Get-IntersightIamUserGroup -Name $GroupName

    if (($null -eq $VerifyGroup) -and ($null -eq $IdpRel)) {
        # Create Group
        $NewGroup = New-IntersightIamUserGroup -Name $GroupName -Idpreference $IdpRel -Permissions $RoleList
        # Permissions is nothing but list of role names

        # Qualifier - The qualifier defines how a user qualifies to be part of a user group.
        # Group Relationship
        $GroupRel = Get-IntersightIamUserGroup -Name $GroupName | Get-IntersightMoMoRef

        # Group list
        $GroupList = [System.Collections.ArrayList]@()
        $GroupList.Add($GroupName) | Out-Null

        # Create Qualifier
        New-IntersightIamQualifier -Usergroup $GroupRel -Value $GroupList

        # Write Output Message
        Write-Host "$($NewGroup.Name) Group Created Successfully!" -ForegroundColor Green

    } elseif ($VerifyGroup.Name -eq $Name) {
        Write-Host "Group $($GroupName) already Exists!" -ForegroundColor Red
    } elseif ($null -eq $IdpRel) {
        Write-Host "Can't find Idp provider: $($IdpName)!"
    }
}
