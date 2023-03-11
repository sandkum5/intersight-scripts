<#
    Script to get Port Count of all the FI's in Intersight
    Useful for situations when we want to find the number of ports in use on the FI's to count the needed licenses.
    
    Note: 
      Under Intersight > Infrastructure Service > Operate > Fabric Interconnects, the "Ports Used" column doesn't list the actual number of ports used. 
      This column includes the FC ports which are in disabled state.
      FC ports should not be included in license consumption if disabled. 
    
    Understanding When Ports Will Consume Licenses
      All configured Ethernet ports will consume licenses.
        This is regardless of whether the port is connected and has an active link or not.
        To release unneccessarily consumed licenses, unused Ethernet ports should be unconfigured.

      All FC ports that are not shutdown will consume licenses.
        To release unneccessarily consumed licenses, unused FC ports should be shut down.

     Ref: https://www.cisco.com/c/en/us/support/docs/servers-unified-computing/ucs-infrastructure-ucs-manager-software/200638-Understanding-and-Troubleshooting-UCS-Li.html#anc9

#>

$ApiParams = @{
    BasePath = "https://intersight.com"
    ApiKeyId = Get-Content -Path ./apiKey.txt -Raw
    ApiKeyFilePath = $pwd.Path + "/SecretKey.txt"
    HttpSigningHeader = @("(request-target)", "Host", "Date", "Digest")
}

Set-IntersightConfiguration @ApiParams

$FiInfo = Get-IntersightNetworkElementSummary | Select-Object Name,Moid,Model,Serial,Ipv4Address

foreach ($value in $FiInfo) {
    $moid = $value.Moid
    Write-Host "++++++++++++++++++++++++++++++++++++++++++"
    Write-Host "Domain: $($value.Name), $($value.Serial), $($value.Model), $($value.Ipv4Address), $($value.Moid)"

    # List Ethernet ports which are not in unconfigured state
    Write-Host ""
    Write-Host "Ethernet Ports"
    (Get-IntersightEtherPhysicalPort -Filter "Ancestors.Moid eq `'$moid`'").Results | Where-Object {($_.Role -notLike "unknown")} | Select-Object AdminState,PortId,SlotId,OperState,Role,SwitchId | ft
    
    # Uncomment below line to get the Port Count
    # ((Get-IntersightEtherPhysicalPort -Filter "Ancestors.Moid eq `'$moid`'").Results | Where-Object {($_.Role -notLike "unknown")} | Select-Object AdminState,PortId,SlotId,OperState,Role,SwitchId).Count
    
    # List FC Ports in Enabled state
    Write-Host "Fc Ports"
    (Get-IntersightFcPhysicalPort -Filter "Ancestors.Moid eq `'$moid`'").Results | Where-Object {($_.OperState -notLike "sfp-not-present") -and ($_.AdminState -NotLike "disabled")} | Select-Object AdminState,PortId,SlotId,OperState,Role,SwitchId | ft
    
    # Uncomment below line to get the Count
    # ((Get-IntersightFcPhysicalPort -Filter "Ancestors.Moid eq `'$moid`'").Results | Where-Object {($_.OperState -notLike "sfp-not-present") -and ($_.AdminState -NotLike "disabled")} | Select-Object AdminState,PortId,SlotId,OperState,Role,SwitchId).Count    
}
