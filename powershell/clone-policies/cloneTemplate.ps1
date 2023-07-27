<#
    Derive Profile from Template
#>
Function Invoke-CloneSPTemplate {
    Param (
        # Variables
        $OrgName,
        $NewOrgName,
        $SPTemplateName,
        $NewSPTemplateName
    )
    # Get Orgs
    $OrgObj = Get-IntersightOrganizationOrganization -Name $OrgName | Get-IntersightMoMoRef
    $NewOrgObj = Get-IntersightOrganizationOrganization -Name $NewOrgName | Get-IntersightMoMoRef

    # Get Server Profile Template
    $SPTemplate = Get-IntersightServerProfileTemplate -Name $SPTemplateName -Organization $OrgObj
    $NewSPTemplate = Get-IntersightServerProfileTemplate -Name $NewSPTemplateName -Organization $NewOrgObj

    if ($NewSPTemplate) {
        Write-Host "ServerProfile Template $NewSPTemplateName, Moid: $($NewSPTemplate.Moid) already exits under Org: $NewOrgName" -ForegroundColor Green
        return $NewSPTemplate
    } else {
        $SPTemplateSrc = Initialize-IntersightMoBaseMo -ClassId "ServerProfileTemplate" -ObjectType "ServerProfileTemplate" -Moid $SPTemplate.Moid

        $NewSPTemplateTarget = Initialize-IntersightServerProfileTemplate -Name $NewSPTemplateName -Organization $NewOrgObj

        New-IntersightBulkMoCloner -Sources $SPTemplateSrc -Targets $NewSPTemplateTarget -Organization $NewOrgObj

        $NewSPTemplate = Get-IntersightServerProfileTemplate -Name $NewSPTemplateName -Organization $NewOrgObj

        if ($NewSPTemplate) {
            Write-Host "ServerProfile Template $NewSPTemplateName, Moid: $($NewSPTemplate.Moid) created under Org: $NewOrgName" -ForegroundColor Yellow
            return $NewSPTemplate
        }
    }
}
