<#
    Clone Uplink PC Role and attach to New Port Policy
#>

. ./cloneEthNetGroupPolicy.ps1
. ./cloneFlowControlPolicy.ps1
. ./cloneLinkControlPolicy.ps1
. ./cloneLinkAggregationPolicy.ps1
Function Invoke-CloneUplinkPcRole {
    Param (
        $Org,
        $NewOrg,
        $PortPolicy,
        $NewPortPolicy
    )

    $newPortPolicyObj = $NewPortPolicy | Get-IntersightMoMoRef

    $orgObj = $Org | Get-IntersightMoMoRef
    $newOrgObj = $NewOrg | Get-IntersightMoMoRef

    $portPolicyObj = Get-IntersightFabricPortPolicy -Moid $PortPolicy.Moid -Organization $orgObj | Get-IntersightMoMoRef

    $uplinkPcRole = Get-IntersightFabricUplinkPcRole -Parent $portPolicyObj
    $getNewUplinkPcRole = Get-IntersightFabricUplinkPcRole -Parent $newPortPolicyObj

    $newUplinkRoleMoidList = [System.Collections.ArrayList]@()
    foreach ($newuplink in $getNewUplinkPcRole) {
        $newUplinkRoleMoidList.Add($newuplink.Moid) | Out-Null
    }

    if ($uplinkPcRole) {
        foreach ($uplinkpc in $uplinkPcRole) {
            $adminspeed = $uplinkpc.AdminSpeed
            $pcid = $uplinkpc.PcId
            $ports = $uplinkpc.Ports
            $portList = [System.Collections.ArrayList]@()
            foreach ($port in $ports) {
                $portObj = Initialize-IntersightFabricPortIdentifier -ClassId "FabricPortIdentifier" -ObjectType "FabricPortIdentifier" -PortId $port.PortId -SlotId $port.SlotId
                $portList.Add($portObj) | Out-Null
            }
            # Create Uplink PC Role
            if ($uplinkpc.Moid -in $newUplinkRoleMoidList) {
                Write-Host "Uplink PC Role already exists in Target Org" -ForegroundColor "Blue"
                continue
            } else {
                Write-Debug "Update Uplink PC Role"
                $newUplinkPcRole = New-IntersightFabricUplinkPcRole -PortPolicy $newPortPolicyObj -AdminSpeed $adminspeed -PcId $pcid -Ports $portList
            }

            # Attach Ethernet Network Group Policy to uplink role
            if ($uplinkpc.EthNetworkGroupPolicy) {
                $ethnetgrouppolicyMoid = $uplinkpc.EthNetworkGroupPolicy.ActualInstance.Moid
                $ethnetgrouppolicy = Get-IntersightFabricEthNetworkGroupPolicy -Moid $ethnetgrouppolicyMoid -Organization $OrgObj

                $ethNetGroupPolicyNewOrg = Invoke-CloneEthNetGroupPolicy -OrgName $Org.Name -NewOrgName $NewOrg.Name -PolicyName $ethnetgrouppolicy.Name

                if ($ethNetGroupPolicyNewOrg) {
                    $getethNetGroupPolicyNewOrg = Get-IntersightFabricEthNetworkGroupPolicy -Moid $ethNetGroupPolicyNewOrg.Moid -Organization $newOrgObj
                    $ethNetGroupPolicyNewOrgObj = $getethNetGroupPolicyNewOrg | Get-IntersightMoMoRef
                }
                # $ethNetGroupPolicyNewOrgObj = $ethNetGroupPolicyNewOrg | Get-IntersightMoMoRef
                # Update Uplink Role with Eth Network Group Policy
                Write-Debug "Attach Ethernet Network Group Policy to Uplink PC Role"
                Set-IntersightFabricUplinkPcRole -Moid $newUplinkPcRole.Moid -EthNetworkGroupPolicy $ethNetGroupPolicyNewOrgObj | Out-Null
            }

            # Flow Control Policy
            if ($uplinkpc.FlowControlPolicy) {
                $flowcontrolpolicyMoid = $uplinkpc.FlowControlPolicy.ActualInstance.Moid
                $flowcontrolpolicy = Get-IntersightFabricFlowControlPolicy -Moid $flowcontrolpolicyMoid -Organization $OrgObj

                $flowControlPolicyNewOrg = Invoke-CloneFlowControlPolicy -OrgName $Org.Name -NewOrgName $NewOrg.Name -PolicyName $flowcontrolpolicy.Name

                if ($flowControlPolicyNewOrg) {
                    $getflowControlPolicyNewOrg = Get-IntersightFabricFlowControlPolicy -Moid $flowControlPolicyNewOrg.Moid -Organization $newOrgObj
                    $flowControlPolicyNewOrgObj = $getflowControlPolicyNewOrg | Get-IntersightMoMoRef
                }

                # $flowControlPolicyNewOrgObj = $flowControlPolicyNewOrg | Get-IntersightMoMoRef
                Write-Debug "Attach Flow Control Policy to Uplink PC Role"
                Set-IntersightFabricUplinkPcRole -Moid $newUplinkPcRole.Moid -FlowControlPolicy $flowControlPolicyNewOrgObj | Out-Null
            }

            # Link Control Policy
            if ($uplinkpc.LinkControlPolicy) {
                $linkcontrolpolicyMoid = $uplinkpc.LinkControlPolicy.ActualInstance.Moid
                $linkcontrolpolicy = Get-IntersightFabricLinkControlPolicy -Moid $linkcontrolpolicyMoid -Organization $OrgObj

                $linkControlPolicyNewOrg = Invoke-CloneLinkControlPolicy -OrgName $Org.Name -NewOrgName $NewOrg.Name -PolicyName $linkcontrolpolicy.Name

                if ($linkControlPolicyNewOrg) {
                    $getlinkControlPolicyNewOrg = Get-IntersightFabricLinkControlPolicy -Moid $linkControlPolicyNewOrg.Moid -Organization $newOrgObj
                    $linkControlPolicyNewOrgObj = $getlinkControlPolicyNewOrg | Get-IntersightMoMoRef
                }
                # $linkControlPolicyNewOrgObj = $linkControlPolicyNewOrg | Get-IntersightMoMoRef
                Write-Debug "Attach Link Control Policy to Uplink PC Role"
                Set-IntersightFabricUplinkPcRole -Moid $newUplinkPcRole.Moid -LinkControlPolicy $linkControlPolicyNewOrgObj | Out-Null
            }

            # Attach Link Aggregation Policy to uplink role
            if ($uplinkpc.LinkAggregationPolicy) {
                $linkAggregationPolicyMoid = $uplinkpc.LinkAggregationPolicy.ActualInstance.Moid
                $linkAggregationPolicy = Get-IntersightFabricLinkAggregationPolicy -Moid $linkAggregationPolicyMoid -Organization $OrgObj

                $linkAggregationPolicyNewOrg = Invoke-CloneLinkAggregationPolicy -OrgName $Org.Name -NewOrgName $NewOrg.Name -PolicyName $linkAggregationPolicy.Name

                if ($linkAggregationPolicyNewOrg) {
                    $getLinkAggregationPolicyNewOrg = Get-IntersightFabricLinkAggregationPolicy -Moid $linkAggregationPolicyNewOrg.Moid -Organization $newOrgObj
                    $linkAggregationPolicyNewOrgObj = $getLinkAggregationPolicyNewOrg | Get-IntersightMoMoRef
                }
                # $ethNetGroupPolicyNewOrgObj = $ethNetGroupPolicyNewOrg | Get-IntersightMoMoRef
                # Update Uplink Role with Eth Network Group Policy
                Write-Debug "Attach Link Aggregation Policy to Uplink PC Role"
                Set-IntersightFabricUplinkPcRole -Moid $newUplinkPcRole.Moid -LinkAggregationPolicy $linkAggregationPolicyNewOrgObj | Out-Null
            }

            if ($newUplinkPcRole) {
                Write-Host "Uplink PC Role created and attached successfully to the new Port Policy!" -ForegroundColor Yellow
            }
        }
    }
}