<#
This is where you would type the input related help information.
.SYNOPSIS
    Acknowledge Intersight Alarms
.DESCRIPTION
    Script to Acknowledge Alarms
    We have three functions defined:
        Invoke-GetAlarmCount - Get Alarm Count based on input parameters
        Invoke-GetAlarms     - Get Alarms based on input parameters
        Invoke-UpdateAlarm   - Update Alarm to Acknowledge state

    # Input Parameters
        $AlarmType     - Options: active, cleared, acked
        $AlarmAckState - Options: Acknowledge, None
        $AlarmTime     - If we want alarms before a certain time
            E.g. Time Format: 'P0Y11M1D': 0 years, 11 Months, 1 Day
            Refer "Duration" section for Time Format: https://intersight.com/apidocs/introduction/query/#supported-types
        $AffectedMoName - Source Name
.LINK
    Be sure to check out more PowerShell code on https://github.com/CiscoDevNet/intersight-powershell-utils

.EXAMPLE

#>

Function Invoke-GetAlarmCount {

    <#
    .SYNOPSIS
        Get Intersight Alarms Count.
    .DESCRIPTION
        Invoke-GetAlarmCount returns the Alarm count
    .NOTES
        This function works on MacOS/Windows running PowerShell 7.3.3 or higher
    .LINK
        Be sure to check out more PowerShell code on https://github.com/CiscoDevNet/intersight-powershell-utils
    .EXAMPLE
        Invoke-GetAlarmCount
        Get Intersight Alarm Count
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$AlarmType = "active",  # Default value, Options: cleared, acked, active
        [Parameter(Mandatory = $false)]
        [string]$Time = "P0Y0M0D",
        [Parameter(Mandatory = $false)]
        [string]$AffectedMoName = ""
    )

    # Create Query Filter based on AlarmType and AffectedMoDisplayName
    if ( $AlarmType -eq "cleared" ) {
        if ($AffectedMoName -ne "") {
            $filter="(Severity eq 'Cleared' and OrigSeverity ne 'Cleared' and Acknowledge eq 'None' and contains(tolower(AffectedMoDisplayName),'$($AffectedMoName)')"
        } else {
            $filter="(Severity eq 'Cleared' and OrigSeverity ne 'Cleared' and Acknowledge eq 'None'"
        }
    } elseif ( $AlarmType -eq "acked" ) {
        if ($AffectedMoName -ne "") {
            $filter="(Severity in ('Critical', 'Warning', 'Info') and Acknowledge eq 'Acknowledge' and contains(tolower(AffectedMoDisplayName),'$($AffectedMoName)')"
        } else {
            $filter="(Severity in ('Critical', 'Warning', 'Info') and Acknowledge eq 'Acknowledge'"
        }
    } elseif ( $AlarmType -eq "active" ) {
        if ($AffectedMoName -ne "") {
            $filter="(Severity in ('Critical', 'Warning', 'Info') and Acknowledge eq 'None' and contains(tolower(AffectedMoDisplayName),'$($AffectedMoName)')"
        } else {
            $filter="(Severity in ('Critical', 'Warning', 'Info') and Acknowledge eq 'None'"
        }
    }

    try {
        # oData Query Filter
        $filter = "$($filter) and CreationTime lt now() sub '$($Time)')"

        # Get Alarm Count
        $Alarms = Get-IntersightCondAlarm -InlineCount 'allpages' -Filter $filter
        return $Alarms.Count
    }
    catch {
        Write-Host "Get Alarm Count operation Failed!"
        Write-Host $_
    }
}

Function Invoke-GetAlarms {

    <#
    .SYNOPSIS
        Get Intersight Alarms.
    .DESCRIPTION
        Invoke-GetAlarms returns the Alarms based on Input Parameters
    .NOTES
        This function works on MacOS/Windows running PowerShell 7.3.3 or higher
    .LINK
        Be sure to check out more PowerShell code on https://github.com/CiscoDevNet/intersight-powershell-utils
    .EXAMPLE
        Invoke-GetAlarms
        Get Intersight Alarms based on Input Parameters
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$AlarmType = "active",
        [Parameter(Mandatory = $false)]
        [int]$top = 100,
        [Parameter(Mandatory = $false)]
        [int]$skip = 0,
        [Parameter(Mandatory = $false)]
        [string]$Time,
        [Parameter(Mandatory = $false)]
        [string]$AffectedMoName = ""
    )

    # Create Query Filter based on AlarmType and AffectedMoDisplayName
    if ( $AlarmType -eq "cleared" ) {
        if ($AffectedMoName -ne "") {
            $filter="(Severity eq 'Cleared' and OrigSeverity ne 'Cleared' and Acknowledge eq 'None' and contains(tolower(AffectedMoDisplayName),'$($AffectedMoName)')"
        } else {
            $filter="(Severity eq 'Cleared' and OrigSeverity ne 'Cleared' and Acknowledge eq 'None'"
        }
    } elseif ( $AlarmType -eq "acked" ) {
        if ($AffectedMoName -ne "") {
            $filter="(Severity in ('Critical', 'Warning', 'Info') and Acknowledge eq 'Acknowledge' and contains(tolower(AffectedMoDisplayName),'$($AffectedMoName)')"
        } else {
            $filter="(Severity in ('Critical', 'Warning', 'Info') and Acknowledge eq 'Acknowledge'"
        }
    } elseif ( $AlarmType -eq "active" ) {
        if ($AffectedMoName -ne "") {
            $filter="(Severity in ('Critical', 'Warning', 'Info') and Acknowledge eq 'None' and contains(tolower(AffectedMoDisplayName),'$($AffectedMoName)')"
        } else {
            $filter="(Severity in ('Critical', 'Warning', 'Info') and Acknowledge eq 'None'"
        }
    }

    try {
        # oData Query filters
        $filter = "$($filter) and CreationTime lt now() sub '$($Time)')"
        $expand = 'RegisteredDevice($select=PlatformType,DeviceHostname,ParentConnection)'
        $orderby = "LastTransitionTime desc"

        # Get Alarms
        $Alarms = Get-IntersightCondAlarm -Top $top -Skip $skip -Filter $filter -Expand $expand -Orderby $orderby | Select-Object -ExpandProperty Results | Select-Object CreationTime,Moid,AffectedMoDisplayName,Code,Description,MsAffectedObject,OrigSeverity #,RegisteredDevice
        return $Alarms
    }
    catch {
        Write-Host "Get Alarms operation Failed!"
        Write-Host $_
    }
}

Function Invoke-UpdateAlarm {

    <#
    .SYNOPSIS
        Update Intersight Alarm.
    .DESCRIPTION
        Invoke-UpdateAlarm updates an Intersight Alarm based on Input Parameters
    .NOTES
        This function works on MacOS/Windows running PowerShell 7.3.3 or higher
    .LINK
        Be sure to check out more PowerShell code on https://github.com/CiscoDevNet/intersight-powershell-utils
    .EXAMPLE
        Invoke-UpdateAlarms -Moid <AlarmMoid> -Acknowledge "Acknowledge"
        Update Intersight Alarm for the provided Moid
    #>

    [CmdletBinding()]
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
        Write-Host $_
    }
}

# Intersight API Configuration
$ApiParams = @{
    BasePath = "https://intersight.com"
    ApiKeyId = Get-Content -Path "/Path/to/ApiKey.txt" -Raw
    ApiKeyFilePath = "/Path/to/SecretKey.txt"
    HttpSigningHeader = @("(request-target)", "Host", "Date", "Digest")
}

Set-IntersightConfiguration @ApiParams

# Input Parameters
$AlarmType = "active" # Options: active, cleared, acked
$AlarmAckState = "Acknowledge" # Options: Acknowledge, None
$AlarmTime = "P0Y0M0D"
$AffectedMoName = "imm-fi-loan"

# Get Alarm Count
$AlarmCount = Invoke-GetAlarmCount -AffectedMoName $AffectedMoName -Time $AlarmTime -AlarmType $AlarmType

# Get Alarms based on Input Parameters
# We are using Pagination($skip, $top) to handle situations when Alarm Count exceeds 1000.
if ($AlarmCount -eq 0) {
    Write-Host "Matching AlarmCount is $($AlarmCount)"
} else {
    $top = 1000
    $pages = [int][Math]::Ceiling($AlarmCount/$top)
    $Alarms = @()
    try {
        for ($i=0; $i -lt $pages; $i++) {
            Write-Host "Get $($AlarmType) Alarms!"
            $Alarms += Invoke-GetAlarms -Time $AlarmTime -top $top -skip ($i*$top) -AffectedMoName $AffectedMoName -AlarmType $AlarmType
        }
    }
    catch {
        Write-Host "Error encountered during Alarm Get Operation!"
        Write-Host $_
    }
}

# Update Alarms
try {
    if ($Alarms) {
        foreach ($Alarm in $Alarms) {
            $Moid = $Alarm.Moid
            Write-Host "Alarm Moid: $($Moid), Update Alarm Ack State to: $($AlarmAckState)"
            Invoke-UpdateAlarm -Moid $Moid -AckState $AlarmAckState | Out-Null
        }
    }
}
catch {
    Write-Host "Error encountered during Alarm Update Operation!"
    Write-Host $_
}
