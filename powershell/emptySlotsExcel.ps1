<#
    Print Empty Slots in UCSM Domains connected to Intersight
    Prints all or Domain Specific Output
    Install Module ImportExcel:
        Cmd: Install-Module -Name ImportExcel
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

$myObj = [System.Collections.ArrayList]@()
foreach ($server in $serverNames) {
    $x = $Server.Name | Select-String -Pattern "^(.+)-(\d+)-(\d)"
    $DomainName = $x.Matches.Groups[1].Value
    $ChassisId = $x.Matches.Groups[2].Value
    $ServerId = $x.Matches.Groups[3].Value

    $serverObj = [PSCustomObject]@{
        "Domain" = $DomainName
        "Chassis" = "Chassis_$($ChassisId)"
        "Slot" = "Slot_$($ServerId)"
    }
    $myObj += $serverObj
}

$mycustomObj = [System.Collections.ArrayList]@()
$myDomains = $myObj.Domain | Sort-Object -Unique
foreach ($domain in $myDomains) {
    $domainInfo = $myObj | Where-Object {$_.Domain -eq $domain}
    $chassisNames = $domainInfo.Chassis | Sort-Object -Unique
    foreach ($chassis in $chassisNames) {
        $chassisInfo = $domainInfo | Where-Object {$_.Chassis -eq $chassis}
        $equippedSlots = $ChassisInfo.Slot | Sort-Object
        $slotDict = @{}
        foreach ($slot in ('Slot_1', 'Slot_2', 'Slot_3', 'Slot_4', 'Slot_5', 'Slot_6', 'Slot_7', 'Slot_8')){
            if ($slot -in $equippedSlots){
                $slotDict.Add($slot, "Equipped")
            } else {
                $slotDict.Add($slot,"Available")
            }
        }
        $domainObj = [pscustomobject]@{
            "Domain" = $domain
            "Chassis" = $chassis
            "Slot_1" = $slotDict.Slot_1
            "Slot_2" = $slotDict.Slot_2
            "Slot_3" = $slotDict.Slot_3
            "Slot_4" = $slotDict.Slot_4
            "Slot_5" = $slotDict.Slot_5
            "Slot_6" = $slotDict.Slot_6
            "Slot_7" = $slotDict.Slot_7
            "Slot_8" = $slotDict.Slot_8
        }
        $mycustomObj += $domainObj
    }
}

# Write to csv
# $mycustomObj | Export-Csv 'emptySlots.csv'

# Write to xlsx file
Export-Excel -InputObject $mycustomObj -Path "emptySlots.xlsx" -TableName RawData -WorksheetName RawData

# Update xlsx with color coding Empty Slots
try {
    # Import the module
    Import-Module ImportExcel

    # Open excel file
    $excel = Open-ExcelPackage -Path "./emptySlots.xlsx"

    # Get Active worksheet
    $activeSheet = $excel.Workbook.View.ActiveTab

    # Set cell's background color
    foreach ($cell in $excel.Workbook.Worksheets[$activeSheet + 1].Cells.GetEnumerator()) {
        if ($cell.Value -eq "Available") {
            $excel.Workbook.Worksheets[$activeSheet + 1].Cells["$($cell.Address)"].Style.Fill.PatternType = [OfficeOpenXml.Style.ExcelFillStyle]::Solid
            $excel.Workbook.Worksheets[$activeSheet + 1].Cells["$($cell.Address)"].Style.Fill.BackgroundColor.SetColor("Yellow")
        }
        if ($cell.Value -eq "Equipped") {
            $excel.Workbook.Worksheets[$activeSheet + 1].Cells["$($cell.Address)"].Style.Fill.PatternType = [OfficeOpenXml.Style.ExcelFillStyle]::Solid
            # $excel.Workbook.Worksheets[$activeSheet + 1].Cells["$($cell.Address)"].Style.Fill.PatternType = [ExcelFillStyle]::Solid
            $excel.Workbook.Worksheets[$activeSheet + 1].Cells["$($cell.Address)"].Style.Fill.BackgroundColor.SetColor("White")
        }
    }
}
finally {
    # Close excel file
    Close-ExcelPackage $excel
}
