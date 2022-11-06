<#
    Script to clone Port Policy in Intersight

    Pending Items:
        - FCoE Uplink Port-Channel
        - Appliance Port-Channel
#>

# Add Functions
. ./cloneRoleUplinkEth.ps1
. ./cloneRoleUplinkFc.ps1
. ./cloneRoleAppliance.ps1
. ./cloneRoleUplinkFcoe.ps1
. ./cloneRolePCUplinkEth.ps1
. ./cloneRolePCUplinkFc.ps1

$ApiParams = @{
    BasePath          = "https://intersight.com"
    ApiKeyId          = Get-Content -Path "./apiKey.txt" -Raw
    ApiKeyFilePath    = $pwd.Path + "/SecretKey.txt"
    HttpSigningHeader = @("(request-target)", "Host", "Date", "Digest")
}

Set-IntersightConfiguration @ApiParams
# Get Org Info
$orgName = "default"
$newOrgName = "prod"
$portPolicyName = "oldport"

# $orgMoid = (Get-IntersightOrganizationOrganization -Name $orgName).Moid
$org = Get-IntersightOrganizationOrganization -Name $orgName
$orgObj = $org | Get-IntersightMoMoRef

# $newOrgMoid = (Get-IntersightOrganizationOrganization -Name $newOrgName).Moid
$newOrg = Get-IntersightOrganizationOrganization -Name $newOrgName
$newOrgObj = $newOrg | Get-IntersightMoMoRef

###################### Port Policy ###################
# Get existing Port Policy
$portPolicy = Get-IntersightFabricPortPolicy -Name $portPolicyName -Organization $orgObj

# Initialize Port Policy Source
$portPolicySrc = Initialize-IntersightMoBaseMo -ClassId "FabricPortPolicy" -ObjectType "FabricPortPolicy" -Moid $portPolicy.Moid

# Initialize Port Policy Target
$portPolicyTarget = Initialize-IntersightFabricPortPolicy -Name $portPolicyName -Organization $newOrgObj

# Create Port Policy Clone
New-IntersightBulkMoCloner -Sources $portPolicySrc -Targets $portPolicyTarget -Organization $newOrgObj

$newPortPolicy = Get-IntersightFabricPortPolicy -Name $portPolicyName -Organization $newOrgObj
$newPortPolicyObj = $newPortPolicy | Get-IntersightMoMoRef
Write-Host "Created Port Policy: $($newPortPolicy.Name) under Org: $($newOrg.Name)" -ForegroundColor Yellow

###################### Port Mode #####################
# Get Port Mode Policy
$portMode = Get-IntersightFabricPortMode -Parent ($portPolicy | Get-IntersightMoMoRef)

# Create new Port Modes and link to new Port Policy
if ($portMode) {
    Write-Debug "Update Port Mode"
    foreach ($port in $portMode) {
        $custommode = $port.CustomMode
        $slotid = $port.SlotId
        $portidstart = $port.PortIdStart
        $portidend = $port.PortIdEnd
        New-IntersightFabricPortMode -PortPolicy $newPortPolicyObj -CustomMode $custommode -SlotId $slotid -PortIdStart $portidstart -PortIdEnd $portidend | Out-Null
    }
}

#################### FC Uplink Role ##################
$fcUplinkRole = Get-IntersightFabricFcUplinkRole -Parent ($portPolicy | Get-IntersightMoMoRef)

if ($fcUplinkRole) {
    Write-Debug "Update FC Uplink Role"
    foreach ($fcuplink in $fcUplinkRole) {
        $adminspeed = $fcuplink.AdminSpeed
        $aggregateportid = $fcuplink.AggregatePortId
        $slotid = $fcuplink.SlotId
        $portid = $fcuplink.PortId
        $vsanid = $fcuplink.VsanId
        New-IntersightFabricFcUplinkRole -PortPolicy $newPortPolicyObj -AdminSpeed $adminspeed -SlotId $slotid -PortId $portid -VsanId $vsanid -AggregatePortId $aggregateportid | Out-Null
    }
}

#################### FC Storage Role ###############
$fcStorageRole = Get-IntersightFabricFcStorageRole -Parent ($portPolicy | Get-IntersightMoMoRef)

if ($fcStorageRole) {
    Write-Debug "Update FC Storage Role"
    foreach ($fcstorage in $fcStorageRole) {
        $adminspeed = $fcstorage.AdminSpeed
        $aggregateportid = $fcstorage.AggregatePortId
        $slotid = $fcstorage.SlotId
        $portid = $fcstorage.PortId
        $vsanid = $fcstorage.VsanId
        New-IntersightFabricFcStorageRole -PortPolicy $newPortPolicyObj -AdminSpeed $adminspeed -SlotId $slotid -PortId $portid -VsanId $vsanid -AggregatePortId $aggregateportid | Out-Null
    }
}

#################### Uplink Role #####################
Invoke-CloneUplinkRole -Org $org -NewOrg $newOrg -PortPolicy $portPolicy -NewPortPolicy $newPortPolicy

#################### FCoE Uplink Role ################
Invoke-CloneFcoeUplinkRole -Org $org -NewOrg $newOrg -PortPolicy $portPolicy -NewPortPolicy $newPortPolicy

#################### Appliance Role ##################
Invoke-CloneApplianceRole -Org $org -NewOrg $newOrg -PortPolicy $portPolicy -NewPortPolicy $newPortPolicy

#################### Server Role #####################
Invoke-CloneServerRole -PortPolicy $portPolicy -NewPortPolicy $newPortPolicy

#################### Uplink PC Role ##################
Invoke-CloneUplinkPcRole -Org $org -NewOrg $newOrg -PortPolicy $portPolicy -NewPortPolicy $newPortPolicy

#################### FC Uplink PC ####################
Invoke-CloneFcUplinkPcRole -Org $org -NewOrg $newOrg -PortPolicy $portPolicy -NewPortPolicy $newPortPolicy

#################### FCoE Uplink PC ##################


#################### Appliance PC ####################

