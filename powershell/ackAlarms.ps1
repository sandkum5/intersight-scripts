# Script to Acknowledge or UnAcknowledge an Alarm
# Time Format: 'P0Y11M1D': 0 years, 11 Months, 1 Day

<#
This is where you would type the input related help information.
.SYNOPSIS

.DESCRIPTION

.PARAMETER

.EXAMPLE

#>

Function Invoke-GetAlarms {
    [CmdletBinding()]
    [OutputType()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$type = "active",
        [Parameter(Mandatory = $false)]
        [int]$top = 100,
        [Parameter(Mandatory = $false)]
        [int]$skip = 0,
        [Parameter(Mandatory = $false)]
        [string]$Time = "P0Y0M0D"
    )

    if ( $type -eq "cleared" ) {
        $filter="(Severity eq 'Cleared' and OrigSeverity ne 'Cleared' and Acknowledge eq 'None'"
    } elseif ( $type -eq "acked" ) {
        $filter="(Severity in ('Critical', 'Warning', 'Info') and Acknowledge eq 'Acknowledge'"
    } elseif ( $type -eq "active" ) {
        $filter="(Severity in ('Critical', 'Warning', 'Info') and Acknowledge eq 'None'"
    }

    try {
        $Alarms = Get-IntersightCondAlarm -Top $top -Skip $skip -Filter "$($filter) and CreationTime lt now() sub '$($Time)')" -Expand 'RegisteredDevice($select=PlatformType,DeviceHostname,ParentConnection)' -Orderby "LastTransitionTime desc" | Select-Object -ExpandProperty Results | Select-Object CreationTime,Moid,Code,Description,MsAffectedObject,OrigSeverity
        return $Alarms
    }
    catch {
        Write-Host "Get Alarms operation Failed!"
    }
}

Function Invoke-UpdateAlarm {
    [CmdletBinding()]
    [OutputType()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Moid,
        [Parameter(Mandatory = $false)]
        [string]$AckState = "Acknowledge"
    )
    try {
        Set-IntersightCondAlarm -Moid $Moid -Acknowledge $AckState | Out-Null
    }
    catch {
        Write-Host "Error Encountered while Setting Alarm Acknowledge State!"
    }
}


$ApiParams = @{
    BasePath = "https://intersight.com"
    ApiKeyId = Get-Content -Path "/Path/to/ApiKey.txt" -Raw
    ApiKeyFilePath = "/Path/to/SecretKey.txt"
    HttpSigningHeader = @("(request-target)", "Host", "Date", "Digest")
}

Set-IntersightConfiguration @ApiParams

$AlarmCount = (Get-IntersightCondAlarm -Count $true).Count

$top = 1000
$skip = 0
for ($i=0; $i -lt $AlarmCount/$top; $i++) {
    $Alarms = Invoke-GetAlarms -Time 'P1Y7M1D' -top $top -skip $skip
    foreach ($Alarm in $Alarms) {
        Write-Host $Alarm
        Invoke-UpdateAlarm -Moid $Alarm.Moid -AckState "Acknowledge" | Out-Null
    }
    $skip += $top
}
