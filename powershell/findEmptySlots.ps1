<#
    Print Empty Slots in UCSM Domains connected to Intersight
    Caveats:
        Doesn't take into consideration a full-width blade
#>

$ApiParams = @{
    BasePath = "https://intersight.com"
    ApiKeyId = Get-Content -Path "./ApiKey.txt" -Raw
    ApiKeyFilePath = "./SecretKey.txt"
    HttpSigningHeader = @("(request-target)", "Host", "Date", "Digest")
}

Set-IntersightConfiguration @ApiParams

#Get Blade Server Names
$ServerNames = Get-IntersightComputePhysicalSummary -Top 1000 | Where-object {$_.SourceObjectType -eq "compute.Blade"} | Select-Object Name

$ServerNames = [System.Collections.ArrayList]@()
$skip = 0
$count = 0
$totalCount = (Get-IntersightComputePhysicalSummary -Count $true).Count

while ($count -le $totalCount)
{
    $ServerNames += (Get-IntersightComputePhysicalSummary -Top 100 -Skip $skip).Results | Where-object {$_.SourceObjectType -eq "compute.Blade"} | Select-Object Name
    $skip += 100
    $count += 100
}

#Create a nested hashtable
$properties = @{}
foreach ($Server in $ServerNames) {
    $x = $Server.Name | Select-String -Pattern "^(.+)-(\d+)-(\d)"
    $DomainName = $x.Matches.Groups[1].Value
    $ChassisId = $x.Matches.Groups[2].Value
    $ServerId = $x.Matches.Groups[3].Value

    if ($properties.ContainsKey($DomainName)){
    } else {
        $properties.Add($DomainName, @{}) | Out-Null
    }
    if ($properties[$DomainName].ContainsKey($ChassisId)) {
    } else {
        $properties[$DomainName].Add($ChassisId, [System.Collections.ArrayList]@()) | Out-Null
    }
    $properties[$DomainName][$ChassisId].Add($ServerId) | Out-Null
}


#Print Domain, Chassis, EmptySlot Info
foreach ($domain in $properties.Keys) {
    Write-Host "Domain: $($domain)"
    foreach ($chassis in $properties[$domain].Keys) {
        $serverList = $properties[$domain][$chassis]
        $emptySlots = [System.Collections.ArrayList]@()
        foreach ($server in 1..8) {
            if ( $serverList -contains $server) {
                continue
            } else {
                $emptySlots.Add($server) | Out-Null
            }
        }
        if ($emptySlots) {
            Write-Host "  Chassis: $($chassis)"
            Write-Host "    EmptySlots: $($emptySlots)"
        }
    }
}
