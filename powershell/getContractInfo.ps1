$ApiParams = @{
    BasePath = "https://intersight.com"
    ApiKeyId = Get-Content -Path ./apiKey.txt -Raw
    ApiKeyFilePath = $pwd.Path + "/SecretKey.txt"
    HttpSigningHeader = @("(request-target)", "Host", "Date", "Digest")
}

Set-IntersightConfiguration @ApiParams

$skip = 0
$count = 0
$totalCount = (Get-IntersightAssetDeviceContractInformation -Count $true).Count
$csv = @()
while ($count -le $totalCount)
{
    # $csv += Get-IntersightAssetDeviceContractInformation -Top 100 -Skip $skip | select -ExpandProperty Results | select DeviceId, DeviceType, ContractStatus, ServiceDescription, ServiceLevel, ServiceStartDate, ServiceEndDate
    $csv += Get-IntersightAssetDeviceContractInformation -Top 100 -Skip $skip | select -ExpandProperty Results | select  ContractStatus,ContractStatusReason,ServiceDescription,ServiceLevel,ServiceStartDate,ServiceEndDate,SalesOrderNumber,PurchaseOrderNumber,PlatformType,DeviceType,DeviceId -ExpandProperty Contract  | select DeviceId,DeviceType,PlatformType,ContractNumber,LineStatus,ContractStatus,ContractStatusReason,ServiceDescription,ServiceLevel,ServiceStartDate,ServiceEndDate,SalesOrderNumber,PurchaseOrderNumber
    $skip += 100
    $count += 100
}

# Export to a CSV File
$csv | Export-Csv -Path "ContractInfo.csv" -NoTypeInformation

# Print the results
# $csv | group DeviceType, ContractStatus | select Name, Count


# STALE CODE for Reference
# Get API returned object Count
# $deviceCount = (Get-IntersightAssetDeviceContractInformation -Count $true).Count
# Add 1 to the Quotient
# $loopCount = [System.math]::Floor($deviceCount / 100) + 1
# Get Device Contract Info and write to file: contractInfo.csv 
# for ($i = 0; $i -le $loopCount; $i++) {
#    $skip = ($i * 100)
#    Get-IntersightAssetDeviceContractInformation -Top 100 -Skip $skip | Select -ExpandProperty Results | select ContractStatus,ContractStatusReason,ServiceDescription,ServiceLevel,ServiceStartDate,ServiceEndDate,SalesOrderNumber,PurchaseOrderNumber,PlatformType,DeviceType,DeviceId -ExpandProperty Contract  | select DeviceId,DeviceType,PlatformType,ContractNumber,LineStatus,ContractStatus,ContractStatusReason,ServiceDescription,ServiceLevel,ServiceStartDate,ServiceEndDate,SalesOrderNumber,PurchaseOrderNumber  | ConvertTo-Csv | Out-File "./contractInfo.csv"
#}

