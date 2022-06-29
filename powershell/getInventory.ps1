<#
    Script to get inventory of all the Servers claimed in Intersight
#>

$ApiParams = @{
    BasePath = "https://intersight.com"
    ApiKeyId = Get-Content -Path ./apiKey.txt -Raw
    ApiKeyFilePath = $pwd.Path + "/SecretKey.txt"
    HttpSigningHeader = @("(request-target)", "Host", "Date", "Digest")
}

Set-IntersightConfiguration @ApiParams

# For individual Server Inventory, uncomment line 15 and comment line 17.
# $moids = Get-IntersightComputePhysicalSummary -Serial xxxxxx | Select-Object Moid

$moids = Get-IntersightComputePhysicalSummary | Select-Object Moid

foreach ($moid in $moids.Moid)
{
    # Get Server Basic Info
    Write-Host "Server Basic Info" -ForegroundColor Red
    Get-IntersightComputePhysicalSummary -Moid $moid | Select-Object Model,Serial,Name,Firmware,AvailableMemory

    # Get CPU Inventory
    Write-Host "Server CPU Info" -ForegroundColor Yellow
    Get-IntersightProcessorUnit -Filter "Ancestors/any(t:t/Moid eq '$moid')" | Select-Object -Expand Results | Select-Object Vendor,Model,Architecture,NumCores,NumCoresEnabled,NumThreads,ProcessorId,SocketDesignation,Speed,Stepping,Presence,OperState,OperReason,Dn

    # Get Memory Inventory
    Write-Host "Server Memory Info" -ForegroundColor Yellow
    Get-IntersightMemoryUnit -Filter "Ancestors/any(t:t/Moid eq '$moid')"  | Select-Object -Expand Results | Select-Object Type,Location,Capacity,Clock,Model,Serial,Vendor,Presence,OperState,Dn

    # Get Storage Controller Inventory
    Write-Host "Server Storage Controller Info" -ForegroundColor Yellow
    Get-IntersightStorageController -Filter "Ancestors/any(t:t/Moid eq '$moid')"  | Select-Object -Expand Results | Select-Object Name,Model,Serial,Vendor,Presence,OperState,PciSlot,Type,ControllerId

    # Get Disks Inventory
    Write-Host "Server Physical Disk Info" -ForegroundColor Yellow
    Get-IntersightStoragePhysicalDisk -Filter "Ancestors/any(t:t/Moid eq '$moid')" | Select-Object -Expand Results | Select-Object DiskId,Name,Model,Pid,Serial,Vendor,Dn,Protocol,BlockSize,Size,Type,DriveFirmware,Presence,DiskState,DriveState,FailurePredicted

    # Get PCI Device Inventory
    Write-Host "Server PCI Device Info" -ForegroundColor Yellow
    Get-IntersightPciDevice -Filter "Ancestors/any(t:t/Moid eq '$moid')" | Select-Object -Expand Results | Select-Object Model,Pid,SlotId
}
