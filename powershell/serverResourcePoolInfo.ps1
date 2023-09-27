# Script to List Server Name along with Resource Pool Name
# Show which servers are not part of any resource pool or part of one or more than one resource pool

$ApiParams = @{
    BasePath = "https://intersight.com"
    ApiKeyId = Get-Content -Path "/Path/to/ApiKey.txt" -Raw
    ApiKeyFilePath = "/Path/to/SecretKey.txt"
    HttpSigningHeader = @("(request-target)", "Host", "Date", "Digest")
}

Set-IntersightConfiguration @ApiParams

# Server Data
$serverData = [System.Collections.ArrayList]@()
$skip = 0
$count = 0
$totalCount = (Get-IntersightComputePhysicalSummary -Count $true).Count
while ($count -le $totalCount)
{
    $serverInfo = Get-IntersightComputePhysicalSummary -Top 100 -Skip $skip | Select-Object -ExpandProperty Results | Select-Object Name,Moid,Model,Serial,ManagementMode,ChassisId,PlatformType
    foreach ($server in $serverInfo) {
        $tempServerData = @{}
        $tempServerData["Moid"] = $server.Moid
        $tempServerData["Name"] = $server.Name
        $tempServerData["Model"] = $server.Model
        $tempServerData["Serial"] = $server.Serial
        $tempServerData["ManagementMode"] = $server.ManagementMode
        $tempServerData["ChassisId"] = $server.ChassisId
        $tempServerData["PlatformType"] = $server.PlatformType
        $serverData.Add($tempServerData) | Out-Null
    }
    $skip += 100
    $count += 100
}

# Resource Pool Data
$RPs = (Get-IntersightResourcepoolPool -top 1000).Results

$resourcePoolData = [System.Collections.ArrayList]@()
foreach ($RP in $RPs) {
    $tempRPData = @{}
    $tempRPData["Name"] = $RP.Name
    $info = (Get-IntersightResourcepoolPool -Name $RP.Name).Selectors.Selector
    $parser1 = ($info -split "\(")[2]
    $parser2 = ($parser1 -split "\)")[0]
    $parser3 = $parser2 -split ","
    $serverMoids = $parser3 -split "'" | Where-Object {$_ -ne ""}
    $tempRPData["ServerMoids"] = $serverMoids
    $resourcePoolData.Add($tempRPData) | Out-Null
}


# Add Server and Resource Pool Data under jsonData dictionary
$jsonData = @{}
$jsonData["Server"] = $serverData
$jsonData["ResourcePool"] = $resourcePoolData

# Write jsonData to a json file
$jsonData | ConvertTo-Json -Depth 4 | Out-File "$pwd/ServerRPData.json"

# Print Server and Resource Pool Name
foreach ($server in $jsonData.Server) {
    Write-Host "Server: $($server.Name)"
    foreach ($rp in $jsonData.ResourcePool) {
        if ($server.Moid -in $rp.ServerMoids) {
            Write-Host "    ResourcePool: $($rp.Name)"
        }
    }
}

# Sample Output
<#
> ./serverResourcePoolInfo.ps1Server: imm-fi-loan-1-1
Server: cx-imm-ucs-4
Server: imm-fi-loan-1-3
    ResourcePool: RP_demo1
    ResourcePool: RP_demo2
Server: cx-imm-ucs-5
Server: cx-imm-ucs-3
Server: imm-fi-loan-1-4
    ResourcePool: RP_demo1
    ResourcePool: RP_demo2
Server: imm-fi-loan-1-2
    ResourcePool: RP_demo2
Server: cx-hx-fi1-ucsm-6
Server: cx-hx-fi1-ucsm-7
#>
