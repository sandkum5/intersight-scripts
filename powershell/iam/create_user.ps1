# Function to create Users

Function CreateUser {
    [CmdletBinding()]
    [OutputType()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$UserEmail,
        [Parameter(Mandatory = $true)]
        [string]$IdpName,
        [Parameter(Mandatory = $true)]
        [array]$Roles
    )

    # Idp Reference
    $IdpRel = Get-IntersightIamIdpReference -Name $IdpName | Get-IntersightMoMoRef

    # Permissions(Roles) Reference
    $RoleList = [System.Collections.ArrayList]@()
    foreach ($Role in $Roles) {
        $RoleRel = Get-IntersightIamPermission -Name $Role | Get-IntersightMoMoRef
        if ($null -eq $RoleRel) {
            $RoleList.Add($RoleRel) | Out-Null
        }
    }

    # Verify if a User already exists
    $VerifyUser = Get-IntersightIamUser -Email $UserEmail

    if (($null -eq $VerifyUser) -and ($null -eq $IdpRel)) {
        # Create User
        $NewUser = New-IntersightIamUser -Email $UserEmail -Idpreference $IdpRel -Permissions $RoleList

        # Write Output Message
        Write-Host "$($NewUser.Email) Created Successfully!" -ForegroundColor Green
    } elseif ($VerifyUser.Name -eq $Name) {
        Write-Host "User $($UserEmail) already Exists!" -ForegroundColor Red
    } elseif ($null -eq $IdpRel) {
        Write-Host "Can't find Idp provider: $($IdpName)!"
    }
}
