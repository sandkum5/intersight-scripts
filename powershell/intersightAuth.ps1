<#
    Intersight Authentication
        Intersight Environment configuration before Intersight Cmdlets can be used.

    Inputs:
        ApiKeyId            : Add ApiKey.txt file path
        ApiKeyFilePath      : Add SecretKey.txt file path
        SkipCertificateCheck: Options: $false, $true. Set to $true if using PVA/CVA

        If the API Keys are in same director as the script, following can be used:
            ApiKeyId = Get-Content -Path "$($pwd.Path)/ApiKey.txt" -Raw
            ApiKeyFilePath = "$($pwd.Path)/SecretKey.txt"

        If the API Keys are in a different directory:
            Mac/Linux:
                ApiKeyId = "/Path/to/ApiKey.txt" or "<api_key_id_value>"
                ApiKeyFilePath = "/Path/to/SecretKey.txt"
            Windows:
                ApiKeyId = "c:\Path\to\ApiKey.txt" or "<api_key_id_value>"
                ApiKeyFilePath = "c:\Path\to\SecretKey.txt"

#>

$ApiParams = @{
    BasePath             = "https://intersight.com"
    ApiKeyId             = Get-Content -Path "/Path/To/ApiKey.txt" -Raw
    ApiKeyFilePath       = "/Path/To/SecretKey.txt"
    HttpSigningHeader    = @("(request-target)", "Host", "Date", "Digest")
    SkipCertificateCheck = $false   # Enable for PVA/CVA
}

Set-IntersightConfiguration @ApiParams
