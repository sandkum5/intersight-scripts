<#
    Get OrgName
    Create MulticastPolicy, VLAN Policy
    Add VLANs using bulkRequest API Endpoint
#>

Function Invoke-AddVLANs {
    param (
        $vlans,
        $ethNetworkPolicy,
        $multicastPolicy,
        $AutoAllowOnUplinks
    )
    $request = [System.Collections.ArrayList]@()
    foreach($vlan in $vlans) {
        # $vlanName = $vlan.Name                      # Uncomment for VLAN Name same as csv filename
        $vlanName = "VLAN_"+$vlan.ID                  # Uncomment for VLAN Name Format: VLAN_x
        # $null, $vlanName, $null = $vlan.Name -split " "
        $vlanId = $vlan.ID
        if ($vlan.Native -eq "No") {
            $IsNative = $false
        } elseif ($vlan.Native -eq "Yes") {
            $IsNative = $true
        }
        $SharingType = $vlan.VLANSharing

        if ($SharingType -in ("Isolated", "Community")) {
            $PrimaryVlanName = $vlan.PrimaryVlan
            foreach ($vlanInfo in $vlans) {
                $null, $vlanInfoName, $null = $vlanInfo.Name -split " "
                if ($vlanInfo.VLANSharing -eq "Primary") {
                    if ($vlanInfoName -eq $PrimaryVlanName) {
                        [long]$PrimaryVlanId = $vlanInfo.ID
                    }
                }
            }
            # Add VLAN to the VLAN Policy
            $additionalProps = Initialize-IntersightFabricVlan -Name $vlanName -VlanId $vlanId -EthNetworkPolicy $ethNetworkPolicyRel -SharingType $SharingType -AutoAllowOnUplinks $AutoAllowOnUplinks -PrimaryVlanId $PrimaryVlanId -IsNative $IsNative
            # -MulticastPolicy $multicastPolicyRel 
            $additionalPropsObj = New-Object System.Collections.Generic.Dictionary"[String,Object]"
            $additionalPropsObj.Add("Body",$additionalProps)
            $request += Initialize-IntersightBulkSubRequest -Verb "POST" -Uri "/v1/fabric/Vlans" -AdditionalProperties $additionalPropsObj

        } elseif ($SharingType -in ("Primary")) {
            $additionalProps = Initialize-IntersightFabricVlan -Name $vlanName -VlanId $vlanId -EthNetworkPolicy $ethNetworkPolicyRel -SharingType $SharingType -AutoAllowOnUplinks $AutoAllowOnUplinks -PrimaryVlanId 0 -IsNative $IsNative
            $additionalPropsObj = New-Object System.Collections.Generic.Dictionary"[String,Object]"
            $additionalPropsObj.Add("Body",$additionalProps)
            $request += Initialize-IntersightBulkSubRequest -Verb "POST" -Uri "/v1/fabric/Vlans" -AdditionalProperties $additionalPropsObj

        } else {
            $PrimaryVlanId = 0
            $additionalProps = Initialize-IntersightFabricVlan -Name $vlanName -VlanId $vlanId -EthNetworkPolicy $ethNetworkPolicyRel -MulticastPolicy $multicastPolicyRel -SharingType $SharingType -AutoAllowOnUplinks $AutoAllowOnUplinks -PrimaryVlanId 0 -IsNative $IsNative
            $additionalPropsObj = New-Object System.Collections.Generic.Dictionary"[String,Object]"
            $additionalPropsObj.Add("Body",$additionalProps)
            $request += Initialize-IntersightBulkSubRequest -Verb "POST" -Uri "/v1/fabric/Vlans" -AdditionalProperties $additionalPropsObj
        }
    }
    # Intersight API Bulk Request
    New-IntersightBulkRequest -Requests $request | Out-Null
}



$ApiParams = @{
    BasePath             = "https://intersight.com"
    ApiKeyId             = Get-Content -Path "/Path/To/ApiKey.txt" -Raw     # Update
    ApiKeyFilePath       = "/Path/To/SecretKey.txt"                         # Update
    HttpSigningHeader    = @("(request-target)", "Host", "Date", "Digest")
    SkipCertificateCheck = $false
}

Set-IntersightConfiguration @ApiParams

# Variables
$OrgName             = "default"            # Update
$VlanPolicyName      = "Demo"               # Update
$MulticastPolicyName = "Demo"               # Update
# Variables for Multicast Policy
$SnoopingState       = "Enabled"            # Update
$QuerierState        = "Disabled"           # Update
# CSV file exported from UCSM
$FileName            = "./Demo.csv"         # Update
$AutoAllowOnUplinks  = $false


# Get Organization Info
$orgRel = Get-IntersightOrganizationOrganization -Name $OrgName | Get-IntersightMoMoRef

# Verify Multicast Policy Exists, If not Create
try {
    $multicastPolicyRel = Get-IntersightFabricMulticastPolicy -Name $MulticastPolicyName | Get-IntersightMoMoRef
    if ($multicastPolicyRel) {
        Write-Host "Multicast Policy $($MulticastPolicyName) already exists under Org: $($OrgName)" -ForegroundColor "Green"
    } else {
        <# Action when all if and else if conditions are false #>
        Write-Host "Creating Multicast Policy: $($MulticastPolicyName)" -ForegroundColor "Green"
        $multicastPolicy = New-IntersightFabricMulticastPolicy -Name $MulticastPolicyName -Organization $orgRel -SnoopingState $SnoopingState -QuerierState $QuerierState
        if ($multicastPolicy) {
            $multicastPolicyRel = $multicastPolicy | Get-IntersightMoMoRef
        } else {
            Write-Host "Error creating Multicast Policy: $($MulticastPolicyName)" -ForegroundColor "Red"
        }
    }
}
catch {
    Write-Host $_
}

# Verify VLAN Policy Exists, If not Create
try {
    $ethNetworkPolicyRel = Get-IntersightFabricEthNetworkPolicy -Name $VlanPolicyName -Organization $orgRel | Get-IntersightMoMoRef
    if ($ethNetworkPolicyRel) {
        Write-Host "VLAN Policy $($VlanPolicyName) already exists under Org: $($OrgName)" -ForegroundColor "Green"
    } else {
        Write-Host "Creating VLAN Policy: $($VlanPolicyName)" -ForegroundColor Green
        $ethNetworkPolicy = New-IntersightFabricEthNetworkPolicy -Name $VlanPolicyName -Organization $orgRel
        if ($ethNetworkPolicy) {
            $ethNetworkPolicyRel = $ethNetworkPolicy | Get-IntersightMoMoRef
        } else {
            Write-Host "Error creating VLAN Policy: $($VlanPolicyName)" -ForegroundColor "Red"
        }
    }
}
catch {
    Write-Host $_
}

# Update VLAN 1 Multicast Policy
$VlanMoid = (Get-IntersightFabricVlan -Parent $ethNetworkPolicyRel | Where-Object {$_.VlanId -eq 1}).Moid
Set-IntersightFabricVlan -Moid $VlanMoid -EthNetworkPolicy $ethNetworkPolicyRel -MulticastPolicy $multicastPolicyRel | Out-Null

# Get VLANs from CSV
$ImportedVlan = Import-Csv $FileName -Header @("Name", "ID", "Type", "Transport", "Native", "VLANSharing", "PrimaryVLAN", "MulticastPolicyName")
$vlanList = $ImportedVlan | Select-Object -Skip 1

$totalCount = $vlanList.Length
Write-Host "Total VLANs to add: $($totalCount)" -ForegroundColor "Green"

$count = [int][Math]::Ceiling($totalCount/100)

for ($i=1; $i -le $count; $i++) {
    if ($i -eq 1) {
        $startVlan = 1
        $endVlan = 100
    } elseif ($i -eq $count) {
        $startVlan = $i*100 - 99
        $endVlan = $totalCount
    } else {
        $startVlan = $i*100 - 99
        $endVlan = $i*100
    }
    Write-Host "Adding VLANs: Start Range: $($startVlan), End Range: $($endVlan)" -ForegroundColor "Green"
    $vlans = $vlanList[$startVlan..$endVlan]
    Invoke-AddVLANs -vlans $vlans -ethNetworkPolicy $ethNetworkPolicyRel -MulticastPolicy $multicastPolicyRel -AutoAllowOnUplinks $AutoAllowOnUplinks
}
