# Script to Trigger Intersight OS Installation Workflow
$OrgName = "default"
$ServerSerial = 'xxxxxxxx'

# Get Orgs
$OrgObj = Get-IntersightOrganizationOrganization -Name $OrgName | Get-IntersightMoMoRef

$Server = Get-IntersightComputePhysicalSummary -Serial $ServerSerial

if ($Server.PlatformType -eq "IMCBlade") {
    $ServerObj = Get-IntersightComputeBlade -Serial $ServerSerial | Get-IntersightMoMoRef
}

# Print available OS Config Filenames
$GetOSConfigFileNames = Get-IntersightOsConfigurationFile | Where-Object {$_.SharedScope -eq 'shared'} | Select-Object Name

Write-host "Available OS Config File Names:"
foreach ($Name in $GetOSConfigFileNames.Name) {
    Write-host $Name
}
# Take OSConfig File as Input:
# $OSConfigFile = 'ESXi7.0ConfigFile'
while ($True) {
    $OSConfigFile = Read-Host -Prompt "Enter an OS Config Filename from the above list"
    if ($OSConfigFile -in $GetOSConfigFileNames.Name) {
        Write-Host "OS Config Filename looks good!" -ForegroundColor Green
        break
    } else {
        Write-Host "Re-Enter OS Config Filename" -ForegroundColor Red
    }
}

$OSConfigFileObj = Get-IntersightOsConfigurationFile -Name $OSConfigFile | Get-IntersightMoMoRef

# OS Repo Info
$GetOSRepoNames = Get-IntersightSoftwarerepositoryOperatingSystemFile | Select-Object Name
Write-host "Available OS Repo Names:"
foreach ($Name in $GetOSRepoNames.Name) {
    Write-host $Name
}

# Take OS Repo Name as Input:
# $OSRepoName = "ESXi 7.0 Cisco Custom ISO"
while ($True) {
    $OSRepoName = Read-Host -Prompt "Enter an OS Repo Name from the above list"
    if ($OSRepoName -in $GetOSRepoNames.Name) {
        Write-Host "OS Repo Name looks good!" -ForegroundColor Green
        break
    } else {
        Write-Host "Re-Enter OS Repo Name" -ForegroundColor Red
    }
}

$OSRepoObj = Get-IntersightSoftwarerepositoryOperatingSystemFile -Name $OSRepoName | Get-IntersightMoMoRef

$iptype = "ipv4"
if ( $iptype -eq "ipv4") {
    $ipv4interface = Initialize-IntersightCommIpV4Interface -IpAddress "10.10.10.10" -Gateway "10.10.10.1" -Netmask "255.255.255.0"
    $ipconfig = Initialize-IntersightOsIpv4Configuration -IpV4Config $ipv4interface
} elseif ($iptype -eq "ipv6") {
    $ipv6interface = Initialize-IntersightCommIpV6Interface -Gateway "FE80:0A::1" -IpAddress "FE80:0A:10" -Prefix "FE80:0A"
    $ipconfig = Initialize-IntersightOsIpv6Configuration -IpV6Config $ipv6interface
}

$OsAnswers = Initialize-IntersightOsAnswers -Hostname "pwsh-demo" -IpConfigType "static" -IpConfiguration $ipconfig -IsRootPasswordCrypted $false -Nameserver "8.8.8.8" -NetworkDevice "" -RootPassword "password" -Source "Template"
# Network Device where the IP address must be configured. Network Interface names and MAC address are supported.
# Options: None, Embedded, File, Template
# IpConfigType: Options: static, DHCP

# List SCU Repo Names
$OsduImageNames = Get-IntersightfirmwareServerConfigurationUtilityDistributable | Select-Object Name
Write-host "Available SCU Repo Names:"
foreach ($Name in $OsduImageNames.Name) {
    Write-host $Name
}
# Input SCU Repo Name
# $OsduRepoName = "SCU6.23b"
while ($True) {
    $OsduRepoName = Read-Host -Prompt "Enter an SCU Repo Name from the above list"
    if ($OsduRepoName -in $OsduImageNames.Name) {
        Write-Host "SCU Repo Name looks good!" -ForegroundColor Green
        break
    } else {
        Write-Host "Re-Enter SCU Repo Name" -ForegroundColor Red
    }
}
$OsduRepoObj = Get-IntersightfirmwareServerConfigurationUtilityDistributable -Name $OsduRepoName | Get-IntersightMoMoRef

# OS Install target configuration
$target = "vd" # Options: vd, fc, iscsi
if ( $target -eq "vd") {
    $OSInstallTarget = Initialize-IntersightOsVirtualDrive -ClassId "OsVirtualDrive" -ObjectType "OsVirtualDrive" -Id "0" -Name "vD1" -StorageControllerSlotId "1"
} elseif ($target -eq "fc") {
    $OSInstallTarget = Initialize-IntersightOsFibreChannelTarget -ClassId "OsFibreChannelTarget" -ObjectType "OsFibreChannelTarget" -InitiatorWwpn "" -LunId "" -TargetWwpn ""
} elseif ($target -eq "iscsi") {
    $OSInstallTarget = Initialize-IntersightOsIscsiTarget -ClassId "" -ObjectType "" -LunId "" -TargetIqn "" -VnicMac ""
}

New-IntersightOsInstall -Name "PWSH_OS_Install" -Description "PWSH Created OS Install Workflow" -Organization $OrgObj -Server $ServerObj -Image $OSRepoObj -ConfigurationFile $OSConfigFileObj -Answers $OsAnswers -OverrideSecureBoot $false -OsduImage $OsduRepoObj -InstallMethod "vMedia" -InstallTarget $OSInstallTarget
