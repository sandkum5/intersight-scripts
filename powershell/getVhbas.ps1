<#
  
#>

$ApiParams = @{
    BasePath = "https://intersight.com"
    ApiKeyId = Get-Content -Path ./apiKey.txt -Raw
    ApiKeyFilePath = $pwd.Path + "/SecretKey.txt"
    HttpSigningHeader = @("(request-target)", "Host", "Date", "Digest")
}

Set-IntersightConfiguration @ApiParams


# Get Vfc Data from FI
$skip = 0
$count = 0
$totalCount = (Get-IntersightNetworkVfc -Count $true).Count

while ($count -le $totalCount)
{
    $vfcData = (Get-IntersightNetworkVfc -Top 1000 -Skip $skip -Expand 'NetworkElement($select=SwitchProfileName,Serial,SwitchId,Model,ManagementMode,Operability,AdminEvacState,OperEvacState)' -Select 'VfcId,Description,BoundInterfaceDn,PinnedInterfaceDn,OperState,OperReason,NetworkElement').Results

    #Create an empty array in the variable $vnicArray we'll add the objects to
    [System.Collections.ArrayList]$vfcArray = @()
    #Iterate through each vnic in $vnics with a ForEach loop
    ForEach($data in $vfcData) {
        $fiData = $data.NetworkElement.ActualInstance
        $dataObject = [PSCustomObject]@{
            VfcId                 = $data.VfcId
            VfcDescription       = $data.Description
            VfcBoundInterfaceDn  = $data.BoundInterfaceDn
            VfcPinnedInterfaceDn = $data.PinnedInterfaceDn
            VfcOperState         = $data.OperState
            VfcOperReason        = $data.OperReason
            FiAdminEvacState     = $fiData.AdminEvacState
            FiManagementMode     = $fiData.ManagementMode
            FiOperEvacState      = $fiData.OperEvacState
            FiOperability        = $fiData.Operability
            FiSwitchProfileName  = $fiData.SwitchProfileName
            FiSwitchId           = $fiData.SwitchId
            FiModel              = $fiData.Model
            FiSerial             = $fiData.Serial
        }
        $vfcArray.Add($dataObject) | Out-Null
    }
    $skip += 1000
    $count += 1000
}



# Get Server vHBA Data
$skip = 0
$count = 0
$totalCount = (Get-IntersightVnicFcIf -Count $true -Filter "ScpVhba ne 'null'").Count

while ($count -le $totalCount)
{
    $vhbaData = (Get-IntersightVnicFcIf -Top 1000 -Skip $skip -Filter "ScpVhba ne 'null'" -Select "Name,Wwpn,VifId,Order,Type,Placement,Profile,ScpVhba" -Expand 'Profile($select=Name,AssociatedServer;$expand=AssociatedServer($select=Name,Model,Serial)),ScpVhba($select=SanConnectivityPolicy;$expand=SanConnectivityPolicy($select=Name))').Results

    #Create an empty array in the variable $vnicArray we'll add the objects to
    [System.Collections.ArrayList]$vhbaArray = @()
    #Iterate through each vnic in $vnics with a ForEach loop
    ForEach($data in $vhbaData) {
        $dataObject = [PSCustomObject]@{
            Name          = $data.Name
            Wwpn          = $data.Wwpn
            VfcId         = $data.VifId
            VhbaType      = $data.Type
            SwitchId      = $data.Placement.SwitchId
            PCIeId        = $data.Placement.Id
            AdapterUplink = $data.Placement.Uplink
            ServerProfile = $data.Profile.ActualInstance.Name
            ServerName    = ($data.Profile.ActualInstance.AdditionalProperties['AssociatedServer'].ToString() | ConvertFrom-Json).Name
            ServerModel   = ($data.Profile.ActualInstance.AdditionalProperties['AssociatedServer'].ToString() | ConvertFrom-Json).Model
            ServerSerial  = ($data.Profile.ActualInstance.AdditionalProperties['AssociatedServer'].ToString() | ConvertFrom-Json).Serial
            SanConnPolicy = $data.ScpVhba.ActualInstance.SanConnectivityPolicy.ActualInstance.Name
        }
        $vhbaArray.Add($dataObject) | Out-Null
    }
    $skip += 1000
    $count += 1000
}

# Merge Vfc Data with Vhba Data and Write to Excel
ForEach($vhba in $vhbaArray) {
    ForEach($vfc in $vfcArray) {
        if ($vfc.VfcId -eq $vhba.VfcId) {
            $vhba | Add-Member -MemberType NoteProperty -Name VfcDescription       -Value $vfc.VfcDescription  
            $vhba | Add-Member -MemberType NoteProperty -Name VfcBoundInterfaceDn  -Value $vfc.VfcBoundInterfaceDn
            $vhba | Add-Member -MemberType NoteProperty -Name VfcPinnedInterfaceDn -Value $vfc.VfcPinnedInterfaceDn
            $vhba | Add-Member -MemberType NoteProperty -Name VfcOperState         -Value $vfc.VfcOperState
            $vhba | Add-Member -MemberType NoteProperty -Name VfcOperReason        -Value $vfc.VfcOperReason
            $vhba | Add-Member -MemberType NoteProperty -Name FiSwitchProfileName  -Value $vfc.FiSwitchProfileName 
            $vhba | Add-Member -MemberType NoteProperty -Name FiSwitchId           -Value $vfc.FiSwitchId
            $vhba | Add-Member -MemberType NoteProperty -Name FiModel              -Value $vfc.FiModel
            $vhba | Add-Member -MemberType NoteProperty -Name FiSerial             -Value $vfc.FiSerial
            $vhba | Add-Member -MemberType NoteProperty -Name FiAdminEvacState     -Value $vfc.FiAdminEvacState
            $vhba | Add-Member -MemberType NoteProperty -Name FiOperEvacState      -Value $vfc.FiOperEvacState
            $vhba | Add-Member -MemberType NoteProperty -Name FiOperability        -Value $vfc.FiOperability
            $vhba | Add-Member -MemberType NoteProperty -Name FiManagementMode     -Value $vfc.FiManagementMode
        }
    }
}

$vhbaArray | Export-Csv -Path "vhba.csv" -NoTypeInformation -Append 
