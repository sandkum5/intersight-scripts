<#
Parse Intersight Har files
Input:
    HarFilename
    Intersight Endpoint URL
        E.g. ntp/Policies, network/ElementSummaries
Output:
    StartedDateTime
    URL
    HTTP Status Code
    X-starship-traceid
#>

$FileName = './intersight_demo1.har'
$UrlMatch = ".*network/ElementSummaries.*"

$hardata = Get-Content -Path $FileName | ConvertFrom-Json
$data = $hardata.log.entries | Where-Object {$_.request.url -match $UrlMatch}

foreach ($url in $data) {
    Write-Host "StartedDateTime   : " $url.startedDateTime
    Write-Host "URL               : " $url.request.url
    Write-Host "HTTP Status       : " $url.response.status
    foreach ($header in $url.response.headers) {
        if ($header.name -eq 'x-starship-traceid') {
            Write-Host "X-starship-traceid: " $header.value
        }
    }
    Write-Host ""
}
