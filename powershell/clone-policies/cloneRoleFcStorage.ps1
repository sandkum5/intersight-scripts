<#
    Clone FC Storage Role and attach to New Port Policy
#>

Function Invoke-CloneFcStorageRole {
    Param (
        $portPolicy,
        $newPortPolicy
    )

    $newPortPolicyObj = $newPortPolicy | Get-IntersightMoMoRef

    $fcStorageRole = Get-IntersightFabricFcStorageRole -Parent ($portPolicy | Get-IntersightMoMoRef)

    if ($fcStorageRole) {
        foreach ($fcstorage in $fcStorageRole) {
            $adminspeed = $fcstorage.AdminSpeed
            $slotid = $fcstorage.SlotId
            $portid = $fcstorage.PortId
            $vsanid = $fcstorage.VsanId
            # $aggregateportid = $fcstorage.AggregatePortId
            $fcStorageRole = New-IntersightFabricFcStorageRole -PortPolicy $newPortPolicyObj -AdminSpeed $adminspeed -SlotId $slotid -PortId $portid -VsanId $vsanid # -AggregatePortId

            if ($fcStorageRole) {
                Write-Host "FC Storage Role created and attached successfully to the new Port Policy!" -ForegroundColor Yellow
            }
        }
    }
}
