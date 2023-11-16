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


# Write to Excel File
# Create a list of Rows for Excel file
$rows = [System.Collections.ArrayList]@()

# Excel Header Fields
$fields = @("DomainName", "ChassisId", "Slot_1", "Slot_2", "Slot_3", "Slot_4", "Slot_5", "Slot_6", "Slot_7", "Slot_8")
$rows.Add($fields) | Out-Null

# Add Data rows to rows list
foreach ($domain in $properties.GetEnumerator()) {
    # Write-Host "$($domain.Name)"
    foreach ($chassis in ($domain.Value).GetEnumerator()) {
        $row = [System.Collections.ArrayList]@()
        $row.Add($domain.Name) | Out-Null
        $row.Add("Chassis_$($chassis.Name)") | Out-Null
        $serverList = $($chassis.Value)
        foreach ($server in 1..8) {
            if ( $serverList -contains $server) {
                $row.Add("Equipped") | Out-Null
            } else {
                $row.Add("Available") | Out-Null
            }
        }
        $rows.Add($row) | Out-Null
    }
}

# Write Rows to a csv file
foreach ($row in $rows) {
    $domain = $row[0]
    $chassis = $row[1]
    $slot_1 = $row[2]
    $slot_2 = $row[3]
    $slot_3 = $row[4]
    $slot_4 = $row[5]
    $slot_5 = $row[6]
    $slot_6 = $row[7]
    $slot_7 = $row[8]
    $slot_8 = $row[9]
    Add-Content "./emptySlots.csv" "$($domain),$($chassis),$($slot_1),$($slot_2),$($slot_3),$($slot_4),$($slot_5),$($slot_6),$($slot_7),$($slot_8)"
}

# Read CSV and Write to xlsx file
$csvdata = Import-Csv "./emptySlots.csv"
Export-Excel -InputObject $csvdata -Path "emptySlots.xlsx" -TableName RawData -WorksheetName RawData

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
            $excel.Workbook.Worksheets[$activeSheet + 1].Cells["$($cell.Address)"].Style.Fill.PatternType = [ExcelFillStyle]::Solid
            $excel.Workbook.Worksheets[$activeSheet + 1].Cells["$($cell.Address)"].Style.Fill.BackgroundColor.SetColor("Yellow")
        }
        if ($cell.Value -eq "Equipped") {
            $excel.Workbook.Worksheets[$activeSheet + 1].Cells["$($cell.Address)"].Style.Fill.PatternType = [ExcelFillStyle]::Solid
            $excel.Workbook.Worksheets[$activeSheet + 1].Cells["$($cell.Address)"].Style.Fill.BackgroundColor.SetColor("White")
        }
    }
}
finally {
    # Close excel file
    Close-ExcelPackage $excel
}
