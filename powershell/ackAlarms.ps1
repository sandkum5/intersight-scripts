# Script to Acknowledge or UnAcknowledge an Alarm
# Time Format: 'P0Y11M1D': 0 years, 11 Months, 1 Day

<#
This is where you would type the input-related help information.
.SYNOPSIS

.DESCRIPTION

.PARAMETER

.EXAMPLE

#>

Function Invoke-GetAlarmCount {
    [CmdletBinding()]
    [OutputType()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$AlarmType,
        [Parameter(Mandatory = $false)]
        [string]$Time,
        [Parameter(Mandatory = $true)]
        [string]$AffectedMoName
    )

    if ( $AlarmType -eq "cleared" ) {
        $filter="(Severity eq 'Cleared' and OrigSeverity ne 'Cleared' and Acknowledge eq 'None'"
    } elseif ( $AlarmType -eq "acked" ) {
        $filter="(Severity in ('Critical', 'Warning', 'Info') and Acknowledge eq 'Acknowledge'"
    } elseif ( $AlarmType -eq "active" ) {
        $filter="(Severity in ('Critical', 'Warning', 'Info') and Acknowledge eq 'None' and contains(tolower(AffectedMoDisplayName),'$($AffectedMoName)')"
    }

    try {
        $Alarms = Get-IntersightCondAlarm -InlineCount 'allpages' -Filter "$($filter) and CreationTime lt now() sub '$($Time)')"
        return $Alarms.Count
    }
    catch {
        Write-Host "Get Alarm Count operation Failed!"
    }
}

Function Invoke-GetAlarms {
    [CmdletBinding()]
    [OutputType()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$AlarmType,
        [Parameter(Mandatory = $false)]
        [int]$top = 100,
        [Parameter(Mandatory = $false)]
        [int]$skip = 0,
        [Parameter(Mandatory = $false)]
        [string]$Time,
        [Parameter(Mandatory = $true)]
        [string]$AffectedMoName
    )

    if ( $AlarmType -eq "cleared" ) {
        $filter="(Severity eq 'Cleared' and OrigSeverity ne 'Cleared' and Acknowledge eq 'None'"
    } elseif ( $AlarmType -eq "acked" ) {
        $filter="(Severity in ('Critical', 'Warning', 'Info') and Acknowledge eq 'Acknowledge'"
    } elseif ( $AlarmType -eq "active" ) {
        $filter="(Severity in ('Critical', 'Warning', 'Info') and Acknowledge eq 'None' and contains(tolower(AffectedMoDisplayName),'$($AffectedMoName)')"
    }

    try {
        $Alarms = Get-IntersightCondAlarm -Top $top -Skip $skip -Filter "$($filter) and CreationTime lt now() sub '$($Time)')" -Expand 'RegisteredDevice($select=PlatformType,DeviceHostname,ParentConnection)' -Orderby "LastTransitionTime desc" | Select-Object -ExpandProperty Results | Select-Object CreationTime,Moid,AffectedMoDisplayName,Code,Description,MsAffectedObject,OrigSeverity #,RegisteredDevice
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

$AlarmType = "acked" # Options: active, cleared, acked
$AlarmAckState = "None" # Options: Acknowledge, None
$AlarmTime = "P0Y0M0D"
$AffectedMoName = "imm-fi-loan"

$AlarmCount = Invoke-GetAlarmCount -AffectedMoName $AffectedMoName -Time $AlarmTime -AlarmType $AlarmType

$top = 2
$skip = 0
$Alarms = @()
for ($i=0; $i -lt $AlarmCount/$top; $i++) {
    $Alarms += Invoke-GetAlarms -Time $AlarmTime -top $top -skip $skip -AffectedMoName $AffectedMoName -AlarmType $AlarmType
    $skip += $top
}

if ($Alarms) {
    foreach ($Alarm in $Alarms) {
        $Moid = $Alarm.Moid
        Write-Host "Working on Alarm Moid: " $Moid
        Invoke-UpdateAlarm -Moid $Moid -AckState $AlarmAckState | Out-Null
    }
}
