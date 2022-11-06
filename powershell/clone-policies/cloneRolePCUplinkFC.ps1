<#
    Clone FC Uplink PC Role and attached to Port Policy
#>

Function Invoke-CloneFcUplinkPcRole {
    Param (
        $Org,
        $NewOrg,
        $PortPolicy,
        $NewPortPolicy
    )

    $newPortPolicyObj = $NewPortPolicy | Get-IntersightMoMoRef

    $orgObj = $Org | Get-IntersightMoMoRef
    # $newOrgObj = $NewOrg | Get-IntersightMoMoRef

    $portPolicyObj = Get-IntersightFabricPortPolicy -Moid $PortPolicy.Moid -Organization $orgObj | Get-IntersightMoMoRef

    $fcUplinkPcRole = Get-IntersightFabricFcUplinkPcRole -Parent $portPolicyObj
    $getNewFcUplinkPcRole = Get-IntersightFabricFcUplinkPcRole -Parent $newPortPolicyObj

    $newFcUplinkRoleMoidList = [System.Collections.ArrayList]@()
    foreach ($newfcuplink in $getNewFcUplinkPcRole) {
        $newFcUplinkRoleMoidList.Add($newfcuplink.Moid) | Out-Null
    }

    if ($fcUplinkPcRole) {
        foreach ($fcuplinkpc in $fcUplinkPcRole) {
            $adminspeed = $fcuplinkpc.AdminSpeed
            $pcid = $fcuplinkpc.PcId
            $ports = $fcuplinkpc.Ports
            $vsanid = $fcuplinkpc.VsanId
            $portList = [System.Collections.ArrayList]@()
            foreach ($port in $ports) {
                $portObj = Initialize-IntersightFabricPortIdentifier -ClassId "FabricPortIdentifier" -ObjectType "FabricPortIdentifier" -PortId $port.PortId -SlotId $port.SlotId -AggregatePortId $port.AggregatePortId
                $portList.Add($portObj) | Out-Null
            }
            # Create Uplink FC PC Role
            if ($fcuplinkpc.Moid -in $newFcUplinkRoleMoidList) {
                Write-Host "Uplink FC PC Role already exists in Target Org" -ForegroundColor "Blue"
                continue
            } else {
                Write-Debug "Update FC Uplink PC Role"
                $newFcUplinkPcRole = New-IntersightFabricFcUplinkPcRole -PortPolicy $newPortPolicyObj -AdminSpeed $adminspeed -PcId $pcid -Ports $portList -VsanId $vsanid
            }

            if ($newFcUplinkPcRole) {
                Write-Host "Uplink FC PC Role created and attached successfully to the new Port Policy!" -ForegroundColor Yellow
            }
        }
    }
}
