$ApiParams = @{
    BasePath = "https://intersight.com"
    ApiKeyId = Get-Content -Path ./apiKey.txt -Raw
    ApiKeyFilePath = $pwd.Path + "/SecretKey.txt"
    HttpSigningHeader = @("(request-target)", "Host", "Date", "Digest")
}

Set-IntersightConfiguration @ApiParams

# Get API returned object Count
$deviceCount = (Get-IntersightAssetDeviceContractInformation -Count $true).Count

# Add 1 to the Quotient
$loopCount = [System.math]::Floor($deviceCount / 100) + 1

# Get Device Contract Info and write to file: contractInfo.csv 
for ($i = 0; $i -le $loopCount; $i++) {
    $top = 100
    $skip = ($i * 100)
    Get-IntersightAssetDeviceContractInformation -Top $top -Skip $skip | Select -ExpandProperty Results | select ContractStatus,ContractStatusReason,ServiceDescription,ServiceLevel,ServiceStartDate,ServiceEndDate,SalesOrderNumber,PurchaseOrderNumber,PlatformType,DeviceType,DeviceId -ExpandProperty Contract  | select DeviceId,DeviceType,PlatformType,ContractNumber,LineStatus,ContractStatus,ContractStatusReason,ServiceDescription,ServiceLevel,ServiceStartDate,ServiceEndDate,SalesOrderNumber,PurchaseOrderNumber  | ConvertTo-Csv | Out-File "./contractInfo.csv"
}
