# Script to Get Interface MAC configured under Boot Policy
$ApiParams = @{
    BasePath = "https://intersight.com"
    ApiKeyId = Get-Content -Path "./ApiKey.txt" -Raw
    ApiKeyFilePath = "./SecretKey.txt"
    HttpSigningHeader = @("(request-target)", "Host", "Date", "Digest")
}

Set-IntersightConfiguration @ApiParams

$ServerSerial = "xxxx"
$ServerName = ""

# Get Server Object
if ($ServerSerial -ne "") {
    $ServerRel = (Get-IntersightComputePhysicalSummary -Filter "Serial eq $($ServerSerial)").Results | Get-IntersightMoMoRef
}
if ($ServerName -ne "") {
    $ServerRel = (Get-IntersightComputePhysicalSummary -Name $ServerName | Get-IntersightMoMoRef
}

# Get ServerProfile associated with Server
if ($ServerRel) {
    $ServerProfile = Get-IntersightServerProfile -AssociatedServer $ServerRel
}

# Find Boot Policy Moid
if ($ServerProfile) {
    $BootPolicyMoid = ($ServerProfile.PolicyBucket.ActualInstance | Where-Object {$_.ObjectType -eq 'BootPrecisionPolicy'}).Moid

    # Get Interfaces
    $VnicEthIfs = (Get-IntersightVnicEthIf -Filter "(Profile.Moid eq '$($ServerProfile.Moid)')").Results
}
else {
    Write-Host "Server is not associated with any Server Profile!"
}

# Boot Policy
if ($BootPolicyMoid) {
    $PXEObject =  (Get-IntersightBootPrecisionPolicy -Moid $BootPolicyMoid).BootDevices | Where-Object {$_.ObjectType -eq 'BootPxe'}
} else {
    Write-Host "No Boot Policy Configured"
}

# Get Interface Name from Boot Policy
if ($PXEObject) {
    $BootInterfaceName = $PXEObject.AdditionalProperties.InterfaceName
}
else {
    Write-Host "No PXE Boot Object Configuration"
}

# Get the Interface MAC defined in Boot Policy
if ($VnicEthIfs) {
    $InterfaceMac = ($VnicEthIfs | Where-Object {$_.Name -eq $BootInterfaceName}).MacAddress
}
else {
    Write-Host "Interface Names Configured under LAN Connectivity Policy don't match with Interface Name configured under Boot Policy!"
}

Write-Host "Interface: $($BootInterfaceName), Mac Address: $($InterfaceMac)"
