<#
.SYNOPSIS
    Script to Import UCSM VLANs in Intersight
.DESCRIPTION
    NOTE: Please be careful with the VLAN Policy name as it will update any existing policy.
    Script to Import UCSM VLANs in Intersight
    Input Parameters
        $OrgName        - Organization under which we want to create the VLAN Policy. Make sure the Org is created within Intersight
        $VlanPolicyName - VLAN Policy Name which will be created within Intersight
        $FileName       - CSV File exported from UCSM
        $DefaultMulticastPolicyName - Multicast policy name which will be created and assigned to VLAN if no Multicast policy exists in UCSM for the VLAN
        Multicast Policy Settings if the policy doesn't exist in Intersight:
            $SnoopingState = "Enabled"
            $QuerierState = "Disabled"
.LINK
    Be sure to check out more PowerShell code on https://github.com/CiscoDevNet/intersight-powershell-utils
.EXAMPLE
#>

# Intersight Configuration
$ApiParams = @{
    BasePath             = "https://intersight.com"
    ApiKeyId             = Get-Content -Path "/Path/to/ApiKey.txt" -Raw
    ApiKeyFilePath       = "/Path/to/SecretKey.txt"
    HttpSigningHeader    = @("(request-target)", "Host", "Date", "Digest")
    SkipCertificateCheck = $false
}

Set-IntersightConfiguration @ApiParams

# Variables
$OrgName = "default"
$VlanPolicyName = "pwsh_demo"

# CSV file exported from UCSM
$FileName = "./ucsm-vlan-export.csv"
$DefaultMulticastPolicyName = "default_pwsh_demo"
$SnoopingState = "Enabled"
$QuerierState = "Disabled"

# Get Organization Info
$orgRel = Get-IntersightOrganizationOrganization -Name $OrgName | Get-IntersightMoMoRef

# Get VLAN Policy
try {
    $ethNetworkPolicyRel = Get-IntersightFabricEthNetworkPolicy -Name $VlanPolicyName -Organization $orgRel | Get-IntersightMoMoRef
}
catch {
    Write-Host $_
}

# Check if VLAN Policy exists. If not, create VLAN Policy
if ($ethNetworkPolicyRel) {
    Write-Host "VLAN Policy $($VlanPolicyName) already exists under Org: $($OrgName)"
} else {
    Write-Host "Creating VLAN Policy: $($VlanPolicyName)" -ForegroundColor Green
    $ethNetworkPolicy = New-IntersightFabricEthNetworkPolicy -Name $VlanPolicyName -Organization $orgRel
    $ethNetworkPolicyRel = $ethNetworkPolicy | Get-IntersightMoMoRef
}

# Get VLANs from CSV
$VlanList = Import-Csv $FileName -Header @("Name", "ID", "Type", "Transport", "Native", "VLANSharing", "PrimaryVLAN", "MulticastPolicyName")
$vlans = $VlanList | Select-Object -Skip 1
# $vlans = Import-Csv $FileName


foreach($vlan in $vlans) {
    # $vlanName = $vlan.Name
    $null, $vlanName, $null = $vlan.Name -split " "
    $vlanId = $vlan.ID
    if ($vlan.Native -eq "No") {
        $IsNative = $false
    } elseif ($vlan.Native -eq "Yes") {
        $IsNative = $true
    }
    $SharingType = $vlan.VLANSharing
    $MulticastPolicyName = $vlan.MulticastPolicyName

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
        # Write-Host $vlanName $vlanId
        New-IntersightFabricVlan -AutoAllowOnUplinks $false -Name $vlanName -VlanId $vlanId -EthNetworkPolicy $ethNetworkPolicyRel -PrimaryVlanId $PrimaryVlanId -SharingType $SharingType -IsNative $IsNative | Out-Null

        Write-Host "Added $($SharingType) VLAN $($vlanName)" -ForegroundColor Green

    } elseif ($SharingType -in ("Primary")) {
        # Add VLAN to the VLAN Policy
        # Write-Host $vlanName $vlanId
        New-IntersightFabricVlan -AutoAllowOnUplinks $false -Name $vlanName -VlanId $vlanId -EthNetworkPolicy $ethNetworkPolicyRel -PrimaryVlanId 0 -SharingType $SharingType -IsNative $IsNative | Out-Null

        Write-Host "Added $($SharingType) VLAN: $($vlanName)" -ForegroundColor Green

    } else {
        $PrimaryVlanId = 0
        # Get Multicast Policy
        if ($MulticastPolicyName -eq "") {
            $multicastPolicy = Get-IntersightFabricMulticastPolicy -Name $DefaultMulticastPolicyName -Organization $orgRel
        } else  {
            $multicastPolicy = Get-IntersightFabricMulticastPolicy -Name $MulticastPolicyName
        }

        # If Multicast Policy Exists
        if ($multicastPolicy) {
            $multicastPolicyRel = $multicastPolicy | Get-IntersightMoMoRef
            # Add VLAN to the VLAN Policy
            if ($vlanId -eq 1) {
                # Add VLAN 1 Update Logic
                $VlanMoid = (Get-IntersightFabricVlan -Parent $ethNetworkPolicyRel | Where-Object {$_.VlanId -eq 1}).Moid
                Set-IntersightFabricVlan -Moid $VlanMoid -EthNetworkPolicy $ethNetworkPolicyRel -MulticastPolicy $multicastPolicyRel | Out-Null
            } else {
                # Write-Host $vlanName $vlanId
                New-IntersightFabricVlan -AutoAllowOnUplinks $false -Name $vlanName -VlanId $vlanId -MulticastPolicy $multicastPolicyRel -EthNetworkPolicy $ethNetworkPolicyRel -PrimaryVlanId $PrimaryVlanId -SharingType $SharingType -IsNative $IsNative | Out-Null

                Write-Host "Added VLAN: $($vlanName) with Multicast Policy: $($multicastPolicy.Name)" -ForegroundColor Green
            }

        } else {
            # If Multicast Policy Doesn't exist
            if ($MulticastPolicyName -eq "") {
                Write-Host "Creating Default Multicast Policy: $($DefaultMulticastPolicyName)" -ForegroundColor Green
                $multicastPolicy = New-IntersightFabricMulticastPolicy -Name $DefaultMulticastPolicyName -Organization $orgRel -SnoopingState $SnoopingState -QuerierState $QuerierState
            } else {
                Write-Host "Creating Multicast Policy: $($MulticastPolicyName)" -ForegroundColor Green
                $multicastPolicy = New-IntersightFabricMulticastPolicy -Name $MulticastPolicyName -Organization $orgRel -SnoopingState $SnoopingState -QuerierState $QuerierState
            }

            $multicastPolicyRel = $multicastPolicy | Get-IntersightMoMoRef
            # Add VLAN to the VLAN Policy
            if ($vlanId -eq 1) {
                # Add VLAN 1 Update Logic
                $VlanMoid = (Get-IntersightFabricVlan -Parent $ethNetworkPolicyRel | Where-Object {$_.VlanId -eq 1}).Moid
                Set-IntersightFabricVlan -Moid $VlanMoid -EthNetworkPolicy $ethNetworkPolicyRel -MulticastPolicy $multicastPolicyRel | Out-Null
            } else {
                New-IntersightFabricVlan -AutoAllowOnUplinks $false -Name $vlanName -VlanId $vlanId -MulticastPolicy $multicastPolicyRel -EthNetworkPolicy $ethNetworkPolicyRel -PrimaryVlanId $PrimaryVlanId -SharingType $SharingType -IsNative $IsNative | Out-Null
                Write-Host "Added VLAN: $($vlanName) with Multicast Policy: $($multicastPolicy.Name)" -ForegroundColor Green
            }
        }
    }
}
