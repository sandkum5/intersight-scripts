<#
    Script to get all the blades in a Chassis in a UCSM Domain
    Input: Chassis_Name
#>

$ApiParams = @{
    BasePath = "https://intersight.com"
    ApiKeyId = Get-Content -Path ./apiKey.txt -Raw
    ApiKeyFilePath = $pwd.Path + "/SecretKey.txt"
    HttpSigningHeader = @("(request-target)", "Host", "Date", "Digest")
}

Set-IntersightConfiguration @ApiParams

$chassisName = Read-Host "Please enter Chassis Name"

$bladeMoids = Get-IntersightEquipmentChassis -Name $chassisName | Select-Object -ExpandProperty Blades | Select-Object -ExpandProperty ActualInstance | Select-Object ActualInstance -ExpandProperty Moid

foreach ($moid in $bladeMoids)
{
    Get-IntersightComputeBlade -Filter "Moid eq '$moid'" | Select-Object -ExpandProperty Results | Select-Object ChassisId,SlotId,Serial
    # ChassisId,SlotId,HardwareUuid,MgmtIpAddress,Name,PlatformType,Model,Serial
}


<#
Sample Run:

> ./get_server_info.ps1                                                           Please enter Chassis Name: imm-fi-loan-1

ChassisId SlotId Serial
--------- ------ ------
1              2 FCH2210782L
1              4 FCH221077UZ
1              3 FCH2210779V
1              1 FCH2210786V

or

> ./get_server_info.ps1
Please enter Chassis Name: imm-fi-loan-1

ChassisId     : 1
SlotId        : 2
HardwareUuid  : 4xxxxxxx-9xxx-4xxx-8xxx-42DAxxxxx1
MgmtIpAddress : 198.xx.xx.xx
Name          : imm-fi-1-2
PlatformType  : IMCBlade
Model         : UCSB-B200-M5
Serial        : FCHxxxxxxx1

ChassisId     : 1
SlotId        : 4
HardwareUuid  : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxx2
MgmtIpAddress : 198.xx.xx.xx
Name          : imm-fi-1-4
PlatformType  : IMCBlade
Model         : UCSB-B200-M5
Serial        : FCHxxxxxxx2

ChassisId     : 1
SlotId        : 3
HardwareUuid  : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxx3
MgmtIpAddress : 198.xx.xx.xx
Name          : imm-fi-1-3
PlatformType  : IMCBlade
Model         : UCSB-B200-M5
Serial        : FCHxxxxxxx3

ChassisId     : 1
SlotId        : 1
HardwareUuid  : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxx4
MgmtIpAddress : 198.xx.xx.xx
Name          : imm-fi-1-1
PlatformType  : IMCBlade
Model         : UCSB-B200-M5
Serial        : FCHxxxxxxx4

#>
