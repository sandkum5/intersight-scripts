<#
    Clone FC Uplink Role and attach to New Port Policy
#>

Function Invoke-CloneFcUplinkRole {
    Param (
        $portPolicy,
        $newPortPolicy
    )

    $newPortPolicyObj = $newPortPolicy | Get-IntersightMoMoRef

    $fcUplinkRole = Get-IntersightFabricFcUplinkRole -Parent ($portPolicy | Get-IntersightMoMoRef)

    if ($fcUplinkRole) {
        foreach ($fcuplink in $fcUplinkRole) {
            $adminspeed = $fcuplink.AdminSpeed
            $slotid = $fcuplink.SlotId
            $portid = $fcuplink.PortId
            $vsanid = $fcuplink.VsanId
            # $aggregateportid = $fcuplink.AggregatePortId
            $fcUplinkRole = New-IntersightFabricFcUplinkRole -PortPolicy $newPortPolicyObj -AdminSpeed $adminspeed -SlotId $slotid -PortId $portid -VsanId $vsanid # -AggregatePortId $aggregateportid

            if ($fcUplinkRole) {
                Write-Host "FC Uplink Role created and attached successfully to the new Port Policy!" -ForegroundColor Yellow
            }
        }
    }
}
