<#
.SYNOPSIS
    Parse Intersight HAR Files
.DESCRIPTION
    Script to parse Intersight HAR Files
    Input:
        FileName - HAR File
        URL Path - Options:
            Paths - To print Intersight Endpoints/paths available in HAR file. This will print info for the specific path
            Quit  - To exit script
            Enter - Press Enter Key to print all the Endpoints/paths info available in HAR file
    Output:
        StartedDateTime
        URL
        HTTP Status
        X-starship-traceid
.LINK
    Be sure to check out more PowerShell code on https://github.com/CiscoDevNet/intersight-powershell-utils

.EXAMPLE

#>

Clear-Host
$FileName = './intersight.har'
$HarData = Get-Content -Path $FileName | ConvertFrom-Json

# $URL = ".*network/ElementSummaries.*"

$apiv1 = $HarData.log.entries.request.url | Where-Object {$_ -match 'api/v1'}
$pathList = New-Object System.Collections.ArrayList
foreach ($url in $apiv1) {
    $path, $null = $url -split "\?"
    $null, $subpath = $path -split "v1/"
    $pathList.Add($subpath) | Out-Null
    # Write-Host $subpath
}
Write-Host "Available Paths: "
$pathList | Select-Object -Unique
Write-Host ""
$continue = $true
while ($continue){
    $URL = Read-Host -Prompt "Enter Intersight URL Path: (To Exit, type: Quit, To Print all the Intersight paths info, press Enter Key, To print only the Paths, type: Paths)"
    if ($URL -eq "Quit") {
        Write-Host "Ending Har Parsing!"
        $continue = $false
        break
    }
    elseif ($URL -eq "Paths") {
        Write-Host "Available Paths: "
        $pathList | Select-Object -Unique
    }
    else {
        $Data = $HarData.log.entries | Where-Object {$_.request.url -match $URL}

        foreach ($Url in $Data) {
            Write-Host "StartedDateTime   : " $Url.startedDateTime
            Write-Host "URL               : " $Url.request.url
            Write-Host "HTTP Status       : " $Url.response.status
            foreach ($Header in $Url.response.headers) {
                if ($Header.name -eq 'x-starship-traceid') {
                    Write-Host "X-starship-traceid: " $Header.value
                }
            }
            Write-Host ""
        }
    }
}
