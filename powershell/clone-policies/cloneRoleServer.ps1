<#
    Clone Server Role and attach to New Port Policy
#>

Function Invoke-CloneServerRole {
    Param (
        $portPolicy,
        $newPortPolicy
    )

    $newPortPolicyObj = $newPortPolicy | Get-IntersightMoMoRef

    $ServerRole = Get-IntersightFabricServerRole -Parent ($portPolicy | Get-IntersightMoMoRef)

    if ($ServerRole) {
        foreach ($Server in $ServerRole) {
            $slotid = $Server.SlotId
            $portid = $Server.PortId
            $autonegotiationdisabled = $Server.AutoNegotiationDisabled
            $additionalproperties= $Server.AdditionalProperties
            $ServerRole = New-IntersightFabricServerRole -PortPolicy $newPortPolicyObj -SlotId $slotid -PortId $portid -AutoNegotiationDisabled $autonegotiationdisabled -AdditionalProperties $additionalproperties

            if ($ServerRole) {
                Write-Host "Server Role created and attached successfully to the new Port Policy!" -ForegroundColor Yellow
            }
        }
    }
}
