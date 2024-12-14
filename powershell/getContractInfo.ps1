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
    $contracts = (Get-IntersightAssetDeviceContractInformation -Top 1000 -Skip $skip -Expand 'Source($select=Dn,PlatformType,Model,Name,Serial,ManagementMode)').Results
    [System.Collections.ArrayList]$contractArray = @()
    ForEach($data in $contracts) {
        $dataObject = [PSCustomObject]@{
            DeviceId                = $data.DeviceId
            DeviceType              = $data.DeviceType
            PlatformType            = $data.PlatformType
            SourceManagementMode    = $data.Source.ActualInstance.AdditionalProperties.ManagementMode
            SourceName              = $data.Source.ActualInstance.AdditionalProperties.Name
            SourceDn                = $data.Source.ActualInstance.AdditionalProperties.Dn
            SourceModel             = $data.Source.ActualInstance.AdditionalProperties.Model
            ContractStatus          = $data.ContractStatus
            ContractStatusReason    = $data.ContractStatusReason
            ServiceDescription      = $data.ServiceDescription
            ServiceLevel            = $data.ServiceLevel
            ServiceStartDate        = $data.ServiceStartDate
            ServiceEndDate          = $data.ServiceEndDate
            SalesOrderNumber        = $data.SalesOrderNumber
            PurchaseOrderNumber     = $data.PurchaseOrderNumber
            ContractContractNumber  = $data.Contract.ContractNumber
            ContractLineStatus      = $data.Contract.LineStatus
        }
        $contractArray.Add($dataObject) | Out-Null
    }
    $contractArray | Export-Csv -Path "Contracts.csv" -NoTypeInformation -Append 
    $skip += 1000
    $count += 1000
}
