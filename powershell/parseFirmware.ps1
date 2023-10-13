<#
    Parse Firmware Info from Inventory.json file generated using script getServerInventory.ps1
    Output Format:
        Server, Type, Component, Version, Dn
#>
$jsonObj = Get-Content "./inventory.json" -Raw | ConvertFrom-Json

$firstobject = $true
$jsonObj.PSObject.Properties | ForEach-Object {
    $Data = $_.Value.FirmwareRunningFirmware
    $array = @()
    foreach ($i in $Data) {
        $info = [PSCustomObject]@{
            "Server"    = $_.Name
            "Type"      = $i.Type
            "Component" = $i.Component
            "Version"   = $i.Version
            "Dn"        = $i.Dn
        }
        $array += $info
    }
    if ($firstobject) {
        $array | ConvertTo-Csv | Out-File "./Firmware.csv" -Append
        $firstobject = $false
    }
    else {
        $array | ConvertTo-Csv | Select-Object -Skip 1 | Out-File "./Firmware.csv" -Append
    }
}
