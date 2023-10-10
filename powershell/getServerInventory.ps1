<#
    Script to Get a single Server or first 1000 server Inventory along with Firmware Info from Intersight and write to a inventory.json file
#>
Function Invoke-GetCPUInfo {
    Param (
        $ServerInventory,
        $Data
    )
    # Parse CPU Info
    $CPUInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq "ProcessorUnit"}).AdditionalProperties
    $CPUList = [System.Collections.ArrayList]@()
    foreach ($i in $CPUInfo) {
        $cpu = @{
            "Architecture"      = $i.Architecture
            "Description"       = $i.Description
            "Dn"                = $i.Dn
            "Model"             = $i.Model
            "NumCores"          = $i.NumCores
            "NumCoresEnabled"   = $i.NumCoresEnabled
            "NumThreads"        = $i.NumThreads
            "OperState"         = $i.OperState
            "PartNumber"        = $i.PartNumber
            "Pid"               = $i.Pid
            "Presence"          = $i.Presence
            "ProcessorId"       = $i.ProcessorId
            "SocketDesignation" = $i.SocketDesignation
            "Speed"             = $i.Speed
            "Stepping"          = $i.Stepping
            "Vendor"            = $i.Vendor
        }
        $CPUList.Add($cpu) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add("CPU", $CPUList) | Out-Null
}

Function Invoke-GetDIMMInfo {
    Param (
        $ServerInventory,
        $Data
    )
    # Parse DIMM Info
    $DIMMInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq "MemoryUnit"}).AdditionalProperties
    $DIMMList = [System.Collections.ArrayList]@()
    foreach ($i in $DIMMInfo) {
        $dimm = @{
            "ArrayId"     = $i.ArrayId
            "Bank"        = $i.Bank
            "Capacity"    = $i.Capacity
            "Clock"       = $i.Clock
            "Description" = $i.Description
            "Dn"          = $i.Dn
            "Location"    = $i.Location
            "MemoryId"    = $i.MemoryId
            "Model"       = $i.Model
            "OperState"   = $i.OperState
            "Operability" = $i.Operability
            "PartNumber"  = $i.PartNumber
            "Pid"         = $i.Pid
            "Presence"    = $i.Presence
            "Serial"      = $i.Serial
            "Set"         = $i.Set
            "Type"        = $i.Type
            "Vendor"      = $i.Vendor
            "Visibility"  = $i.Visibility
            "Width"       = $i.Width
        }
        $DIMMList.Add($dimm) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add("DIMM", $DIMMList) | Out-Null
}
Function Invoke-GetAdapterInfo {
    Param (
        $ServerInventory,
        $Data
    )
    # Parse Adapter Info
    $AdapterInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq "AdapterUnit"}).AdditionalProperties
    $AdapterList = [System.Collections.ArrayList]@()
    foreach ($i in $AdapterInfo) {
        $adapter = @{
            "AdapterId" = $i.ArrayId
            "Dn"        = $i.Dn
            "Model"     = $i.Model
            "PciSlot"   = $i.PciSlot
            "Presence"  = $i.Presence
            "Serial"    = $i.Serial
            "Vendor"    = $i.Vendor
        }
        $AdapterList.Add($adapter) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add("Adapter", $AdapterList) | Out-Null
}
Function Invoke-GetAdapterExtEthInterfaceInfo {
    Param (
        $ServerInventory,
        $Data
    )
    # Parse Adapter External Interface Info
    $AdapterExtEthInterfaceInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq "AdapterExtEthInterface"}).AdditionalProperties
    $AdapterExtEthInterfaceList = [System.Collections.ArrayList]@()
    foreach ($i in $AdapterExtEthInterfaceInfo) {
        $adapterextethinterface = @{
            "Dn"                = $i.Dn
            "ExtEthInterfaceId" = $i.ExtEthInterfaceId
            "InterfaceType"     = $i.InterfaceType
            "MacAddress"        = $i.MacAddress
            "PeerAggrPortId"    = $i.PeerAggrPortId
            "PeerPortId"        = $i.PeerPortId
            "PeerSlotId"        = $i.PeerSlotId
        }
        $AdapterExtEthInterfaceList.Add($adapterextethinterface) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add("AdapterExtEthInterface", $AdapterExtEthInterfaceList) | Out-Null
}

Function Invoke-GetAdapterHostEthInterfaceInfo {
    Param (
        $ServerInventory,
        $Data
    )
    # Parse Adapter Ethernet Interface Info
    $AdapterHostEthInterfaceInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq "AdapterHostEthInterface"}).AdditionalProperties
    $AdapterHostEthInterfaceList = [System.Collections.ArrayList]@()
    foreach ($i in $AdapterHostEthInterfaceInfo) {
        $adapterhostethinterface = @{
            "Dn"                 = $i.Dn
            "HostEthInterfaceId" = $i.ExtEthInterfaceId
            "InterfaceType"      = $i.InterfaceType
            "MacAddress"         = $i.MacAddress
            "Name"               = $i.Name
            "StandByVifId"       = $i.StandByVifId
            "VifId"              = $i.VifId
        }
        $AdapterHostEthInterfaceList.Add($adapterhostethinterface) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add("AdapterHostEthInterface", $AdapterHostEthInterfaceList) | Out-Null
}

Function Invoke-GetAdapterHostFcInterfaceInfo {
    Param (
        $ServerInventory,
        $Data
    )
    # Parse Adapter Host FC Interface Info
    $AdapterHostFcInterfaceInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq "AdapterHostFcInterface"}).AdditionalProperties
    $AdapterHostFcInterfaceList = [System.Collections.ArrayList]@()
    foreach ($i in $AdapterHostFcInterfaceInfo) {
        $adapterhostfcinterface = @{
            "Dn"                = $i.Dn
            "HostFcInterfaceId" = $i.HostFcInterfaceId
            "Name"              = $i.Name
            "VifId"             = $i.VifId
            "Wwnn"              = $i.Wwnn
            "Wwpn"              = $i.Wwpn
        }
        $AdapterHostFcInterfaceList.Add($adapterhostfcinterface) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add("AdapterHostFcInterface", $AdapterHostFcInterfaceList) | Out-Null
}
Function Invoke-GetStorageControllerInfo {
    Param (
        $ServerInventory,
        $Data
    )
    # Parse Storage Controller Info
    $StorageControllerInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq "StorageController"}).AdditionalProperties
    $StorageControllerList = [System.Collections.ArrayList]@()
    foreach ($i in $StorageControllerInfo) {
        $controller = @{
            "ConnectedSasExpander"    = $i.ConnectedSasExpander
            "ControllerId"            = $i.ControllerId
            "Dn"                      = $i.Dn
            "EccBucketLeakRate"       = $i.EccBucketLeakRate
            "ForeignConfigPresent"    = $i.ForeignConfigPresent
            "InterfaceType"           = $i.InterfaceType
            "IsUpgraded"              = $i.IsUpgraded
            "MaxVolumesSupported"     = $i.MaxVolumesSupported
            "MemoryCorrectableErrors" = $i.MemoryCorrectableErrors
            "Model"                   = $i.Model
            "PciSlot"                 = $i.PciSlot
            "PersistentCacheSize"     = $i.PersistentCacheSize
            "Presence"                = $i.Presence
            "RaidSupport"             = $i.RaidSupport
            "Serial"                  = $i.Serial
            "TotalCacheSize"          = $i.TotalCacheSize
            "Vendor"                  = $i.Vendor
        }
        $StorageControllerList.Add($controller) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add("StorageController", $StorageControllerList) | Out-Null
}
Function Invoke-GetStoragePhysicalDiskInfo {
    Param (
        $ServerInventory,
        $Data
    )
    # Parse Storage Physical Disk Info
    $StoragePhysicalDiskInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq "StoragePhysicalDisk"}).AdditionalProperties
    $StoragePhysicalDiskList = [System.Collections.ArrayList]@()
    foreach ($i in $StoragePhysicalDiskInfo) {
        $StoragePhysicalDisk = @{
            "ConnectedSasExpander"    = $i.ConnectedSasExpander
            "ControllerId"            = $i.ControllerId
            "Dn"                      = $i.Dn
            "EccBucketLeakRate"       = $i.EccBucketLeakRate
            "ForeignConfigPresent"    = $i.ForeignConfigPresent
            "InterfaceType"           = $i.InterfaceType
            "IsUpgraded"              = $i.IsUpgraded
            "MaxVolumesSupported"     = $i.MaxVolumesSupported
            "MemoryCorrectableErrors" = $i.MemoryCorrectableErrors
            "Model"                   = $i.Model
            "PciSlot"                 = $i.PciSlot
            "PersistentCacheSize"     = $i.PersistentCacheSize
            "Presence"                = $i.Presence
            "RaidSupport"             = $i.RaidSupport
            "Serial"                  = $i.Serial
            "TotalCacheSize"          = $i.TotalCacheSize
            "Vendor"                  = $i.Vendor
        }
        $StoragePhysicalDiskList.Add($StoragePhysicalDisk) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add("StoragePhysicalDisk", $StoragePhysicalDiskList) | Out-Null
}

Function Invoke-GetStorageFlexUtilControllerInfo {
    Param (
        $ServerInventory,
        $Data
    )
    # Parse StorageFlexUtilController Info
    $StorageFlexUtilControllerInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq "StorageFlexUtilController"}).AdditionalProperties
    $StorageFlexUtilControllerList = [System.Collections.ArrayList]@()
    foreach ($i in $StorageFlexUtilControllerInfo) {
        $StorageFlexUtilController = @{
            "ControllerName"   = $i.ControllerName
            "ControllerStatus" = $i.ControllerStatus
            "Dn"               = $i.Dn
            "FfControllerId"   = $i.FfControllerId
            "InternalState"    = $i.InternalState
        }
        $StorageFlexUtilControllerList.Add($StorageFlexUtilController) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add("StorageFlexUtilController", $StorageFlexUtilControllerList) | Out-Null
}

Function Invoke-GetStorageFlexUtilPhysicalDriveInfo {
    Param (
        $ServerInventory,
        $Data
    )
    # Parse StorageFlexUtilPhysicalDrive Info
    $StorageFlexUtilPhysicalDriveInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq "StorageFlexUtilPhysicalDrive"}).AdditionalProperties
    $StorageFlexUtilPhysicalDriveList = [System.Collections.ArrayList]@()
    foreach ($i in $StorageFlexUtilPhysicalDriveInfo) {
        $StorageFlexUtilPhysicalDrive = @{
            "BlockSize"        = $i.BlockSize
            "Capacity"         = $i.Capacity
            "Controller"       = $i.Controller
            "Dn"               = $i.Dn
            "DrivesEnabled"    = $i.DrivesEnabled
            "Health"           = $i.Health
            "ManufacturerDate" = $i.ManufacturerDate
            "ManufacturerId"   = $i.ManufacturerId
            "OemId"            = $i.OemId
            "PartitionCount"   = $i.PartitionCount
            "PdStatus"         = $i.PdStatus
            "PhysicalDrive"    = $i.PhysicalDrive
            "ProductName"      = $i.ProductName
            "ProductRevision"  = $i.ProductRevision
            "Serial"           = $i.Serial
            "WriteEnabled"     = $i.WriteEnabled
        }
        $StorageFlexUtilPhysicalDriveList.Add($StorageFlexUtilPhysicalDrive) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add("StorageFlexUtilPhysicalDrive", $StorageFlexUtilPhysicalDriveList) | Out-Null
}

Function Invoke-GetStorageFlexUtilVirtualDriveInfo {
    Param (
        $ServerInventory,
        $Data
    )
    # Parse StorageFlexUtilVirtualDrive Info
    $StorageFlexUtilVirtualDriveInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq "StorageFlexUtilVirtualDrive"}).AdditionalProperties
    $StorageFlexUtilVirtualDriveList = [System.Collections.ArrayList]@()
    foreach ($i in $StorageFlexUtilVirtualDriveInfo) {
        $StorageFlexUtilVirtualDrive = @{
            "Dn"            = $i.Dn
            "DriveStatus"   = $i.DriveStatus
            "DriveType"     = $i.DriveType
            "PartitionId"   = $i.PartitionId
            "PartitionName" = $i.PartitionName
            "ResidentImage" = $i.ResidentImage
            "Size"          = $i.Size
            "VirtualDrive"  = $i.VirtualDrive
        }
        $StorageFlexUtilVirtualDriveList.Add($StorageFlexUtilVirtualDrive) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add("StorageFlexUtilVirtualDrive", $StorageFlexUtilVirtualDriveList) | Out-Null
}

Function Invoke-GetBootHddDeviceInfo {
    Param (
        $ServerInventory,
        $Data
    )
    # Parse BootHddDevice Info
    $BootHddDeviceInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq "BootHddDevice"}).AdditionalProperties
    $BootHddDeviceList = [System.Collections.ArrayList]@()
    foreach ($i in $BootHddDeviceInfo) {
        $BootHddDevice = @{
            "Dn"    = $i.Dn
            "Name"  = $i.Name
            "Order" = $i.Order
            "State" = $i.State
            "Type"  = $i.Type
        }
        $BootHddDeviceList.Add($BootHddDevice) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add("BootHddDevice", $BootHddDeviceList) | Out-Null
}

Function Invoke-GetBootPchStorageDeviceInfo {
    Param (
        $ServerInventory,
        $Data
    )
    # Parse BootPchStorageDevice Info
    $BootPchStorageDeviceInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq "BootPchStorageDevice"}).AdditionalProperties
    $BootPchStorageDeviceList = [System.Collections.ArrayList]@()
    foreach ($i in $BootPchStorageDeviceInfo) {
        $BootPchStorageDevice = @{
            "Dn"    = $i.Dn
            "Name"  = $i.Name
            "Order" = $i.Order
            "State" = $i.State
            "Type"  = $i.Type
        }
        $BootPchStorageDeviceList.Add($BootPchStorageDevice) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add("BootPchStorageDevice", $BootPchStorageDeviceList) | Out-Null
}
Function Invoke-GetBootVmediaDeviceInfo {
    Param (
        $ServerInventory,
        $Data
    )
    # Parse BootVmediaDevice Info
    $BootVmediaDeviceInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq "BootVmediaDevice"}).AdditionalProperties
    $BootVmediaDeviceList = [System.Collections.ArrayList]@()
    foreach ($i in $BootVmediaDeviceInfo) {
        $BootVmediaDevice = @{
            "Dn"    = $i.Dn
            "Name"  = $i.Name
            "Order" = $i.Order
            "State" = $i.State
            "Type"  = $i.Type
        }
        $BootVmediaDeviceList.Add($BootVmediaDevice) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add("BootVmediaDevice", $BootVmediaDeviceList) | Out-Null
}

Function Invoke-GetFANInfo {
    Param (
        $ServerInventory,
        $Data
    )
    # Parse FAN Info
    $FANInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq "EquipmentFan"}).AdditionalProperties
    $FANList = [System.Collections.ArrayList]@()
    foreach ($i in $FANInfo) {
        $fan = @{
            "Dn"        = $i.Dn
            "FanId" = $i.ArrayId
            "FanModuleId" = $i.Model
            "ModuleId"    = $i.ModuleId
            "OperState"   = $i.OperState
            "Presence"    = $i.Presence
            "TrayId"      = $i.TrayId
        }
        $FANList.Add($fan) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add("Fan", $FANList) | Out-Null
}

Function Invoke-GetPSUInfo {
    Param (
        $ServerInventory,
        $Data
    )
    # Parse PSU Info
    $PSUInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq "EquipmentPsu"}).AdditionalProperties
    $PSUList = [System.Collections.ArrayList]@()
    foreach ($i in $PSUInfo) {
        $psu = @{
            "Dn"       = $i.Dn
            "Model"    = $i.Model
            "Presence" = $i.Presence
            "PsuId"    = $i.PsuId
            "Serial"   = $i.Serial
            "Vendor"   = $i.Vendor
            "Voltage"  = $i.Voltage
        }
        $PSUList.Add($psu) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add("PSU", $PSUList) | Out-Null
}

Function Invoke-GetEquipmentTpmInfo {
    Param (
        $ServerInventory,
        $Data
    )
    # Parse EquipmentTpm Info
    $EquipmentTpmInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq "EquipmentTpm"}).AdditionalProperties
    $EquipmentTpmList = [System.Collections.ArrayList]@()
    foreach ($i in $EquipmentTpmInfo) {
        $EquipmentTpm = @{
            "ActivationStatus"    = $i.ActivationStatus
            "AdminState"          = $i.AdminState
            "Dn"                  = $i.Dn
            "FirmwareVersion"     = $i.FirmwareVersion
            "InventoryDeviceInfo" = $i.InventoryDeviceInfo
            "Model"               = $i.Model
            "Ownership"           = $i.Ownership
            "Presence"            = $i.Presence
            "Revision"            = $i.Revision
            "Serial"              = $i.Serial
            "TpmId"               = $i.TpmId
            "Vendor"              = $i.Vendor
            "Version"             = $i.Version
        }
        $EquipmentTpmList.Add($EquipmentTpm) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add("EquipmentTpm", $EquipmentTpmList) | Out-Null
}

Function Invoke-GetManagementInterfaceInfo {
    Param (
        $ServerInventory,
        $Data
    )
    # Parse PSU Info
    $ManagementInterfaceInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq "ManagementInterface"}).AdditionalProperties
    $ManagementInterfaceList = [System.Collections.ArrayList]@()
    foreach ($i in $ManagementInterfaceInfo) {
        $ManagementInterface = @{
            "Dn"          = $i.Dn
            "Gateway"     = $i.Gateway
            "HostName"    = $i.HostName
            "IpAddress"   = $i.IpAddress
            "Ipv4Address" = $i.Ipv4Address
            "Ipv4Gateway" = $i.Ipv4Gateway
            "Ipv4Mask"    = $i.Ipv4Mask
            "Ipv6Address" = $i.Ipv6Address
            "Ipv6Gateway" = $i.Ipv6Gateway
            "Ipv6Prefix"  = $i.Ipv6Prefix
            "MacAddress"  = $i.MacAddress
            "Mask"        = $i.Mask
            "VlanId"      = $i.VlanId
        }
        $ManagementInterfaceList.Add($ManagementInterface) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add("ManagementInterface", $ManagementInterfaceList) | Out-Null
}

Function Invoke-GetLocatorLedInfo {
    Param (
        $ServerInventory,
        $Data
    )
    # Parse LocatorLed Info
    $LocatorLedInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq "EquipmentLocatorLed"}).AdditionalProperties
    $LocatorLedList = [System.Collections.ArrayList]@()
    foreach ($i in $LocatorLedInfo) {
        $locatorled = @{
            "Color"     = $i.Color
            "Dn"        = $i.Dn
            "OperState" = $i.OperState
        }
        $LocatorLedList.Add($locatorled) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add("LocatorLed", $LocatorLedList) | Out-Null
}

Function Invoke-GetPciInfo {
    param (
        $ServerInventory,
        $Data
    )

    # Parse PCI Info
    $PciInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq "PciDevice"}).AdditionalProperties
    $PciList = [System.Collections.ArrayList]@()
    foreach ($i in $PciInfo) {
        $pci = @{
            "Dn"              = $i.Dn
            "FirmwareVersion" = $i.FirmwareVersion
            "Model"           = $i.Model
            "Pid"             = $i.Pid
            "SlotId"          = $i.SlotId
            "Vendor"          = $i.Vendor
        }
        $PciList.Add($pci) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add("PciDevice", $PciList) | Out-Null
}

Function Invoke-GetFirmwareInfo {
    param (
        $ServerInventory,
        $Data
    )

    # Parse Firmware Info
    $FirmwareInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq "FirmwareRunningFirmware"}).AdditionalProperties
    $FirmwareList = [System.Collections.ArrayList]@()
    foreach ($i in $FirmwareInfo) {
        $firmware = @{
            "Component" = $i.Component
            "Type"      = $i.Type
            "Version"   = $i.Version
            "Dn"        = $i.Dn
        }
        $FirmwareList.Add($firmware) | Out-Null
    }
    ($Data.($Server.Serial)).Add("ComponentFirmware", $FirmwareList) | Out-Null
}

Function Invoke-GetServerInfo {
    param (
        $Server,
        $Data
    )
    # Parse Server Info
    $ServerInfo = @{
        "Name"                = $Server.Name
        "Model"               = $Server.Model
        "PlatformType"        = $Server.PlatformType
        "Uuid"                = $Server.Uuid
        "Vendor"              = $Server.Vendor
        "Dn"                  = $Server.Dn
        "Firmware"            = $Server.Firmware
        "Ipv4Address"         = $Server.Ipv4Address
        "MgmtIpAddress"       = $Server.MgmtIpAddress
        "ManagementMode"      = $Server.ManagementMode
        "AvailableMemory"     = $Server.AvailableMemory
        "TotalMemory"         = $Server.TotalMemory
        "MemorySpeed"         = $Server.MemorySpeed
        "NumAdaptors"         = $Server.NumAdaptors
        "NumCpuCores"         = $Server.NumCpuCores
        "NumCpuCoresEnabled"  = $Server.NumCpuCoresEnabled
        "NumCpus"             = $Server.NumCpus
        "NumEthHostInterfaces"= $Server.NumEthHostInterfaces
        "NumFcHostInterfaces" = $Server.NumFcHostInterfaces
        "NumThreads"          = $Server.NumThreads
        "OperPowerState"      = $Server.OperPowerState
        "TunneledKvm"         = $Server.TunneledKvm
        "FaultSummary"        = $Server.FaultSummary
        "AssetTag"            = $Server.AssetTag
        "UserLabel"           = $Server.UserLabel
        "ServerId"            = $Server.ServerId
        "SlotId"              = $Server.SlotId
        "ServiceProfile"      = $Server.ServiceProfile
    }
    ($Data.($Server.Serial)).Add("Info", $ServerInfo) | Out-Null
}

Function Invoke-GetServerInventory {
    Param (
        $Server
    )
    Write-Host "Parsing Data for Server: $($Server.Name)"
    # Create Hashtable with Server Serial as Key
    $Data.Add($Server.Serial, @{}) | Out-Null

    # Create Specs Key under Server
    ($Data.($Server.Serial)).Add("Specs", @{}) | Out-Null

    # Get Server Inventory
    $Moid = $Server.Moid
    $ServerInventory = (Get-IntersightSearchSearchItem -Top 1000 -Filter "Ancestors/any(t:t/Moid eq '$Moid')").Results

    # Parse Firmware Info
    Invoke-GetFirmwareInfo -Data $Data -ServerInventory $ServerInventory

    # Parse CPU Info
    Invoke-GetCPUInfo -Data $Data -ServerInventory $ServerInventory

    # Parse DIMM Info
    Invoke-GetDIMMInfo -Data $Data -ServerInventory $ServerInventory

    # Parse Adapter Info
    Invoke-GetAdapterInfo -Data $Data -ServerInventory $ServerInventory

    # Parse Adapter External Interface Info
    Invoke-GetAdapterExtEthInterfaceInfo -Data $Data -ServerInventory $ServerInventory

    # Parse Adapter Host Ethernet Interface Info
    Invoke-GetAdapterHostEthInterfaceInfo -Data $Data -ServerInventory $ServerInventory

    # Parse Adapter Host FC Interface Info
    Invoke-GetAdapterHostFcInterfaceInfo -Data $Data -ServerInventory $ServerInventory

    # Parse Storage Controller Info
    Invoke-GetStorageControllerInfo -Data $Data -ServerInventory $ServerInventory

    # Parse Storage Physical Disk Info
    Invoke-GetStoragePhysicalDiskInfo -Data $Data -ServerInventory $ServerInventory

    # Parse StorageFlexUtilController Info
    Invoke-GetStorageFlexUtilControllerInfo -Data $Data -ServerInventory $ServerInventory

    # Parse StorageFlexUtilPhysicalDrive Info
    Invoke-GetStorageFlexUtilPhysicalDriveInfo -Data $Data -ServerInventory $ServerInventory

    # Parse StorageFlexUtilVirtualDrive Info
    Invoke-GetStorageFlexUtilVirtualDriveInfo -Data $Data -ServerInventory $ServerInventory

    # Parse BootHddDevice Info
    Invoke-GetBootHddDeviceInfo -Data $Data -ServerInventory $ServerInventory

    # Parse BootPchStorageDevice Info
    Invoke-GetBootPchStorageDeviceInfo -Data $Data -ServerInventory $ServerInventory

    # Parse BootVmediaDevice Info
    Invoke-GetBootVmediaDeviceInfo -Data $Data -ServerInventory $ServerInventory

    # Parse FAN Info
    Invoke-GetFANInfo -Data $Data -ServerInventory $ServerInventory

    # Parse PSU Info
    Invoke-GetPSUInfo -Data $Data -ServerInventory $ServerInventory

    # Parse TPM Info
    Invoke-GetEquipmentTpmInfo -Data $Data -ServerInventory $ServerInventory

    # Parse Management Interface Info
    Invoke-GetManagementInterfaceInfo -Data $Data -ServerInventory $ServerInventory

    # Parse Locator LED Info
    Invoke-GetLocatorLedInfo -Data $Data -ServerInventory $ServerInventory

    # Parse PCI Info
    Invoke-GetPciInfo -Data $Data -ServerInventory $ServerInventory

    # Parse Server Info
    Invoke-GetServerInfo -Data $Data -Server $Server
}

# Intersight API Configuration
$ApiParams = @{
    BasePath = "https://intersight.com"
    ApiKeyId = Get-Content -Path ./apiKey.txt -Raw
    ApiKeyFilePath = $pwd.Path + "/SecretKey.txt"
    HttpSigningHeader = @("(request-target)", "Host", "Date", "Digest")
}

Set-IntersightConfiguration @ApiParams

$value = Read-Host "Enter a value(Options: single or all): " # Prompt the user for input

switch ($value) {
    "single" {
        $ServerSerial = Read-Host "Enter Server Serial: "
        $Server = (Get-IntersightComputePhysicalSummary -Filter "Serial eq '$ServerSerial'").Results
        $Data = @{}
        Invoke-GetServerInventory -Server $Server
    }
    "all" {
        $Servers = (Get-IntersightComputePhysicalSummary -Top 1000).Results
        $Data = @{}
        foreach ($Server in $Servers) {
            Invoke-GetServerInventory -Server $Server
        }
    }
}

# Write to JSON file
$Data | ConvertTo-Json -Depth 8 | Out-File "./inventory.json" -Append
