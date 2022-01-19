$ApiParams = @{
    BasePath = "https://intersight.com"
    ApiKeyId = Get-Content -Path ./apiKey.txt -Raw
    ApiKeyFilePath = $pwd.Path + "/SecretKey.txt"
    HttpSigningHeader = @("(request-target)", "Host", "Date", "Digest")
}

Set-IntersightConfiguration @ApiParams
# Get Device Contract Info and write to file: contractInfo.csv 
Get-IntersightAssetDeviceContractInformation | select ContractStatus,ContractStatusReason,ServiceDescription,ServiceLevel,ServiceStartDate,ServiceEndDate,SalesOrderNumber,PurchaseOrderNumber,PlatformType,DeviceType,DeviceId -ExpandProperty Contract  | select DeviceId,DeviceType,PlatformType,ContractNumber,LineStatus,ContractStatus,ContractStatusReason,ServiceDescription,ServiceLevel,ServiceStartDate,ServiceEndDate,SalesOrderNumber,PurchaseOrderNumber | ConvertTo-Csv | Out-File "./contractInfo.csv"
