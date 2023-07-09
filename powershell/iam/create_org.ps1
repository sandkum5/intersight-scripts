# Sample Script to Create Intersight Organization

# Get Resource Groups
$RGList = [System.Collections.ArrayList]@()
$rg1 = Get-IntersightResourceGroup -Name 'prod-rg' | Get-IntersightMoMoRef
$rg2 = Get-IntersightResourceGroup -Name 'demo-rg1' | Get-IntersightMoMoRef
$RGList.Add($rg1) | Out-Null
$RGList.Add($rg2) | Out-Null

# Create Organization
$newOrg = New-IntersightOrganizationOrganization -Name "pwsh_org1" -Description "Org Created using PowerShell" -ResourceGroups $RGList
Write-Host "$($newOrg.Name) Created Successfully!" -ForegroundColor Green
