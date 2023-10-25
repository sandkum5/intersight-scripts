<#
    Export VLANs from UCSM VLAN Groups
    Create Ethernet Network Group Policy in Intersight using the UCSM VLAN Group Exported VLANs
    Input:
        OrgName               - Organization Name
        EthNetGroupPolicyName - Ethernet Network Group Policy Name
        NativeVLAN            - Native VLAN on the Uplink
        FileName              - UCSM FileName
#>

$ApiParams = @{
    BasePath             = "https://intersight.com"
    ApiKeyId             = Get-Content -Path "/Path/to/ApiKey.txt" -Raw
    ApiKeyFilePath       = "/Path/to/SecretKey.txt"
    HttpSigningHeader    = @("(request-target)", "Host", "Date", "Digest")
    SkipCertificateCheck = $false
}

Set-IntersightConfiguration @ApiParams

# Variables
$OrgName               = "default"              # Update
$EthNetGroupPolicyName = "demo"                 # Update
$NativeVLAN            = 1                      # Update
$FileName              = "DemoFile.csv"         # Update
$VLANGroup             = Import-Csv $FileName
$VLANList              = $VLANGroup."VLAN ID"

# Create Allowed VLAN String
$AllowedVLans = ""
$SET = $true
foreach ($VLAN in $VLANList) {
    if ($SET) {
        $AllowedVLans = $VLAN
        $SET = $false
    } else {
        $AllowedVLANs += "," + $VLAN
    }
}

# Get Organization Object
$OrgObj = Get-IntersightOrganizationOrganization -Name $OrgName | Get-IntersightMoMoRef

# Get Ethernet Network Group Policy
$EthNetGroupPolicy = Get-IntersightFabricEthNetworkGroupPolicy -Name $EthNetGroupPolicyName
if ($EthNetGroupPolicy) {
    # If Ethernet Network Group Policy Already Exists
    $EthNetGroupPolicyMoid = $EthNetGroupPolicy.Moid
    $ExistingAllowedVLANs = $EthNetGroupPolicy.VlanSettings.AllowedVlans
    $UpdatedAllowedVLANs = $ExistingAllowedVLANs + "," + $AllowedVLANs
    # Update Ethernet Network Group Policy
    $VlanSettings = Initialize-IntersightFabricVlanSettings -NativeVlan $NativeVLAN -AllowedVlans $UpdatedAllowedVLANs

    $UpdatedPolicy = Set-IntersightFabricEthNetworkGroupPolicy -Moid $EthNetGroupPolicyMoid -Organization $OrgObj -VlanSettings $VlanSettings
    $UpdatedVLANs = $UpdatedPolicy.VlanSettings.AllowedVlans
    Write-Host "Updated VLAN List: $($UpdatedVLANs)"
} else {
    # Create a new Ethernet Network Group Policy
    $VlanSettings = Initialize-IntersightFabricVlanSettings -NativeVlan $NativeVLAN -AllowedVlans $AllowedVLANs

    $NewPolicy = New-IntersightFabricEthNetworkGroupPolicy -Name $EthNetGroupPolicyName -VlanSettings $VlanSettings -Organization $OrgObj
    $VLANList = $NewPolicy.VlanSettings.AllowedVlans
    Write-Host "New Policy Created, Allowed VLAN List: $($VLANList)"
}

