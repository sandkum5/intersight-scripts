<#
    Clone Appliance Role and attach to New Port Policy
#>

. ./cloneEthNetGroupPolicy.ps1
. ./cloneEthNetControlPolicy.ps1

Function Invoke-CloneApplianceRole {
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

    $ApplianceRole = Get-IntersightFabricApplianceRole -Parent $portPolicyObj
    $newApplianceRole = Get-IntersightFabricApplianceRole -Parent $newPortPolicyObj

    $newApplianceRoleMoidList = [System.Collections.ArrayList]@()
    foreach ($newAppliance in $newApplianceRole) {
        $newApplianceRoleMoidList.Add($newAppliance.Moid) | Out-Null
    }

    if ($ApplianceRole) {
        foreach ($Appliance in $ApplianceRole) {
            $adminspeed = $Appliance.AdminSpeed
            $slotid = $Appliance.SlotId
            $portid = $Appliance.PortId
            $fec    = $Appliance.Fec
            $priority = $Appliance.Priority
            $mode = $Appliance.Mode

            # Attach Ethernet Network Control Policy to Appliance Role
            if ($Appliance.EthNetworkControlPolicy) {
                $ethnetcontrolpolicyMoid = $Appliance.EthNetworkControlPolicy.ActualInstance.Moid
                $ethnetcontrolpolicy = Get-IntersightFabricEthNetworkControlPolicy -Moid $ethnetcontrolpolicyMoid -Organization $OrgObj

                $ethNetControlPolicyNewOrg = Invoke-CloneEthNetControlPolicy -OrgName $Org.Name -NewOrgName $NewOrg.Name -PolicyName $ethnetcontrolpolicy.Name

                if ($ethNetControlPolicyNewOrg) {
                    $getethNetControlPolicyNewOrg = Get-IntersightFabricEthNetworkControlPolicy -Moid $ethNetControlPolicyNewOrg.Moid -Organization $newOrgObj
                    $ethNetControlPolicyNewOrgObj = $getethNetControlPolicyNewOrg | Get-IntersightMoMoRef
                }
                # Write-Debug "Attach Ethernet Network Control Policy to Appliance Role"
                # Set-IntersightFabricApplianceRole -Moid $newApplianceRole.Moid -EthNetworkControlPolicy $ethNetControlPolicyNewOrgObj | Out-Null
            }

            # Attach Ethernet Network Group Policy to Appliance role
            if ($Appliance.EthNetworkGroupPolicy) {
                $ethnetgrouppolicyMoid = $Appliance.EthNetworkGroupPolicy.ActualInstance.Moid
                $ethnetgrouppolicy = Get-IntersightFabricEthNetworkGroupPolicy -Moid $ethnetgrouppolicyMoid -Organization $OrgObj

                $ethNetGroupPolicyNewOrg = Invoke-CloneEthNetGroupPolicy -OrgName $Org.Name -NewOrgName $NewOrg.Name -PolicyName $ethnetgrouppolicy.Name

                if ($ethNetGroupPolicyNewOrg) {
                    $getethNetGroupPolicyNewOrg = Get-IntersightFabricEthNetworkGroupPolicy -Moid $ethNetGroupPolicyNewOrg.Moid -Organization $newOrgObj
                    $ethNetGroupPolicyNewOrgObj = $getethNetGroupPolicyNewOrg | Get-IntersightMoMoRef
                }
                # $ethNetGroupPolicyNewOrgObj = $ethNetGroupPolicyNewOrg | Get-IntersightMoMoRef
                # Update Appliance Role with Eth Network Group Policy
                # Write-Debug "Attach Ethernet Network Group Policy to Appliance Role"
                # Set-IntersightFabricApplianceRole -Moid $newApplianceRole.Moid -EthNetworkGroupPolicy $ethNetGroupPolicyNewOrgObj | Out-Null
            }

            # Create Appliance Role
            if ($Appliance.Moid -in $newApplianceRoleMoidList) {
                Write-Host "Appliance Role already exists in Target Org" -ForegroundColor "Blue"
                continue
            } else {
                Write-Debug "Update Appliance Role"
                $newApplianceRole = New-IntersightFabricApplianceRole -PortPolicy $newPortPolicyObj -AdminSpeed $adminspeed -SlotId $slotid -PortId $portid -Fec $fec -Priority $priority -Mode $mode -EthNetworkControlPolicy $ethNetControlPolicyNewOrgObj -EthNetworkGroupPolicy $ethNetGroupPolicyNewOrgObj
            }
            if ($newApplianceRole) {
                Write-Host "Appliance Role created and attached successfully to the new Port Policy!" -ForegroundColor Yellow
            }
        }
    }
}