<#
    Clone Fcoe Uplink Role and attach to New Port Policy
#>

. ./cloneLinkControlPolicy.ps1

Function Invoke-CloneFcoeUplinkRole {
    Param (
        $Org,
        $NewOrg,
        $PortPolicy,
        $NewPortPolicy
    )

    $orgObj = $Org | Get-IntersightMoMoRef
    $newOrgObj = $NewOrg | Get-IntersightMoMoRef

    $portPolicyObj = Get-IntersightFabricPortPolicy -Moid $PortPolicy.Moid -Organization $orgObj | Get-IntersightMoMoRef
    $newPortPolicyObj = $NewPortPolicy | Get-IntersightMoMoRef

    $fcoeUplinkRole = Get-IntersightFabricFcoeUplinkRole -Parent $portPolicyObj

    $newFcoeUplinkRole = Get-IntersightFabricFcoeUplinkRole -Parent $newPortPolicyObj

    $newFcoeUplinkRoleMoidList = [System.Collections.ArrayList]@()
    foreach ($newfcoeuplink in $newFcoeUplinkRole) {
        $newFcoeUplinkRoleMoidList.Add($newfcoeuplink.Moid) | Out-Null
    }

    if ($fcoeUplinkRole) {
        foreach ($fcoeuplink in $fcoeUplinkRole) {
            $adminspeed = $fcoeuplink.AdminSpeed
            $slotid = $fcoeuplink.SlotId
            $portid = $fcoeuplink.PortId
            $fec = $fcoeuplink.Fec

            # Create Fcoe Uplink Role
            if ($fcoeuplink.Moid -in $newFcoeUplinkRoleMoidList) {
                Write-Host "Fcoe Uplink Role already exists in target Org!" -ForegroundColor "Blue"
            } else {
                Write-Debug "Update Fcoe Uplink Role"
                $newFcoeUplinkRole = New-IntersightFabricFcoeUplinkRole -PortPolicy $newPortPolicyObj -AdminSpeed $adminspeed -SlotId $slotid -PortId $portid -Fec $fec
            }

            # Attach Link Control Policy
            if ($fcoeuplink.LinkControlPolicy) {
                $linkcontrolpolicyMoid = $fcoeuplink.LinkControlPolicy.ActualInstance.Moid
                $linkcontrolpolicy = Get-IntersightFabricLinkControlPolicy -Moid $linkcontrolpolicyMoid -Organization $OrgObj

                $linkControlPolicyNewOrg = Invoke-CloneLinkControlPolicy -OrgName $Org.Name -NewOrgName $NewOrg.Name -PolicyName $linkcontrolpolicy.Name

                if ($linkControlPolicyNewOrg) {
                    $getlinkControlPolicyNewOrg = Get-IntersightFabricLinkControlPolicy -Moid $linkControlPolicyNewOrg.Moid -Organization $newOrgObj
                    $linkControlPolicyNewOrgObj = $getlinkControlPolicyNewOrg | Get-IntersightMoMoRef
                }
                # $linkControlPolicyNewOrgObj = $linkControlPolicyNewOrg | Get-IntersightMoMoRef
                Write-Debug "Attach Link Control Policy to Fcoe Uplink Role"
                Set-IntersightFabricFcoeUplinkRole -Moid $newFcoeUplinkRole.Moid -LinkControlPolicy $linkControlPolicyNewOrgObj | Out-Null
            }

            if ($newFcoeUplinkRole) {
                Write-Host "Fcoe Uplink Role created and attached successfully to the new Port Policy!" -ForegroundColor Yellow
            }
        }
    }
}