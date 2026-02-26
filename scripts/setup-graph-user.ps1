# Microsoft Graph PowerShell script to setup a new user and assign licenses
# Prerequisite: Install-Module Microsoft.Graph

# 1. Authentication Configuration
$tenantId = "cloudcompassconsulting.onmicrosoft.com"
$adminUpn = "cloudcompassconsulting@cloudcompassconsulting.onmicrosoft.com"
# Note: Interactive login is recommended for the first time to grant permissions.
# To automate, consider using a Service Principal with a Certificate.

Write-Host "Authenticating to Microsoft Graph..." -ForegroundColor Cyan
# This will open a browser window for login
Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All", "Organization.Read.All", "Subscription.Read.All"

# 2. User Configuration
$userParams = @{
    DisplayName = "Juan Perez"
    GivenName = "Juan"
    Surname = "Perez"
    UserPrincipalName = "jperez@cloudcompassconsulting.onmicrosoft.com"
    MailNickname = "jperez"
    UsageLocation = "US" # Required for license assignment
    AccountEnabled = $true
    PasswordProfile = @{
        ForceChangePasswordNextSignIn = $true
        Password = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 12 | ForEach-Object {[char]$_})
    }
}

Write-Host "Creating user: $($userParams.UserPrincipalName)..." -ForegroundColor Cyan
try {
    $newUser = New-MgUser @userParams
    Write-Host "User created successfully!" -ForegroundColor Green
    Write-Host "Temporary Password: $($userParams.PasswordProfile.Password)" -ForegroundColor Yellow
} catch {
    Write-Error "Failed to create user: $_"
    return
}

# 3. License Assignment (Microsoft 365 Business Premium)
Write-Host "Finding Microsoft 365 Business Premium License..." -ForegroundColor Cyan
# 'SPB' is the SkuPartNumber for Microsoft 365 Business Premium
$sku = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "SPB" -or $_.SkuPartNumber -contains "BUSINESS_PREMIUM" }

if ($null -eq $sku) {
    Write-Warning "Could not find Business Premium license. Listing available SKUs:"
    Get-MgSubscribedSku | Select-Object SkuPartNumber, SkuId
    return
}

Write-Host "Assigning license ($($sku.SkuPartNumber))..." -ForegroundColor Cyan
$licenseAdd = @{
    AddLicenses = @(
        @{ SkuId = $sku.SkuId }
    )
    RemoveLicenses = @()
}

Set-MgUserLicense -UserId $newUser.Id -BodyParameter $licenseAdd
Write-Host "License assigned successfully to Juan Perez!" -ForegroundColor Green
