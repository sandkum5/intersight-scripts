# Script to import VLAN's in Intersight
# Takes a CSV file exported from UCSM
$ApiParams = @{
    BasePath          = "https://intersight.com"
    ApiKeyId          = Get-Content -Path "./apiKey.txt" -Raw
    ApiKeyFilePath    = $pwd.Path + "/SecretKey.txt"
    HttpSigningHeader = @("(request-target)", "Host", "Date", "Digest")
}

Set-IntersightConfiguration @ApiParams

#Get vlans from csv
$vlanList = Import-Csv ./vlans.csv -Header @("Name", "ID")


# Uncomment below two lines if the VLAN/Multicast Policies already exist
# $vlanPolicy = Get-IntersightFabricEthNetworkPolicy -Name "Cigna-VLAN-Policy" | Get-IntersightMoMoRef
# $mcastPolicy = Get-IntersightFabricMulticastPolicy -Name "MCAST" | Get-IntersightMoMoRef


# Comment lines 20,22-23,25-26 if VLAN/Multicast Policies are already created
$orgObj = Get-IntersightOrganizationOrganization -Name "default"

Write-Host "Create VLAN Policy" -ForegroundColor Green
$ethNetworkPolicy = New-IntersightFabricEthNetworkPolicy -Name "demo1" -Organization $orgObj

Write-Host "Create Multicast Policy" -ForegroundColor Green
$multicastPolicy = New-IntersightFabricMulticastPolicy -Name "demo1" -Organization $orgObj -SnoopingState "Enabled" -QuerierState "Disabled"


foreach($vlan in $vlanList) {
    if ($vlan.Name -eq "Name"){ continue }
    if ($vlan.ID -eq 1) { continue }

    $vlanId = $vlan.ID
    # $vlanName = $vlan.Name
    $vlanName = "VLAN" + $vlanId.ToString()

    # Add VLAN to the VLAN Policy
    New-IntersightFabricVlan -AutoAllowOnUplinks $false -Name $vlanName -VlanId $vlanId -MulticastPolicy $multicastPolicy -EthNetworkPolicy $ethNetworkPolicy | Out-Null

    Write-Host "Created VLAN $vlanName .." -ForegroundColor Green
}
