<#
    Script to pull Port utilization on the FI's and export to Excel
#>

$ApiParams = @{
    BasePath = "https://intersight.com"
    ApiKeyId = Get-Content -Path ./apiKey.txt -Raw
    ApiKeyFilePath = $pwd.Path + "/SecretKey.txt"
    HttpSigningHeader = @("(request-target)", "Host", "Date", "Digest")
}

Set-IntersightConfiguration @ApiParams

$InterSightFISummary = $Null
$InterSightFISummary = Get-InterSightNetworkElementSummary | Select-Object Name, Model, Ipv4Address, Vendor, _Version, Moid, DeviceMoId, SwitchType, EthernetSwitchingMode, FcSwitchingMode, ManagementMode, Thermal, AdminEvacState, AdminInbandInterfaceState, Dn, EthernetMode, FaultSummary, FcMode, FirmwareVersion, NumEtherPorts, NumEtherPortsConfigured, NumEtherPortsLinkUp, NumExpansionModules, NumFcPorts, NumFcPortsConfigured, NumFcPortsLinkUp, OperEvacState, Operability, OutOfBandIpAddress, OutOfBandIpGateway, OutOfBandIpMask, OutOfBandIpv4Address, OutOfBandIpv4Gateway, OutOfBandIpv4Mask, OutOfBandMac, Serial, SwitchId, TotalMemory, CreateTime, DomainGroupMoid, ModTime

$InterSightEtherPhysicalPorts = $InterSightFCPhysicalPorts = @()

ForEach ($InterSightFISumm in $InterSightFISummary) {
    $Moid = $InterSightFCPhysicalPortDetails = $InterSightFCPhysicalPortDetails = $Null
    $Moid = $InterSightFISumm.Moid

    $InterSightEtherPhysicalPortDetails = (Get-IntersightEtherPhysicalPort -Filter "Ancestors.Moid eq `'$Moid`'").Results | Select-Object ObjectType, AdminState, AggregatePortId, LicenseState, MacAddress, Mode, OperSpeed, PeerDn, PortChannelId, PortType, OperState, PortId, Role, SlotId, SwitchId, ModTime, DomainGroupMoid

    $InterSightFCPhysicalPortDetails = (Get-IntersightFCPhysicalPort -Filter "Ancestors.Moid eq `'$Moid`'").Results | Select-Object ObjectType, AdminState, AggregatePortId, LicenseState, MacAddress, Mode, OperSpeed, PeerDn, PortChannelId, PortType, OperState, PortId, Role, SlotId, SwitchId, ModTime, DomainGroupMoid

    ForEach ($InterSightEtherPhysicalPortDetail in $InterSightEtherPhysicalPortDetails) {
        $InterSightEtherPhysicalPort = New-Object PSObject
        $InterSightEtherPhysicalPort | Add-Member -NotePropertyName "FI Name" -NotePropertyValue $InterSightFISumm.Name
        $InterSightEtherPhysicalPort | Add-Member -NotePropertyName "FI Domain Name" -NotePropertyValue (($InterSightFISumm.Name).split(" ")[0])
        $InterSightEtherPhysicalPort | Add-Member -NotePropertyName "FI Model Number" -NotePropertyValue $InterSightFISumm.Model
        $InterSightEtherPhysicalPort | Add-Member -NotePropertyName "FI Serial Number" -NotePropertyValue $InterSightFISumm.Serial
        $InterSightEtherPhysicalPort | Add-Member -NotePropertyName "FI Version" -NotePropertyValue $InterSightFISumm._Version
        $InterSightEtherPhysicalPort | Add-Member -NotePropertyName "FI Firmware Version" -NotePropertyValue $InterSightFISumm.FirmwareVersion
        $InterSightEtherPhysicalPort | Add-Member -NotePropertyName "FI Ethernet Port Object Type" -NotePropertyValue ($InterSightEtherPhysicalPortDetail.ObjectType)
        $InterSightEtherPhysicalPort | Add-Member -NotePropertyName "FI Ethernet Port Admin State" -NotePropertyValue ($InterSightEtherPhysicalPortDetail.AdminState)
        $InterSightEtherPhysicalPort | Add-Member -NotePropertyName "FI Ethernet Port Aggregate Port Id" -NotePropertyValue ($InterSightEtherPhysicalPortDetail.AggregatePortId)
        $InterSightEtherPhysicalPort | Add-Member -NotePropertyName "FI Ethernet Port License State" -NotePropertyValue ($InterSightEtherPhysicalPortDetail.LicenseState)
        $InterSightEtherPhysicalPort | Add-Member -NotePropertyName "FI Ethernet Port Mac Address" -NotePropertyValue ($InterSightEtherPhysicalPortDetail.MacAddress)
        $InterSightEtherPhysicalPort | Add-Member -NotePropertyName "FI Ethernet Port Mode" -NotePropertyValue ($InterSightEtherPhysicalPortDetail.Mode)
        $InterSightEtherPhysicalPort | Add-Member -NotePropertyName "FI Ethernet Port Operational Speed" -NotePropertyValue ($InterSightEtherPhysicalPortDetail.OperSpeed)
        $InterSightEtherPhysicalPort | Add-Member -NotePropertyName "FI Ethernet Port Peer DN" -NotePropertyValue ($InterSightEtherPhysicalPortDetail.PeerDn)
        $InterSightEtherPhysicalPort | Add-Member -NotePropertyName "FI Ethernet Port Channel Id" -NotePropertyValue ($InterSightEtherPhysicalPortDetail.PortChannelId)
        $InterSightEtherPhysicalPort | Add-Member -NotePropertyName "FI Ethernet Port Type" -NotePropertyValue ($InterSightEtherPhysicalPortDetail.PortType)
        $InterSightEtherPhysicalPort | Add-Member -NotePropertyName "FI Ethernet Port Operational State" -NotePropertyValue ($InterSightEtherPhysicalPortDetail.OperState)
        $InterSightEtherPhysicalPort | Add-Member -NotePropertyName "FI Ethernet Port Id" -NotePropertyValue ($InterSightEtherPhysicalPortDetail.PortId)
        $InterSightEtherPhysicalPort | Add-Member -NotePropertyName "FI Ethernet Port Role" -NotePropertyValue ($InterSightEtherPhysicalPortDetail.Role)
        $InterSightEtherPhysicalPort | Add-Member -NotePropertyName "FI Ethernet Port Slot Id" -NotePropertyValue ($InterSightEtherPhysicalPortDetail.SlotId)
        $InterSightEtherPhysicalPort | Add-Member -NotePropertyName "FI Ethernet Port Switch Id" -NotePropertyValue ($InterSightEtherPhysicalPortDetail.SwitchId)
        $InterSightEtherPhysicalPort | Add-Member -NotePropertyName "FI Ethernet Port Mod Time" -NotePropertyValue ($InterSightEtherPhysicalPortDetail.ModTime)
        $InterSightEtherPhysicalPort | Add-Member -NotePropertyName "FI Ethernet Port Domain Group Moid" -NotePropertyValue ($InterSightEtherPhysicalPortDetail.DomainGroupMoid)
        $InterSightEtherPhysicalPorts+= $InterSightEtherPhysicalPort
    }
    ForEach ($InterSightFCPhysicalPortDetail in $InterSightFCPhysicalPortDetails) {
        $InterSightFCPhysicalPort = New-Object PSObject
        $InterSightFCPhysicalPort | Add-Member -NotePropertyName "FI Name" -NotePropertyValue $InterSightFISumm.Name
        $InterSightFCPhysicalPort | Add-Member -NotePropertyName "FI Domain Name" -NotePropertyValue (($InterSightFISumm.Name).split(" ")[0])
        $InterSightFCPhysicalPort | Add-Member -NotePropertyName "FI Model Number" -NotePropertyValue $InterSightFISumm.Model
        $InterSightFCPhysicalPort | Add-Member -NotePropertyName "FI Serial Number" -NotePropertyValue $InterSightFISumm.Serial
        $InterSightFCPhysicalPort | Add-Member -NotePropertyName "FI Version" -NotePropertyValue $InterSightFISumm._Version
        $InterSightFCPhysicalPort | Add-Member -NotePropertyName "FI Firmware Version" -NotePropertyValue $InterSightFISumm.FirmwareVersion
        $InterSightFCPhysicalPort | Add-Member -NotePropertyName "FI FC Port Object Type" -NotePropertyValue ($InterSightFCPhysicalPortDetail.ObjectType)
        $InterSightFCPhysicalPort | Add-Member -NotePropertyName "FI FC Port Admin State" -NotePropertyValue ($InterSightFCPhysicalPortDetail.AdminState)
        $InterSightFCPhysicalPort | Add-Member -NotePropertyName "FI FC Port Aggregate Port Id" -NotePropertyValue ($InterSightFCPhysicalPortDetail.AggregatePortId)
        $InterSightFCPhysicalPort | Add-Member -NotePropertyName "FI FC Port License State" -NotePropertyValue ($InterSightFCPhysicalPortDetail.LicenseState)
        $InterSightFCPhysicalPort | Add-Member -NotePropertyName "FI FC Port Mac Address" -NotePropertyValue ($InterSightFCPhysicalPortDetail.MacAddress)
        $InterSightFCPhysicalPort | Add-Member -NotePropertyName "FI FC Port Mode" -NotePropertyValue ($InterSightFCPhysicalPortDetail.Mode)
        $InterSightFCPhysicalPort | Add-Member -NotePropertyName "FI FC Port Operational Speed" -NotePropertyValue ($InterSightFCPhysicalPortDetail.OperSpeed)
        $InterSightFCPhysicalPort | Add-Member -NotePropertyName "FI FC Port Peer DN" -NotePropertyValue ($InterSightFCPhysicalPortDetail.PeerDn)
        $InterSightFCPhysicalPort | Add-Member -NotePropertyName "FI FC Port Channel Id" -NotePropertyValue ($InterSightFCPhysicalPortDetail.PortChannelId)
        $InterSightFCPhysicalPort | Add-Member -NotePropertyName "FI FC Port Type" -NotePropertyValue ($InterSightFCPhysicalPortDetail.PortType)
        $InterSightFCPhysicalPort | Add-Member -NotePropertyName "FI FC Port Operational State" -NotePropertyValue ($InterSightFCPhysicalPortDetail.OperState)
        $InterSightFCPhysicalPort | Add-Member -NotePropertyName "FI FC Port Id" -NotePropertyValue ($InterSightFCPhysicalPortDetail.PortId)
        $InterSightFCPhysicalPort | Add-Member -NotePropertyName "FI FC Port Role" -NotePropertyValue ($InterSightFCPhysicalPortDetail.Role)
        $InterSightFCPhysicalPort | Add-Member -NotePropertyName "FI FC Port Slot Id" -NotePropertyValue ($InterSightFCPhysicalPortDetail.SlotId)
        $InterSightFCPhysicalPort | Add-Member -NotePropertyName "FI FC Port Switch Id" -NotePropertyValue ($InterSightFCPhysicalPortDetail.SwitchId)
        $InterSightFCPhysicalPort | Add-Member -NotePropertyName "FI FC Port Mod Time" -NotePropertyValue ($InterSightFCPhysicalPortDetail.ModTime)
        $InterSightFCPhysicalPort | Add-Member -NotePropertyName "FI FC Port Domain Group Moid" -NotePropertyValue ($InterSightFCPhysicalPortDetail.DomainGroupMoid)
        $InterSightFCPhysicalPorts+= $InterSightFCPhysicalPort
    }
}

$InterSightEtherPhysicalPorts | Export-CSV (Excel csv file path) -NoType
$InterSightFCPhysicalPorts | Export-CSV (Excel csv file path) -NoType
