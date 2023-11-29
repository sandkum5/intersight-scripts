<#
    Script to Get a single Server or first 1000 server Inventory along with Firmware Info from Intersight and write to an inventory.json file
#>

# Functions
Function Invoke-GetCPUInfo {
    Param (
        $ServerInventory,
        $Data,
        $Server
    )
    # Parse CPU Info
    $ComponentName = "ProcessorUnit"
    $ComponentInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq $ComponentName}).AdditionalProperties
    $ComponentList = [System.Collections.ArrayList]@()
    foreach ($i in $ComponentInfo) {
        $properties = @{
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
        $ComponentList.Add($properties) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add($ComponentName, $ComponentList) | Out-Null
}

Function Invoke-GetDIMMInfo {
    Param (
        $ServerInventory,
        $Data,
        $Server
    )
    # Parse DIMM Info
    $ComponentName = "MemoryUnit"
    $ComponentInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq $ComponentName}).AdditionalProperties
    $ComponentList = [System.Collections.ArrayList]@()
    foreach ($i in $ComponentInfo) {
        $properties = @{
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
        $ComponentList.Add($properties) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add($ComponentName, $ComponentList) | Out-Null
}
Function Invoke-GetAdapterInfo {
    Param (
        $ServerInventory,
        $Data,
        $Server
    )
    # Parse Adapter Info
    $ComponentName = "AdapterUnit"
    $ComponentInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq $ComponentName}).AdditionalProperties
    $ComponentList = [System.Collections.ArrayList]@()
    foreach ($i in $ComponentInfo) {
        $properties = @{
            "AdapterId" = $i.ArrayId
            "Dn"        = $i.Dn
            "Model"     = $i.Model
            "PciSlot"   = $i.PciSlot
            "Presence"  = $i.Presence
            "Serial"    = $i.Serial
            "Vendor"    = $i.Vendor
        }
        $ComponentList.Add($properties) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add($ComponentName, $ComponentList) | Out-Null
}
Function Invoke-GetAdapterExtEthInterfaceInfo {
    Param (
        $ServerInventory,
        $Data,
        $Server
    )
    # Parse Adapter External Interface Info
    $ComponentName = "AdapterExtEthInterface"
    $ComponentInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq $ComponentName}).AdditionalProperties
    $ComponentList = [System.Collections.ArrayList]@()
    foreach ($i in $ComponentInfo) {
        $properties = @{
            "Dn"                = $i.Dn
            "ExtEthInterfaceId" = $i.ExtEthInterfaceId
            "InterfaceType"     = $i.InterfaceType
            "MacAddress"        = $i.MacAddress
            "PeerAggrPortId"    = $i.PeerAggrPortId
            "PeerPortId"        = $i.PeerPortId
            "PeerSlotId"        = $i.PeerSlotId
        }
        $ComponentList.Add($properties) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add($ComponentName, $ComponentList) | Out-Null
}

Function Invoke-GetAdapterHostEthInterfaceInfo {
    Param (
        $ServerInventory,
        $Data,
        $Server
    )
    # Parse Adapter Ethernet Interface Info
    $ComponentName = "AdapterHostEthInterface"
    $ComponentInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq $ComponentName}).AdditionalProperties
    $ComponentList = [System.Collections.ArrayList]@()
    foreach ($i in $ComponentInfo) {
        $properties = @{
            "Dn"                 = $i.Dn
            "HostEthInterfaceId" = $i.ExtEthInterfaceId
            "InterfaceType"      = $i.InterfaceType
            "MacAddress"         = $i.MacAddress
            "Name"               = $i.Name
            "StandByVifId"       = $i.StandByVifId
            "VifId"              = $i.VifId
        }
        $ComponentList.Add($properties) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add($ComponentName, $ComponentList) | Out-Null
}

Function Invoke-GetAdapterHostFcInterfaceInfo {
    Param (
        $ServerInventory,
        $Data,
        $Server
    )
    # Parse Adapter Host FC Interface Info
    $ComponentName = "AdapterHostFcInterface"
    $ComponentInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq $ComponentName}).AdditionalProperties
    $ComponentList = [System.Collections.ArrayList]@()
    foreach ($i in $ComponentInfo) {
        $properties = @{
            "Dn"                = $i.Dn
            "HostFcInterfaceId" = $i.HostFcInterfaceId
            "Name"              = $i.Name
            "VifId"             = $i.VifId
            "Wwnn"              = $i.Wwnn
            "Wwpn"              = $i.Wwpn
        }
        $ComponentList.Add($properties) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add($ComponentName, $ComponentList) | Out-Null
}
Function Invoke-GetStorageControllerInfo {
    Param (
        $ServerInventory,
        $Data,
        $Server
    )
    # Parse Storage Controller Info
    $ComponentName = "StorageController"
    $ComponentInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq $ComponentName}).AdditionalProperties
    $ComponentList = [System.Collections.ArrayList]@()
    foreach ($i in $ComponentInfo) {
        $properties = @{
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
        $ComponentList.Add($properties) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add($ComponentName, $ComponentList) | Out-Null
}
Function Invoke-GetStoragePhysicalDiskInfo {
    Param (
        $ServerInventory,
        $Data,
        $Server
    )
    # Parse Storage Physical Disk Info
    $ComponentName = "StoragePhysicalDisk"
    $ComponentInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq $ComponentName}).AdditionalProperties
    $ComponentList = [System.Collections.ArrayList]@()
    foreach ($i in $ComponentInfo) {
        $properties = @{
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
        $ComponentList.Add($properties) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add($ComponentName, $ComponentList) | Out-Null
}

Function Invoke-GetStorageFlexUtilControllerInfo {
    Param (
        $ServerInventory,
        $Data,
        $Server
    )
    # Parse StorageFlexUtilController Info
    $ComponentName = "StorageFlexUtilController"
    $ComponentInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq $ComponentName}).AdditionalProperties
    $ComponentList = [System.Collections.ArrayList]@()
    foreach ($i in $ComponentInfo) {
        $properties = @{
            "ControllerName"   = $i.ControllerName
            "ControllerStatus" = $i.ControllerStatus
            "Dn"               = $i.Dn
            "FfControllerId"   = $i.FfControllerId
            "InternalState"    = $i.InternalState
        }
        $ComponentList.Add($properties) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add($ComponentName, $ComponentList) | Out-Null
}

Function Invoke-GetStorageFlexUtilPhysicalDriveInfo {
    Param (
        $ServerInventory,
        $Data,
        $Server
    )
    # Parse StorageFlexUtilPhysicalDrive Info
    $ComponentName = "StorageFlexUtilPhysicalDrive"
    $ComponentInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq $ComponentName}).AdditionalProperties
    $ComponentList = [System.Collections.ArrayList]@()
    foreach ($i in $ComponentInfo) {
        $properties = @{
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
        $ComponentList.Add($properties) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add($ComponentName, $ComponentList) | Out-Null
}

Function Invoke-GetStorageFlexUtilVirtualDriveInfo {
    Param (
        $ServerInventory,
        $Data,
        $Server
    )
    # Parse StorageFlexUtilVirtualDrive Info
    $ComponentName = "StorageFlexUtilVirtualDrive"
    $ComponentInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq $ComponentName}).AdditionalProperties
    $ComponentList = [System.Collections.ArrayList]@()
    foreach ($i in $ComponentInfo) {
        $properties = @{
            "Dn"            = $i.Dn
            "DriveStatus"   = $i.DriveStatus
            "DriveType"     = $i.DriveType
            "PartitionId"   = $i.PartitionId
            "PartitionName" = $i.PartitionName
            "ResidentImage" = $i.ResidentImage
            "Size"          = $i.Size
            "VirtualDrive"  = $i.VirtualDrive
        }
        $ComponentList.Add($properties) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add($ComponentName, $ComponentList) | Out-Null
}

Function Invoke-GetBootHddDeviceInfo {
    Param (
        $ServerInventory,
        $Data,
        $Server
    )
    # Parse BootHddDevice Info
    $ComponentName = "BootHddDevice"
    $ComponentInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq $ComponentName}).AdditionalProperties
    $ComponentList = [System.Collections.ArrayList]@()
    foreach ($i in $ComponentInfo) {
        $properties = @{
            "Dn"    = $i.Dn
            "Name"  = $i.Name
            "Order" = $i.Order
            "State" = $i.State
            "Type"  = $i.Type
        }
        $ComponentList.Add($properties) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add($ComponentName, $BootHddDeviceList) | Out-Null
}

Function Invoke-GetBootPchStorageDeviceInfo {
    Param (
        $ServerInventory,
        $Data,
        $Server
    )
    # Parse BootPchStorageDevice Info
    $ComponentName = "BootPchStorageDevice"
    $ComponentInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq $ComponentName}).AdditionalProperties
    $ComponentList = [System.Collections.ArrayList]@()
    foreach ($i in $ComponentInfo) {
        $properties = @{
            "Dn"    = $i.Dn
            "Name"  = $i.Name
            "Order" = $i.Order
            "State" = $i.State
            "Type"  = $i.Type
        }
        $ComponentList.Add($properties) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add($ComponentName, $ComponentList) | Out-Null
}
Function Invoke-GetBootVmediaDeviceInfo {
    Param (
        $ServerInventory,
        $Data,
        $Server
    )
    # Parse BootVmediaDevice Info
    $ComponentName = "BootVmediaDevice"
    $ComponentInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq $ComponentName}).AdditionalProperties
    $ComponentList = [System.Collections.ArrayList]@()
    foreach ($i in $ComponentInfo) {
        $properties = @{
            "Dn"    = $i.Dn
            "Name"  = $i.Name
            "Order" = $i.Order
            "State" = $i.State
            "Type"  = $i.Type
        }
        $ComponentList.Add($properties) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add($ComponentName, $ComponentList) | Out-Null
}

Function Invoke-GetFANInfo {
    Param (
        $ServerInventory,
        $Data,
        $Server
    )
    # Parse FAN Info
    $ComponentName = "EquipmentFan"
    $ComponentInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq $ComponentName}).AdditionalProperties
    $ComponentList = [System.Collections.ArrayList]@()
    foreach ($i in $ComponentInfo) {
        $properties = @{
            "Dn"        = $i.Dn
            "FanId" = $i.ArrayId
            "FanModuleId" = $i.Model
            "ModuleId"    = $i.ModuleId
            "OperState"   = $i.OperState
            "Presence"    = $i.Presence
            "TrayId"      = $i.TrayId
        }
        $ComponentList.Add($properties) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add($ComponentName, $ComponentList) | Out-Null
}

Function Invoke-GetPSUInfo {
    Param (
        $ServerInventory,
        $Data,
        $Server
    )
    # Parse PSU Info
    $ComponentName = "EquipmentPsu"
    $ComponentInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq $ComponentName}).AdditionalProperties
    $ComponentList = [System.Collections.ArrayList]@()
    foreach ($i in $ComponentInfo) {
        $properties = @{
            "Dn"       = $i.Dn
            "Model"    = $i.Model
            "Presence" = $i.Presence
            "PsuId"    = $i.PsuId
            "Serial"   = $i.Serial
            "Vendor"   = $i.Vendor
            "Voltage"  = $i.Voltage
        }
        $ComponentList.Add($properties) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add($ComponentName, $ComponentList) | Out-Null
}

Function Invoke-GetEquipmentTpmInfo {
    Param (
        $ServerInventory,
        $Data,
        $Server
    )
    # Parse EquipmentTpm Info
    $ComponentName = "EquipmentTpm"
    $ComponentInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq $ComponentName}).AdditionalProperties
    $ComponentList = [System.Collections.ArrayList]@()
    foreach ($i in $ComponentInfo) {
        $properties = @{
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
        $ComponentList.Add($properties) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add($ComponentName, $ComponentList) | Out-Null
}

Function Invoke-GetManagementInterfaceInfo {
    Param (
        $ServerInventory,
        $Data,
        $Server
    )
    # Parse PSU Info
    $ComponentName = "ManagementInterface"
    $ComponentInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq $ComponentName}).AdditionalProperties
    $ComponentList = [System.Collections.ArrayList]@()
    foreach ($i in $ComponentInfo) {
        $properties = @{
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
        $ComponentList.Add($properties) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add($ComponentName, $ComponentList) | Out-Null
}

Function Invoke-GetLocatorLedInfo {
    Param (
        $ServerInventory,
        $Data,
        $Server
    )
    # Parse LocatorLed Info
    $ComponentName = "EquipmentLocatorLed"
    $ComponentInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq $ComponentName}).AdditionalProperties
    $ComponentList = [System.Collections.ArrayList]@()
    foreach ($i in $ComponentInfo) {
        $properties = @{
            "Color"     = $i.Color
            "Dn"        = $i.Dn
            "OperState" = $i.OperState
        }
        $ComponentList.Add($properties) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add($ComponentName, $ComponentList) | Out-Null
}

Function Invoke-GetPciInfo {
    param (
        $ServerInventory,
        $Data,
        $Server
    )

    # Parse PCI Info
    $ComponentName = "PciDevice"
    $ComponentInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq $ComponentName}).AdditionalProperties
    $ComponentList = [System.Collections.ArrayList]@()
    foreach ($i in $ComponentInfo) {
        $properties = @{
            "Dn"              = $i.Dn
            "FirmwareVersion" = $i.FirmwareVersion
            "Model"           = $i.Model
            "Pid"             = $i.Pid
            "SlotId"          = $i.SlotId
            "Vendor"          = $i.Vendor
        }
        $ComponentList.Add($properties) | Out-Null
    }
    ($Data.($Server.Serial).Specs).Add($ComponentName, $ComponentList) | Out-Null
}

Function Invoke-GetFirmwareInfo {
    param (
        $ServerInventory,
        $Data,
        $Server
    )

    # Parse Firmware Info
    $ComponentName = "FirmwareRunningFirmware"
    $ComponentInfo = ($ServerInventory | Where-Object {$_.ObjectType -eq $ComponentName}).AdditionalProperties
    $ComponentList = [System.Collections.ArrayList]@()
    foreach ($i in $ComponentInfo) {
        $properties = @{
            "Component" = $i.Component
            "Type"      = $i.Type
            "Version"   = $i.Version
            "Dn"        = $i.Dn
        }
        $ComponentList.Add($properties) | Out-Null
    }
    ($Data.($Server.Serial)).Add($ComponentName, $ComponentList) | Out-Null
}

Function Invoke-GetServerInfo {
    param (
        $Server,
        $Data
    )
    # Parse Server Info
    $properties = @{
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
    ($Data.($Server.Serial)).Add("Info", $properties) | Out-Null
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
    Invoke-GetFirmwareInfo -Data $Data -ServerInventory $ServerInventory -Server $Server

    # Parse CPU Info
    Invoke-GetCPUInfo -Data $Data -ServerInventory $ServerInventory -Server $Server

    # Parse DIMM Info
    Invoke-GetDIMMInfo -Data $Data -ServerInventory $ServerInventory -Server $Server

    # Parse Adapter Info
    Invoke-GetAdapterInfo -Data $Data -ServerInventory $ServerInventory -Server $Server

    # Parse Adapter External Interface Info
    Invoke-GetAdapterExtEthInterfaceInfo -Data $Data -ServerInventory $ServerInventory -Server $Server

    # Parse Adapter Host Ethernet Interface Info
    Invoke-GetAdapterHostEthInterfaceInfo -Data $Data -ServerInventory $ServerInventory -Server $Server

    # Parse Adapter Host FC Interface Info
    Invoke-GetAdapterHostFcInterfaceInfo -Data $Data -ServerInventory $ServerInventory -Server $Server

    # Parse Storage Controller Info
    Invoke-GetStorageControllerInfo -Data $Data -ServerInventory $ServerInventory -Server $Server

    # Parse Storage Physical Disk Info
    Invoke-GetStoragePhysicalDiskInfo -Data $Data -ServerInventory $ServerInventory -Server $Server

    # Parse StorageFlexUtilController Info
    Invoke-GetStorageFlexUtilControllerInfo -Data $Data -ServerInventory $ServerInventory -Server $Server

    # Parse StorageFlexUtilPhysicalDrive Info
    Invoke-GetStorageFlexUtilPhysicalDriveInfo -Data $Data -ServerInventory $ServerInventory -Server $Server

    # Parse StorageFlexUtilVirtualDrive Info
    Invoke-GetStorageFlexUtilVirtualDriveInfo -Data $Data -ServerInventory $ServerInventory -Server $Server

    # Parse BootHddDevice Info
    Invoke-GetBootHddDeviceInfo -Data $Data -ServerInventory $ServerInventory -Server $Server

    # Parse BootPchStorageDevice Info
    Invoke-GetBootPchStorageDeviceInfo -Data $Data -ServerInventory $ServerInventory -Server $Server

    # Parse BootVmediaDevice Info
    Invoke-GetBootVmediaDeviceInfo -Data $Data -ServerInventory $ServerInventory -Server $Server

    # Parse FAN Info
    Invoke-GetFANInfo -Data $Data -ServerInventory $ServerInventory -Server $Server

    # Parse PSU Info
    Invoke-GetPSUInfo -Data $Data -ServerInventory $ServerInventory -Server $Server

    # Parse TPM Info
    Invoke-GetEquipmentTpmInfo -Data $Data -ServerInventory $ServerInventory -Server $Server

    # Parse Management Interface Info
    Invoke-GetManagementInterfaceInfo -Data $Data -ServerInventory $ServerInventory -Server $Server

    # Parse Locator LED Info
    Invoke-GetLocatorLedInfo -Data $Data -ServerInventory $ServerInventory -Server $Server

    # Parse PCI Info
    Invoke-GetPciInfo -Data $Data -ServerInventory $ServerInventory -Server $Server

    # Parse Server Info
    Invoke-GetServerInfo -Data $Data -Server $Server
}


# Script Execution
# Intersight Configuration
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
        $Servers = [System.Collections.ArrayList]@()
        $skip = 0
        $count = 0
        $totalCount = (Get-IntersightComputePhysicalSummary -Count $true).Count
        
        Write-Host 'API call to Intersight In-progress, 1 API call/1000 objects'
        while ($count -le $totalCount){
            $loop = ($count / 1000) + 1
            Write-Host "$($loop) API Call!"
            $Servers += (Get-IntersightComputePhysicalSummary -Top 1000 -Skip $skip).Results
            $skip += 1000
            $count += 1000
        }

        # $Servers = (Get-IntersightComputePhysicalSummary -Top 1000).Results
        $Data = @{}
        foreach ($Server in $Servers) {
            Invoke-GetServerInventory -Server $Server
        }
    }
}

# Write to JSON file
$InventoryFile = "./inventory.json"
$Data | ConvertTo-Json -Depth 8 | Out-File $InventoryFile -Append
