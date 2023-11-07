<#
    Update Intersight Server License Tier based on Server Model
#>

# Variables
$RackModel   = ""          # Update
$BladeModel  = ""          # Update
$LicenseTier = "Advantage" # Update, Options: Base, Essential, Advantage

Write-Host "Target License Tier: $($LicenseTier)" -ForegroundColor "Red"

# Update Blade Servers
$skip=0
$count=0
$totalCount = (Get-IntersightComputeBlade -Filter "Model eq '$($BladeModel)'").Results.Count
if ($totalCount) {
    while ($count -le $totalCount) {
        $bladeData = (Get-IntersightComputeBlade -Top 0 -Skip $skip -Filter "Model eq '$($BladeModel)'").Results | Select-Object Name,Serial,Model,Moid,Tags
        $skip += 100
        $count += 100
        foreach ($server in $bladeData) {
            # Initialize tags
            $update = $true
            $tags = [System.Collections.ArrayList]@()
            foreach ($tag in $server.Tags) {
                if ($tag.Key -eq "Intersight.LicenseTier") {
                    $tagValue = $LicenseTier
                    if ($tag.Value -eq $LicenseTier) {
                        $update = $false
                    }
                } else {
                    $tagValue = $tag.Value
                }
                $tagObject = Initialize-IntersightMoTag -Key $tag.Key -Value $tagValue
                $tags.Add($tagObject) | Out-Null
            }
            if ($update) {
                # Set VM Tags, Add try/catch statement
                $Info = Set-IntersightComputeBlade -Tags $tags -Moid $server.Moid
                Write-Host "Serial: $($Info.Serial) updated with new License Tier: $($LicenseTier), ServerName: $($server.Name), " -ForegroundColor "Green"
            } else {
                Write-Host "Serial: $($server.Serial) already at License Tier: $($LicenseTier), ServerName: $($server.Name), " -ForegroundColor "Yellow"
            }
        }
    }
} else {
    Write-Host "No Servers Found!"
}


# Update Rack Servers
$skip=0
$count=0
$totalCount = (Get-IntersightComputeRackUnit -Filter "Model eq '$($RackModel)'").Results.Count
if ($totalCount) {
    while ($count -le $totalCount) {
        $Data = (Get-IntersightComputeRackUnit -Top 0 -Skip $skip -Filter "Model eq '$($RackModel)'").Results | Select-Object Name,Serial,Model,Moid,Tags
        $skip += 100
        $count += 100
        foreach ($server in $Data) {
            # Initialize tags
            $update = $true
            $tags = [System.Collections.ArrayList]@()
            foreach ($tag in $server.Tags) {
                if ($tag.Key -eq "Intersight.LicenseTier") {
                    $tagValue = $LicenseTier
                    if ($tag.Value -eq $LicenseTier) {
                        $update = $false
                    }
                } else {
                    $tagValue = $tag.Value
                }
                $tagObject = Initialize-IntersightMoTag -Key $tag.Key -Value $tagValue
                $tags.Add($tagObject) | Out-Null
            }
            if ($update) {
                # Set VM Tags, Add try/catch statement
                $Info = Set-IntersightComputeRackUnit -Tags $tags -Moid $server.Moid
                Write-Host "Serial: $($Info.Serial) updated with new License Tier: $($LicenseTier), ServerName: $($server.Name), " -ForegroundColor "Green"
            } else {
                Write-Host "Serial: $($server.Serial) already at License Tier: $($LicenseTier), ServerName: $($server.Name), " -ForegroundColor "Yellow"
            }
        }
    }
} else {
    Write-Host "No Servers Found!"
}
