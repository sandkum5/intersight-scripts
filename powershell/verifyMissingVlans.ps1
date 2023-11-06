<#
    Steps:
    Get VLAN Policy VLANs
    Get Group Policy VLANs
    Compare Ethernet Network Group Policy VLANs against the VLAN Policy and if a VLAN is missing, list the VLAN
#>

$ApiParams = @{
    BasePath             = "https://intersight.com"
    ApiKeyId             = Get-Content -Path "/Path/To/ApiKey.txt" -Raw     # Update
    ApiKeyFilePath       = "/Path/To/SecretKey.txt"                         # Update
    HttpSigningHeader    = @("(request-target)", "Host", "Date", "Digest")
    SkipCertificateCheck = $false
}

Set-IntersightConfiguration @ApiParams

$OrgName = "default"                        # Update
$VlanPolicyName = "Demo"                    # Update
$EthNetGroupPolicyName = "Demo"             # Update


# Get Organization Object
$OrgObj = Get-IntersightOrganizationOrganization -Name $OrgName | Get-IntersightMoMoRef

# Get Ethernet Network Group Policy VLANs
Write-Host "Pulling Ethernet Network Group Policy VLANs" -ForegroundColor "Green"
$EthNetGroupPolicy = Get-IntersightFabricEthNetworkGroupPolicy -Name $EthNetGroupPolicyName -Organization $OrgObj

if ($EthNetGroupPolicy) {
    $ExistingAllowedVLANs = $EthNetGroupPolicy.VlanSettings.AllowedVlans
}

$EthNetworkGroupList = $ExistingAllowedVLANs -split ","
$EthNetworkGroupSet = $EthNetworkGroupList | Select-Object -Unique


# Get VLAN Policy VLANs
Write-Host "Pulling VLAN Policy VLANs" -ForegroundColor "Green"
$ethNetworkPolicy = Get-IntersightFabricEthNetworkPolicy -Name $VlanPolicyName -Organization $OrgObj
$ethNetworkPolicyMoid = $ethNetworkPolicy.Moid

$skip = 0
$count = 0
$totalCount = (Get-IntersightFabricVlan -Count $true -Filter "Parent.Moid eq '$($ethNetworkPolicyMoid)'").Count
$vlanPolicyList = [System.Collections.ArrayList]@()

while ($count -le $totalCount) {
    $vlans = (Get-IntersightFabricVlan -Top 100 -Skip $skip -Filter "Parent.Moid eq '$($ethNetworkPolicyMoid)'").Results.VlanId
    $skip += 100
    $count += 100
    $vlanPolicyList += $vlans
}

$Missing = $false
Write-Host "Checking Missing VLANs..." -ForegroundColor "Green"
foreach ($groupVlan in $EthNetworkGroupSet) {
    if ($groupVlan -in $vlanPolicyList) {
        continue
    } else {
        Write-Host "VLAN: $($groupVlan) not in VLAN Policy!" -ForegroundColor Red
        $Missing = $true
    }
}
if (-Not $Missing) {
    Write-Host "No Missing VLANs found!" -ForegroundColor "Green"
}
