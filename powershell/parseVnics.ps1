<#
    Parse Network Adapter vNIC/FC/External Interface Info from Inventory.json file created using getServerInventory.ps1 script.
    Output Format:
        Server, Name, MAC, Dn, fcWwpn, fcWwnn, fcVifId, extInterfaceId
#>
$jsonObj = Get-Content "./inventory.json" -Raw | ConvertFrom-Json

$firstobject = $true
$jsonObj.PSObject.Properties | ForEach-Object {
    $Data = $_.Value.Specs
    $array = @()
    foreach ($i in $Data.AdapterHostEthInterface) {
        $eth = [PSCustomObject]@{
            "Server"         = $_.Name
            "Name"           = $i.Name
            "MAC"            = $i.MacAddress
            "Dn"             = $i.Dn
            "fcWwpn"         = ""
            "fcWwnn"         = ""
            "fcVifId"        = ""
            "extInterfaceId" = ""
        }
        $array += $eth
    }
    foreach ($i in $Data.AdapterHostFcInterface) {
        $fc = [PSCustomObject]@{
            "Server"         = $_.Name
            "Name"           = $i.Name
            "MAC"            = ""
            "Dn"             = $i.Dn
            "fcWwpn"         = $i.Wwpn
            "fcWwnn"         = $i.Wwnn
            "fcVifId"        = $i.VifId
            "extInterfaceId" = ""
        }
        $array += $fc
    }
    foreach ($i in $Data.AdapterExtEthInterface) {
        $ext = [PSCustomObject]@{
            "Server"         = $_.Name
            "Name"           = $i.InterfaceType
            "MAC"            = $i.MacAddress
            "Dn"             = $i.Dn
            "fcWwpn"         = ""
            "fcWwnn"         = ""
            "fcVifId"        = ""
            "extInterfaceId" = $i.ExtEthInterfaceId
        }
        $array += $ext
    }
    if ($firstobject) {
        $array | ConvertTo-Csv | Out-File "./vnics.csv" -Append
        $firstobject = $false
    } else {
        $array | ConvertTo-Csv | Select-Object -Skip 1 | Out-File "./vnics.csv" -Append
    }
}
