<#
    Print Empty Slots in UCSM Domains connected to Intersight
    Prints all or Domain Specific Output
    Caveats:
        Doesn't take into consideration a full-width blade
#>

Function Invoke-ParseAllProperties {
    param (
        $properties
    )
    $allEmptySlots = [System.Collections.ArrayList]@()
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
                    $allEmptySlots.Add($server) | Out-Null
                }
            }
            if ($emptySlots) {
                Write-Host "  Chassis: $($chassis)"
                Write-Host "    EmptySlotIds: $($emptySlots)"
            }
        }
    }
    Write-Host "Total Empty Slots: $($allEmptySlots.Count)"
}

Function Invoke-ParseDcProperties {
    param (
        $properties
    )
    $allEmptySlots = [System.Collections.ArrayList]@()
    $dc = Read-Host "Please enter DC"
    foreach ($domain in $properties.Keys) {
        if ($domain.ToLower().Contains($dc.ToLower())) {
            Write-Host "Domain: $($domain)"
            foreach ($chassis in $properties[$domain].Keys) {
                $serverList = $properties[$domain][$chassis]
                $emptySlots = [System.Collections.ArrayList]@()
                foreach ($server in 1..8) {
                    if ( $serverList -contains $server) {
                        continue
                    } else {
                        $emptySlots.Add($server) | Out-Null
                        $allEmptySlots.Add($server) | Out-Null
                    }
                }
                if ($emptySlots) {
                    Write-Host "  Chassis: $($chassis)"
                    Write-Host "    EmptySlotIds: $($emptySlots)"
                }
            }
        }
    }
    Write-Host "Total Empty Slots: $($allEmptySlots.Count)"
}

Function Invoke-ParseDCName {
    param (
        $properties,
        $chars
    )
    $dcPrefix = [System.Collections.ArrayList]@()
    foreach( $domain in $properties.Keys) {
        $pattern = "^([a-zA-Z0-9]{$($chars)})"
        $x = $domain | Select-String -Pattern $pattern
        if ($x) {
            $prefix = ($x.Matches.Groups[1].Value).ToLower() # Comment ToLower for casesensitive output
            $dcPrefix.Add($prefix) | Out-Null
        }
    }
    $uniqueList = $dcPrefix| Select-Object -Unique
    Write-Host "Available Domain Name Prefixes:"
    foreach ($chars in $uniqueList) {
        Write-Host $chars
    }
}

$ApiParams = @{
    BasePath = "https://intersight.com"
    ApiKeyId = Get-Content -Path "./ApiKey.txt" -Raw
    ApiKeyFilePath = "./SecretKey.txt"
    HttpSigningHeader = @("(request-target)", "Host", "Date", "Digest")
}

Set-IntersightConfiguration @ApiParams

#Get Blade Server Names
$ServerNames = [System.Collections.ArrayList]@()
$skip = 0
$count = 0
$totalCount = (Get-IntersightComputePhysicalSummary -Count $true).Count

Write-Host "API call to Intersight In-progress, 1 API call/1000 objects"
while ($count -le $totalCount)
{
    $loop = ($count / 1000) + 1
    Write-Host "$($loop) API Call!"
    $ServerNames += (Get-IntersightComputePhysicalSummary -Top 1000 -Skip $skip).Results | Where-object {$_.SourceObjectType -eq "compute.Blade"} | Select-Object Name
    $skip += 1000
    $count += 1000
}

#Create nested hashtable
Write-Host "Parsing Intersight Data"
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

$properties | ConvertTo-Json -Depth 2 | Out-File "data.json"

while ($true) {
    Write-Host ""
    Write-Host "Do you want All or DataCenter specific info?"
    $option = Read-Host "Options: all, dc, exit"

    if ($option.ToLower() -contains "all") {
        #Get All Domain Empty Slots
        Invoke-ParseAllProperties -properties $properties
    } elseif ($option.ToLower() -contains "dc") {
        #Print available Domain Names prefixes
        $chars = Read-Host "Characters to match"
        Invoke-ParseDCName -properties $properties -chars $chars
        #Get Domain prefix and print all matching Domains
        Invoke-ParseDcProperties -properties $properties
    } elseif ($option.ToLower() -contains "exit") {
        break
    }
}
