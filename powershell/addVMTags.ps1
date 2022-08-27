<#
Usecase:
-At present, Intersight doesn't pull vCenter Tags for the VMs under Virtuazliation tab in Intersight.

Steps:
- Connect to vCenter
- Get VM Name, Tags
- Write to tags.json
- Connect to Intersight and update VM tags

Improvments:
-Add error handling
-Add code to handle duplicate VM names under different vCenters
-Add code to keep existing Intersight VM tags. At present, this script will overwrite existing Intersight VM tags.
-Add code to run this againts multiple vCenters
#>

####################################################################
########################## VMware Section ##########################
####################################################################

# Install-Module -Name VMware.PowerCLI
# Import-Module -Name VMware.PowerCLI

# Connect to vCenter
$vcenterIP = "x.x.x.x"
$user = "administrator@vsphere.local"
$password = "password"

Set-PowerCLIConfiguration -InvalidCertificateAction:ignore
# Add try/catch statement
Connect-VIServer $vcenterIP -User $user -Password $password

# Get-Vm | Select-Object Name,@{Name="Tags";Expression={(Get-TagAssignment -Entity $_).Tag}} | Where-Object {$_.Tags} | ConvertTo-Json | Out-File "$($pwd)/tags.json"

# Get all the VM Names
$vmNames = (Get-VM).Name

# Get VM Names with tags
$taggedVMNames = (Get-TagAssignment).Entity.Name | Sort-Object | Get-Unique

# Variable to store output in [{"name": 'vmname', "Tags": [{"Key": "xx", "Value": "yy"}]}]
$jsonData = [System.Collections.ArrayList]@()
foreach ($taggedVM in $taggedVMNames) {
    if ($taggedVM -in $vmNames) {
        $vmData = @{}
        # Add VM Name field in JSON Data
        $vmData["Name"] = $taggedVM

        # Add Tags field in JSON Data
        $vmData["Tags"] = [System.Collections.ArrayList]@()

        # Get all VM Tags
        $tagData = Get-TagAssignment -Entity $taggedVM

        # Get Tag Names
        $vmTagNames = $tagData.Tag.Name

        # Iterate over Tag Names, create a tempTag dict and add to $vmData
        foreach ($vmTagName in $vmTagNames) {
            $tempTag = @{}
            $tempTag["Key"] = $vmTagName
            $tempTag["Value"] = ($tagData.Tag | Where-Object {
                $_.Name -eq $vmTagName
            }).Category.Name
            $vmData["Tags"].Add($tempTag) | Out-Null
        }
        # Add VM Data to the json list
        $jsonData.Add($vmData) | Out-Null
        # Write-Host "VMName: $taggedVM, TagKey: $($vmtags.Tag.Name), TagValue: $($vmtags.Tag.Category.Name)"
    }
}

# Write JsonData to a json file
$jsonData | ConvertTo-Json -Depth 4 | Out-File "$pwd/tags.json"

<#
tags.json sample output:
[
  {
    "Tags": [
      {
        "Key": "vendor",
        "Value": "cisco"
      },
      {
        "Key": "env",
        "Value": "prod"
      }
    ],
    "Name": "vm1"
  },
  {
    "Tags": [
      {
        "Key": "vendor",
        "Value": "cisco"
      },
      {
        "Key": "location",
        "Value": "sj"
      }
    ],
    "Name": "vm2"
  }
]
#>

####################################################################
##################### Cisco Intersight Section #####################
####################################################################

# Install-Module -Name Intersight.PowerShell
# Import-Module -Name Intersight.PowerShell

$ApiParams = @{
    BasePath = "https://intersight.com"
    ApiKeyId = Get-Content -Path ./apiKey.txt -Raw
    ApiKeyFilePath = $pwd.Path + "/SecretKey.txt"
    HttpSigningHeader = @("(request-target)", "Host", "Date", "Digest")
}

Set-IntersightConfiguration @ApiParams

# Update Intersight VM Tags using Tags exported from vCenter
$tagData = Get-Content -Path './tags.json' | ConvertFrom-Json

foreach ($vm in $tagData) {
    # Write-Host "VMName: $($vm.Name)"

    # Get-VM Moid, Add try/catch statement
    $vmMoid = (Get-IntersightVirtualizationVmwareVirtualMachine -Name $vm.Name).Moid

    # Initialize tags
    $tags = [System.Collections.ArrayList]@()
    foreach ($tag in $vm.Tags) {
        $tagObject = Initialize-IntersightMoTag -Key $tag.Key -Value $tag.Value
        $tags.Add($tagObject) | Out-Null
    }

    # Set VM Tags, Add try/catch statement
    Set-IntersightVirtualizationVmwareVirtualMachine -Tags $tags -Moid $vmMoid
}
