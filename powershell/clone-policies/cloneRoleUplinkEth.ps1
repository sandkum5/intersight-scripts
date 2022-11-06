<#
    Clone Uplink Role and attach to New Port Policy
#>

. ./cloneEthNetGroupPolicy.ps1
. ./cloneLinkControlPolicy.ps1
. ./cloneFlowControlPolicy.ps1

Function Invoke-CloneUplinkRole {
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

    $uplinkRole = Get-IntersightFabricUplinkRole -Parent $portPolicyObj
    $newUplinkRole = Get-IntersightFabricUplinkRole -Parent $newPortPolicyObj

    $newUplinkRoleMoidList = [System.Collections.ArrayList]@()
    foreach ($newuplink in $newUplinkRole) {
        $newUplinkRoleMoidList.Add($newuplink.Moid) | Out-Null
    }

    if ($uplinkRole) {
        foreach ($uplink in $uplinkRole) {
            $adminspeed = $uplink.AdminSpeed
            $slotid = $uplink.SlotId
            $portid = $uplink.PortId
            $fec    = $uplink.Fec

            # Create Uplink Role
            if ($uplink.Moid -in $newUplinkRoleMoidList) {
                Write-Host "Uplink Role already exists in Target Org" -ForegroundColor "Blue"
                continue
            } else {
                Write-Debug "Update Uplink Role"
                $newUplinkRole = New-IntersightFabricUplinkRole -PortPolicy $newPortPolicyObj -AdminSpeed $adminspeed -SlotId $slotid -PortId $portid -Fec $fec
            }
            # Attach Ethernet Network Group Policy to uplink role
            if ($uplink.EthNetworkGroupPolicy) {
                $ethnetgrouppolicyMoid = $uplink.EthNetworkGroupPolicy.ActualInstance.Moid
                $ethnetgrouppolicy = Get-IntersightFabricEthNetworkGroupPolicy -Moid $ethnetgrouppolicyMoid -Organization $OrgObj

                $ethNetGroupPolicyNewOrg = Invoke-CloneEthNetGroupPolicy -OrgName $Org.Name -NewOrgName $NewOrg.Name -PolicyName $ethnetgrouppolicy.Name

                if ($ethNetGroupPolicyNewOrg) {
                    $getethNetGroupPolicyNewOrg = Get-IntersightFabricEthNetworkGroupPolicy -Moid $ethNetGroupPolicyNewOrg.Moid -Organization $newOrgObj
                    $ethNetGroupPolicyNewOrgObj = $getethNetGroupPolicyNewOrg | Get-IntersightMoMoRef
                }
                # $ethNetGroupPolicyNewOrgObj = $ethNetGroupPolicyNewOrg | Get-IntersightMoMoRef
                # Update Uplink Role with Eth Network Group Policy
                Write-Debug "Attach Ethernet Network Group Policy to Uplink Role"
                Set-IntersightFabricUplinkRole -Moid $newUplinkRole.Moid -EthNetworkGroupPolicy $ethNetGroupPolicyNewOrgObj | Out-Null
            }

            # Flow Control Policy
            if ($uplink.FlowControlPolicy) {
                $flowcontrolpolicyMoid = $uplink.FlowControlPolicy.ActualInstance.Moid
                $flowcontrolpolicy = Get-IntersightFabricFlowControlPolicy -Moid $flowcontrolpolicyMoid -Organization $OrgObj

                $flowControlPolicyNewOrg = Invoke-CloneFlowControlPolicy -OrgName $Org.Name -NewOrgName $NewOrg.Name -PolicyName $flowcontrolpolicy.Name

                if ($flowControlPolicyNewOrg) {
                    $getflowControlPolicyNewOrg = Get-IntersightFabricFlowControlPolicy -Moid $flowControlPolicyNewOrg.Moid -Organization $newOrgObj
                    $flowControlPolicyNewOrgObj = $getflowControlPolicyNewOrg | Get-IntersightMoMoRef
                }

                # $flowControlPolicyNewOrgObj = $flowControlPolicyNewOrg | Get-IntersightMoMoRef
                Write-Debug "Attach Flow Control Policy to Uplink Role"
                Set-IntersightFabricUplinkRole -Moid $newUplinkRole.Moid -FlowControlPolicy $flowControlPolicyNewOrgObj | Out-Null
            }

            # Link Control Policy
            if ($uplink.LinkControlPolicy) {
                $linkcontrolpolicyMoid = $uplink.LinkControlPolicy.ActualInstance.Moid
                $linkcontrolpolicy = Get-IntersightFabricLinkControlPolicy -Moid $linkcontrolpolicyMoid -Organization $OrgObj

                $linkControlPolicyNewOrg = Invoke-CloneLinkControlPolicy -OrgName $Org.Name -NewOrgName $NewOrg.Name -PolicyName $linkcontrolpolicy.Name

                if ($linkControlPolicyNewOrg) {
                    $getlinkControlPolicyNewOrg = Get-IntersightFabricLinkControlPolicy -Moid $linkControlPolicyNewOrg.Moid -Organization $newOrgObj
                    $linkControlPolicyNewOrgObj = $getlinkControlPolicyNewOrg | Get-IntersightMoMoRef
                }
                # $linkControlPolicyNewOrgObj = $linkControlPolicyNewOrg | Get-IntersightMoMoRef
                Write-Debug "Attach Link Control Policy to Uplink Role"
                Set-IntersightFabricUplinkRole -Moid $newUplinkRole.Moid -LinkControlPolicy $linkControlPolicyNewOrgObj | Out-Null
            }

            if ($newUplinkRole) {
                Write-Host "Uplink Role created and attached successfully to the new Port Policy!" -ForegroundColor Yellow
            }
        }
    }
}
