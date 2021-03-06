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
while ($count -le $totalCount)
{
    Get-IntersightAssetDeviceContractInformation -Top 100 -Skip $skip | select -ExpandProperty Results | select  ContractStatus,ContractStatusReason,ServiceDescription,ServiceLevel,ServiceStartDate,ServiceEndDate,SalesOrderNumber,PurchaseOrderNumber,PlatformType,DeviceType,DeviceId -ExpandProperty Contract  | select DeviceId,DeviceType,PlatformType,ContractNumber,LineStatus,ContractStatus,ContractStatusReason,ServiceDescription,ServiceLevel,ServiceStartDate,ServiceEndDate,SalesOrderNumber,PurchaseOrderNumber | Export-Csv -Path "ContractInfo.csv" -NoTypeInformation -Append
    $skip += 100
    $count += 100
}
