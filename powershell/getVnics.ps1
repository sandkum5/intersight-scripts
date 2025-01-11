<#
    Script to get VNIC information
    Creats an excel with following keys as columns:
      Name, MacAddress, VethId, StandbyVifId, FailoverEnabled, AllowedVlans, NativeVlan, SwitchId, PCIeId, 
      AdapterUplink, Mtu, Priority, Cos, ServerProfile, ServerName, ServerModel, ServerSerial, LanConnPolicy, 
      VethOperState, VethOperReason, VethBoundInterfaceDn, VethPinnedInterfaceDn, FiSwitchProfileName, FiSwitchId, 
      FiModel, FiSerial, FiAdminEvacState, FiOperEvacState, FiOperability, FiManagementMode
#>

$ApiParams = @{
    BasePath = "https://intersight.com"
    ApiKeyId = Get-Content -Path ./apiKey.txt -Raw
    ApiKeyFilePath = $pwd.Path + "/SecretKey.txt"
    HttpSigningHeader = @("(request-target)", "Host", "Date", "Digest")
}

Set-IntersightConfiguration @ApiParams


# Get Veth Data
$skip = 0
$count = 0
$totalCount = (Get-IntersightNetworkVethernet -Count $true).Count

while ($count -le $totalCount)
{
    $vethData = (Get-IntersightNetworkVethernet -Top 1000 -Skip $skip -Expand 'NetworkElement($select=SwitchProfileName,Serial,SwitchId,Model,ManagementMode,Operability,AdminEvacState,OperEvacState)' -Select 'VethId,Description,BoundInterfaceDn,NetworkElement,OperState,OperReason,PinnedInterfaceDn').Results

    #Create an empty array in the variable $vnicArray we'll add the objects to
    [System.Collections.ArrayList]$vethArray = @()
    #Iterate through each vnic in $vnics with a ForEach loop
    ForEach($data in $vethData) {
        $fiData = $data.NetworkElement.ActualInstance
        $dataObject = [PSCustomObject]@{
            VethId                = $data.VethId
            VethOperState         = $data.OperState
            VethBoundInterfaceDn  = $data.BoundInterfaceDn
            VethDescription       = $data.Description
            VethOperReason        = $data.OperReason
            VethPinnedInterfaceDn = $data.PinnedInterfaceDn
            FiAdminEvacState      = $fiData.AdminEvacState
            FiManagementMode      = $fiData.ManagementMode
            FiOperEvacState       = $fiData.OperEvacState
            FiOperability         = $fiData.Operability
            FiSwitchProfileName   = $fiData.SwitchProfileName
            FiSwitchId            = $fiData.SwitchId
            FiModel               = $fiData.Model
            FiSerial              = $fiData.Serial
        }
        $vethArray.Add($dataObject) | Out-Null
    }
    $skip += 1000
    $count += 1000
}

# Get Server vNIC Data
$skip = 0
$count = 0
$totalCount = (Get-IntersightVnicEthIf -Count $true -Filter "LcpVnic ne 'null'").Count

while ($count -le $totalCount)
{
    $vnicData = (Get-IntersightVnicEthIf -Top 1000 -Skip $skip -Filter "LcpVnic ne 'null'" -Select "Name,MacAddress,FailoverEnabled,VifId,StandbyVifId,Placement,Profile,EthQosPolicy,FabricEthNetworkGroupPolicy,LcpVnic" -Expand 'Profile($select=Name,AssociatedServer;$expand=AssociatedServer($select=Name,Model,Serial)),EthQosPolicy($select=Mtu,Cos,Priority),FabricEthNetworkGroupPolicy($select=VlanSettings),LcpVnic($select=LanConnectivityPolicy;$expand=LanConnectivityPolicy($select=Name))').Results

    #Create an empty array in the variable $vnicArray we'll add the objects to
    [System.Collections.ArrayList]$vnicArray = @()
    #Iterate through each vnic in $vnics with a ForEach loop
    ForEach($data in $vnicData) {
        $dataObject = [PSCustomObject]@{
            Name = $data.Name
            MacAddress = $data.MacAddress
            # Order = $data.Order
            VethId = $data.VifId
            StandbyVifId = $data.StandbyVifId
            FailoverEnabled = $data.FailoverEnabled
            AllowedVlans = $data.FabricEthNetworkGroupPolicy.ActualInstance.VlanSettings.AllowedVlans
            NativeVlan = $data.FabricEthNetworkGroupPolicy.ActualInstance.VlanSettings.NativeVlan
            SwitchId      = $data.Placement.SwitchId
            PCIeId        = $data.Placement.Id
            AdapterUplink = $data.Placement.Uplink
            Mtu           = $data.EthQosPolicy.ActualInstance.Mtu
            Priority      = $data.EthQosPolicy.ActualInstance.Priority
            Cos           = $data.EthQosPolicy.ActualInstance.Cos
            ServerProfile = $data.Profile.ActualInstance.Name
            ServerName   = ($data.Profile.ActualInstance.AdditionalProperties['AssociatedServer'].ToString() | ConvertFrom-Json).Name
            ServerModel = ($data.Profile.ActualInstance.AdditionalProperties['AssociatedServer'].ToString() | ConvertFrom-Json).Model
            ServerSerial = ($data.Profile.ActualInstance.AdditionalProperties['AssociatedServer'].ToString() | ConvertFrom-Json).Serial
            LanConnPolicy = $data.LcpVnic.ActualInstance.LanConnectivityPolicy.ActualInstance.Name
        }
        $vnicArray.Add($dataObject) | Out-Null
    }
    $skip += 1000
    $count += 1000
}

# Merge Veth Data with Vnic Data and Write to Excel
ForEach($vnic in $vnicArray) {
    ForEach($veth in $vethArray) {
        if ($veth.VethId -eq $vnic.VethId) {
            $vnic | Add-Member -MemberType NoteProperty -Name VethOperState         -Value $veth.VethOperState
            $vnic | Add-Member -MemberType NoteProperty -Name VethOperReason        -Value $veth.VethOperReason
            # $vnic | Add-Member -MemberType NoteProperty -Name VethDescription       -Value $veth.VethDescription
            $vnic | Add-Member -MemberType NoteProperty -Name VethBoundInterfaceDn  -Value $veth.VethBoundInterfaceDn
            $vnic | Add-Member -MemberType NoteProperty -Name VethPinnedInterfaceDn -Value $veth.VethPinnedInterfaceDn
            $vnic | Add-Member -MemberType NoteProperty -Name FiSwitchProfileName   -Value $veth.FiSwitchProfileName 
            $vnic | Add-Member -MemberType NoteProperty -Name FiSwitchId            -Value $veth.FiSwitchId
            $vnic | Add-Member -MemberType NoteProperty -Name FiModel               -Value $veth.FiModel
            $vnic | Add-Member -MemberType NoteProperty -Name FiSerial              -Value $veth.FiSerial
            $vnic | Add-Member -MemberType NoteProperty -Name FiAdminEvacState      -Value $veth.FiAdminEvacState
            $vnic | Add-Member -MemberType NoteProperty -Name FiOperEvacState       -Value $veth.FiOperEvacState
            $vnic | Add-Member -MemberType NoteProperty -Name FiOperability         -Value $veth.FiOperability
            $vnic | Add-Member -MemberType NoteProperty -Name FiManagementMode      -Value $veth.FiManagementMode
        }
    }
}

$vnicArray | Export-Csv -Path "vnics.csv" -NoTypeInformation -Append 
