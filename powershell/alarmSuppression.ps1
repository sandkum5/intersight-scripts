<#
    Script to Start/Stop Alarm Suppression for a Server Serial

    Input: ServerSerial, SuppressDescription
#>

# Intersight Configuration
$ApiParams = @{
    BasePath = "https://intersight.com"
    ApiKeyId = Get-Content -Path "/Path/to/ApiKey.txt" -Raw                 # Update
    ApiKeyFilePath = "/Path/to/SecretKey.txt"                               # Update
    HttpSigningHeader = @("(request-target)", "Host", "Date", "Digest")
}

Set-IntersightConfiguration @ApiParams


# Get Server Info
$ServerSerial = "xxxxxxxxxxx"        # Update
$SuppressDescription = "PWSH_Demo"   # Update
$Server = (Get-IntersightComputePhysicalSummary -Filter "Serial eq '$ServerSerial'").Results

# Get Server Object
if ($Server.SourceObjectType -eq 'compute.RackUnit') {
    $EntityRef = (Get-IntersightComputeRackUnit  -Filter "Serial eq '$ServerSerial'").Results | Get-IntersightMoMoRef
}
if ($Server.SourceObjectType -eq 'compute.Blade') {
    $EntityRef = (Get-IntersightComputeRackUnit  -Filter "Serial eq '$ServerSerial'").Results | Get-IntersightMoMoRef
}

# Get Alarm Suppression Classification Object
$ClassificationRef = (Get-IntersightCondAlarmClassification -Select Name -Filter "Name eq 'DefaultServerMaintenance'").Results | Get-IntersightMoMoRef

# Enable Fault Suppression
New-IntersightCondAlarmSuppression -Classifications $ClassificationRef -Description $SuppressDescription -Entity $EntityRef


# Stop Alarm Suppression for the provided description
(Get-IntersightCondAlarmSuppression -Filter "Description eq '$($SuppressDescription)'").Results | Remove-IntersightCondAlarmSuppression
