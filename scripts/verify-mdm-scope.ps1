# Helper to verify if Juan Perez is in the Intune Enrollment Scope
Connect-MgGraph -Scopes "Group.Read.All", "User.Read.All"

$targetUser = "jperez@cloudcompassconsulting.onmicrosoft.com"
$user = Get-MgUser -UserId $targetUser

if ($null -eq $user) {
    Write-Error "User $targetUser not found. Run setup-graph-user.ps1 first."
    return
}

Write-Host "Verifying groups for Juan Perez ($($user.Id))..." -ForegroundColor Cyan
$groups = Get-MgUserMemberOf -UserId $user.Id

foreach ($group in $groups) {
    # This lists the groups Juan is in. 
    # Compare these names to the group you selected in the "Mobility" portal.
    Write-Host "- Group: $($group.AdditionalProperties.displayName)" -ForegroundColor Green
}

Write-Host "`nNote: If MDM User Scope is set to 'All' in the Portal, Juan is already covered." -ForegroundColor Yellow
