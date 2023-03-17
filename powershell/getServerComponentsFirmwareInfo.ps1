<#
    Script to pull Server Component Firmware Info and export to Excel
#>

$ApiParams = @{
    BasePath = "https://intersight.com"
    ApiKeyId = Get-Content -Path ./apiKey.txt -Raw
    ApiKeyFilePath = $pwd.Path + "/SecretKey.txt"
    HttpSigningHeader = @("(request-target)", "Host", "Date", "Digest")
}

Set-IntersightConfiguration @ApiParams

$moids = Get-IntersightComputePhysicalSummary | Select-Object Moid

$firstobject = $true

foreach ($moid in $moids.Moid) {
    # Get Server Info
    $firmwareInfo = New-Object PSObject
    Write-Host "Adding Server" -ForegroundColor Red
    $serverInfo = Get-IntersightComputePhysicalSummary -Moid $moid | Select-Object Name,Model,Serial,Firmware

    $firmwareInfo | Add-Member -NotePropertyName "Server Name" -NotePropertyValue $serverInfo.Name
    $firmwareInfo | Add-Member -NotePropertyName "Model" -NotePropertyValue $serverInfo.Model
    $firmwareInfo | Add-Member -NotePropertyName "Serial" -NotePropertyValue $serverInfo.Serial
    $firmwareInfo | Add-Member -NotePropertyName "Firmware" -NotePropertyValue $serverInfo.Firmware
    Write-Host "Name: $($serverInfo.Name), Model: $($serverInfo.Model), Serial: $($serverInfo.Serial), Firmware: $($serverInfo.Firmware)"

    $firmwareMoids = (Get-IntersightSearchSearchItem -Filter "Ancestors/any(t:t/Moid eq `'$moid`') and ObjectType eq 'firmware.RunningFirmware'").Results.Moid
    $array = @()

    $i = $true
    foreach ($firmwareMoid in $firmwareMoids) {
        if($i)
        {
            $componentInfo = $firmwareInfo.PsObject.Copy()
            $i = $false
        }
        else
        {
            $componentInfo = New-Object PSObject
        }
        $componentFirmware = Get-IntersightFirmwareRunningFirmware -Moid $firmwareMoid | Select-Object Dn,_Version,Type,Component
        $componentInfo | Add-Member -NotePropertyName "Component DN" -NotePropertyValue $componentFirmware.Dn
        $componentInfo | Add-Member -NotePropertyName "Component Version" -NotePropertyValue $componentFirmware._Version
        $componentInfo | Add-Member -NotePropertyName "Component Type" -NotePropertyValue $componentFirmware.Type
        $componentInfo | Add-Member -NotePropertyName "Component" -NotePropertyValue $componentFirmware.Component
        $array += $componentInfo
    }
    if($firstobject)
    {
        $array | ConvertTo-Csv | Out-File "./FirmwareInfo.csv" -Append
        $firstobject = $false
    }
    else
    {
        $array | ConvertTo-Csv | Select-object -Skip 1 | Out-File "./FirmwareInfo.csv" -Append
    }
}
