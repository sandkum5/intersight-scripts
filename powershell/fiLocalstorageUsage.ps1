<#
    Script to get FI Local Storage Utilization 
    Useful before Firmware Upgrades. 
    Usage: Find high storage uitlization and bring it below a certain threshold before upgrade.
    
    GUI Location: Intersight GUI > Operate > Fabric Interconnects > Select FI > Inventory > Local Storage
#>


$ApiParams = @{
    BasePath = "https://intersight.com"
    ApiKeyId = Get-Content -Path ./apiKey.txt -Raw
    ApiKeyFilePath = $pwd.Path + "/SecretKey.txt"
    HttpSigningHeader = @("(request-target)", "Host", "Date", "Digest")
}

Set-IntersightConfiguration @ApiParams

$skip = 0
$count = 0
$totalCount = (Get-IntersightStorageItem -Count $true -Filter "(Size ne 'nothing') and (NetworkElement ne 'null')").Count

while ($count -le $totalCount)
{
    $FiData = (Get-IntersightStorageItem -Top 1000 -Skip $skip -Filter "(Size ne 'nothing') and (NetworkElement ne 'null')" -Expand "NetworkElement,RegisteredDevice").Results 

    [System.Collections.ArrayList]$DataArray = @()

    foreach ($fi in $FiData) {
        $dataObject = [PSCustomObject]@{
            DeviceHostname = $fi.RegisteredDevice.ActualInstance.DeviceHostname[0]
            Model          = $fi.NetworkElement.ActualInstance.Model
            Serial         = $fi.NetworkElement.ActualInstance.Serial
            Dn             = $fi.NetworkElement.ActualInstance.Dn
            DeviceMoId     = $fi.DeviceMoId
            Dir_Dn         = $fi.Dn
            Dir_Name       = $fi.Name
            Dir_Size       = $fi.Size
            Dir_Used       = $fi.Used
        }
        $DataArray.Add($dataObject) | Out-Null
    }
    $DataArray | Export-Csv -Path "FiLocalStorageUsage.csv" -NoTypeInformation -Append 
    $skip += 1000
    $count += 1000
}
