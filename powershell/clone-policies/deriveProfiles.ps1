<#
    Derive Profile from Template
#>
Function Invoke-DeriveServerProfile {
    Param (
        # Variables
        [string]$OrgName,
        [string]$TemplateName,
        [string]$ProfileName,
        [int]$NoOfClones
    )
    # Get Orgs
    $OrgObj = Get-IntersightOrganizationOrganization -Name $OrgName | Get-IntersightMoMoRef

    # Get Server Profile Template
    $SPTemplate = Get-IntersightServerProfileTemplate -Name $TemplateName -Organization $OrgObj

    # SP = ServerProfile
    $SP = Get-IntersightServerProfile -Name $ProfileName -Organization $OrgObj

    if ($SP) {
        Write-Host "ServerProfile $ProfileName, Moid: $($SP.Moid) already exits under Org: $OrgName" -ForegroundColor Green
        return $SP
    } else {
        $SPTemplateSrc = Initialize-IntersightMoBaseMo -ClassId "ServerProfileTemplate" -ObjectType "ServerProfileTemplate" -Moid $SPTemplate.Moid

        $TargetList = [System.Collections.ArrayList]@()

        for ($num = 1 ; $num -le $NoOfClones ; $num++) {
            $ServerProfile = $ProfileName + "_$($num)"
            $CheckSP = Get-IntersightServerProfile -Name $ServerProfile -Organization $OrgObj
            if ($CheckSP -ne "") {
                $SPTarget = Initialize-IntersightServerProfile -Name $ServerProfile -Organization $OrgObj
                $TargetList.Add($SPTarget) | Out-Null
                Write-Host "Server Profile: $($ServerProfile) added to Target List!"
            } else {
                Write-Host "Server Profile: $($CheckSP.Name) already exits!"
            }
        }

        # Create Port Policy Clone
        New-IntersightBulkMoCloner -Sources $SPTemplateSrc -Targets $TargetList -Organization $OrgObj
    }
}
