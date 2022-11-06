<#
    Clone Port Mode and link to Port Policy
#>

Function Invoke-ClonePortMode {
    Param (
        $portPolicy,
        $newPortPolicy
    )

    $newPortPolicyObj = $newPortPolicy | Get-IntersightMoMoRef

    $portMode = Get-IntersightFabricPortMode -Parent ($portPolicy | Get-IntersightMoMoRef)

    if ($portMode) {
        foreach ($port in $portMode) {
            $custommode = $port.CustomMode
            $slotid = $port.SlotId
            $portidstart = $port.PortIdStart
            $portidend = $port.PortIdEnd
            $portMode = New-IntersightFabricPortMode -PortPolicy $newPortPolicyObj -CustomMode $custommode -SlotId $slotid -PortIdStart $portidstart -PortIdEnd $portidend

            if ($portMode) {
                Write-Host "Port Mode created and attached successfully to the new Port Policy!" -ForegroundColor Yellow
            }
        }
    }
}
