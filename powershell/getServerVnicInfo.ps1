<#
    Get VNIC info for a Server Profile
#>

Function Invoke-GetVnicInfo {
    Param (
        [string]$OrgName = 'default',
        [string]$ServerProfileName
    )

    $OrgRel = Get-IntersightOrganizationOrganization -Name $OrgName | Get-IntersightMoMoRef
    $ServerProfile = Get-IntersightServerProfile -Name $ServerProfileName -Organization $OrgRel

    $PolicyBucket = $ServerProfile.PolicyBucket.ActualInstance | Select-Object ObjectType,Moid

    foreach ($Policy in $PolicyBucket) {
        if ($Policy.ObjectType -eq 'VnicLanConnectivityPolicy') {
            $VnicLanConnectivityPolicy = Get-IntersightVnicLanConnectivityPolicy -Moid $Policy.Moid
            $LanConnectivityInfo = $VnicLanConnectivityPolicy | Select-Object Name,Moid,Description,TargetPlatform,PlacementMode # ,AzureQosEnabled,StaticIqnName,IqnPool
        }
    }

    if ($ServerProfile.AssignedServer) {
        $ServerType = $ServerProfile.AssignedServer.ActualInstance.ObjectType
        $ServerMoid = $ServerProfile.AssignedServer.ActualInstance.Moid
        if ($ServerType -eq 'ComputeBlade') {
            $ServerInfo = Get-IntersightComputeBlade -Moid $ServerMoid | Select-Object Name,Pid,Model,Serial,Dn,MgmtIpAddress
        }
        if ($ServerType -eq 'ComputeRackUnit') {
            $ServerInfo = Get-IntersightComputeRackUnit -Moid $ServerMoid | Select-Object Name,Pid,Model,Serial,Dn,MgmtIpAddress
        }
    }

    $VnicEthIfs = (Get-IntersightVnicEthIf -Filter "(Profile.Moid eq '$($ServerProfile.Moid)')").Results

    Write-Host " "
    Write-Host "Server Profile Info:"
    Write-Host "Name                        : $($ServerProfile.Name)"
    Write-Host "Description                 : $($ServerProfile.Description)"
    # Write-Host "Moid                        : $($ServerProfile.Moid)"
    Write-Host "Server Profile Organization : $($orgName)"
    Write-Host " "
    Write-Host " --- Physical Server Info --- "
    Write-Host ($ServerInfo | Format-List | Out-String).Trim()
    Write-Host " "

    if ($LanConnectivityInfo) {
        Write-Host " --- Server LAN Connectivity Info --- "
        Write-Host ($LanConnectivityInfo | Format-List | Out-String).Trim()
        Write-Host " "

        # Get VNIC Info
        foreach ($interface in $VnicEthIfs) {
            $VnicEthIfInfo = $interface | Select-Object Name,MacAddress,FailoverEnabled,Order,PinGroupName,StandbyVifId,VifId #,IscsiIpV4AddressAllocationType,MacAddressType,IscsiIpv4Address,StaticMacAddress,IpLease,MacLease

            # $Cdn                           = $interface.Cdn | Select-Object Source,Value,AdditionalProperties

            # $IscsiIpV4Config               = $interface.IscsiIpV4Config | Select-Object Gateway,Netmask,PrimaryDns,SecondaryDns,AdditionalProperties

            $Placement                     = $interface.Placement | Select-Object SwitchId,Id,PciLink,Uplink # ,AdditionalProperties

            # $UsnicSettings                 = $interface.UsnicSettings | Select-Object Cos,Count,UsnicAdapterPolicy,AdditionalProperties

            # $VmqSettings                   = $interface.VmqSettings | Select-Object Enabled,MultiQueueSupport,NumInterrupts,NumSubVnics,NumVmqs,VmmqAdapterPolicy,AdditionalProperties

            if ($interface.EthAdapterPolicy) {
                $EthAdapterPolicyMoid = $interface.EthAdapterPolicy.ActualInstance.Moid
                $EthAdapterPolicy = Get-IntersightVnicEthAdapterPolicy -Moid $EthAdapterPolicyMoid
                $EthAdapterPolicyName = $EthAdapterPolicy.Name
            }

            if ($interface.EthNetworkPolicy) {
                $EthNetworkPolicyMoid = $interface.EthNetworkPolicy.ActualInstance.Moid
                $EthNetworkPolicy = Get-IntersightVnicEthNetworkPolicy -Moid $EthNetworkPolicyMoid
                $EthNetworkPolicyName = $EthNetworkPolicy.Name
            }

            if ($interface.EthQosPolicy) {
                $EthQosPolicyMoid = $interface.EthQosPolicy.ActualInstance.Moid
                $EthQosPolicy = Get-IntersightVnicEthQosPolicy -Moid $EthQosPolicyMoid
                $EthQosPolicyName = $EthQosPolicy.Name
                $QosInfo = $EthQosPolicy | Select-Object Priority,Burst,Cos,Mtu,RateLimit,TrustHostCos
            }

            if ($interface.FabricEthNetworkControlPolicy) {
                $FabricEthNetworkControlPolicyMoid = $interface.FabricEthNetworkControlPolicy.ActualInstance.Moid
                $FabricEthNetworkControlPolicy = Get-IntersightFabricEthNetworkControlPolicy -Moid $FabricEthNetworkControlPolicyMoid
                $FabricEthNetworkControlPolicyName = $FabricEthNetworkControlPolicy.Name
            }

            if ($interface.FabricEthNetworkGroupPolicy) {
                $FabricEthNetworkGroupPolicyMoid = $interface.FabricEthNetworkGroupPolicy.ActualInstance.Moid
                $FabricEthNetworkGroupPolicy = Get-IntersightFabricEthNetworkGroupPolicy -Moid $FabricEthNetworkGroupPolicyMoid
                $FabricEthNetworkGroupPolicyName = $FabricEthNetworkGroupPolicy.Name
                $AllowedVlans = $FabricEthNetworkGroupPolicy.VlanSettings.AllowedVlans
                $NativeVlan = $FabricEthNetworkGroupPolicy.VlanSettings.NativeVlan
            }

            if ($interface.IscsiBootPolicy) {
                $IscsiBootPolicyMoid = $interface.IscsiBootPolicy.ActualInstance.Moid
                $IscsiBootPolicy = Get-IntersightVnicIscsiBootPolicy -Moid $IscsiBootPolicyMoid
                $IscsiBootPolicyName = $IscsiBootPolicy.Name
            }

            if ($interface.MacPool) {
                $MacPoolMoid = $interface.MacPool.ActualInstance.Moid
                $MacPool = Get-IntersightMacpoolPool -Moid $MacPoolMoid
                $MacPoolName = $MacPool.Name
            }

            Write-Host " "
            Write-Host " --- VNIC $($VnicEthIfInfo.Name) Info --- "
            Write-Host " "
            Write-Host ($VnicEthIfInfo | Format-List | Out-String).Trim()
            Write-Host " "
            Write-Host "VNIC Allowed VLANs: $($AllowedVlans)"
            Write-Host "VNIC Native  VLAN : $($NativeVlan)"
            Write-Host " "
            Write-Host "QoS Info:"
            Write-Host ($QosInfo | Format-list | Out-String).Trim()
            Write-Host " "
            # Write-Host " --- Cdn Info --- "
            # Write-Host ($Cdn | Format-List | Out-String).Trim()
            # Write-Host " "
            # Write-Host " --- Iscsi Config --- "
            # Write-Host ($IscsiIpV4Config | Format-List | Out-String).Trim()
            Write-Host " "
            Write-Host " --- Placement Info --- "
            Write-Host ($Placement | Format-List | Out-String).Trim()
            Write-Host " "
            # Write-Host " --- Usnic Settings --- "
            # Write-Host ($UsnicSettings | Format-List | Out-String).Trim()
            # Write-Host " "
            # Write-Host " --- VMQ Settings --- "
            # Write-Host ($VmqSettings | Format-List | Out-String).Trim()
            Write-Host " "
            Write-Host "Ethernet Adapter Policy Name          : $($EthAdapterPolicyName)"
            # Write-Host "Ethernet Adapter Policy Moid: $($EthAdapterPolicyMoid)"
            # Write-Host " "
            Write-Host "Ethernet Network Policy Name          : $($EthNetworkPolicyName)"
            # Write-Host "Ethernet Network Policy Moid: $($EthNetworkPolicyMoid)"
            # Write-Host " "
            Write-Host "Ethernet QoS Policy Name              : $($EthQosPolicyName)"
            # Write-Host "Ethernet QoS Policy Moid: $($EthQosPolicyMoid)"
            # Write-Host " "
            Write-Host "Fabric Eth Network Control Policy Name: $($FabricEthNetworkControlPolicyName)"
            # Write-Host "Fabric Eth Network Control Policy Moid: $($FabricEthNetworkControlPolicyMoid)"
            # Write-Host " "
            Write-Host "Fabric Eth Network Group Policy Name  : $($FabricEthNetworkGroupPolicyName)"
            # Write-Host "Fabric Eth Network Group Policy Moid: $($FabricEthNetworkGroupPolicyMoid)"
            # Write-Host " "
            Write-Host "Iscsi Boot Policy Name                : $($IscsiBootPolicyName)"
            # Write-Host "Iscsi Boot Policy Moid: $($IscsiBootPolicyMoid)"
            # Write-Host " "
            Write-Host "MAC Pool Name                         : $($MacPoolName)"
            # Write-Host "MAC Pool Moid: $($MacPoolMoid)"
            Write-Host " "
        }
    } else {
        Write-Host "No LAN Connectivity Policy Associated with profile!"
    }
    Write-Host " "
}

$ApiParams = @{
    BasePath          = "https://intersight.com"
    ApiKeyId          = Get-Content -Path "./apiKey.txt" -Raw
    ApiKeyFilePath    = $pwd.Path + "/SecretKey.txt"
    HttpSigningHeader = @("(request-target)", "Host", "Date", "Digest")
}

Set-IntersightConfiguration @ApiParams
