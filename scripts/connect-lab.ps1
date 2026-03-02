# Secure connection script for Intune Lab VM
$vmIp = "13.72.72.42"
$username = "azureuser"
$rg = "rg-intune-lab"
$vmName = "intune-lab-vm"

# 1. Generate a new secure password
$newPassword = -join ((65..90) + (97..122) + (48..57) + (33,35,36,37,38) | Get-Random -Count 16 | ForEach-Object {[char]$_})

Write-Host "Resetting password for $username on $vmName..." -ForegroundColor Cyan
az vm user update --resource-group $rg --name $vmName --user $username --password $newPassword

if ($LASTEXITCODE -eq 0) {
    Write-Host "Password reset successful." -ForegroundColor Green
    
    # 2. Store credentials in Windows Credential Manager
    Write-Host "Storing credentials in Windows Credential Manager..." -ForegroundColor Cyan
    cmdkey /add:$vmIp /user:$username /pass:$newPassword
    
    # 3. Launch RDP
    Write-Host "Launching RDP connection to $vmIp..." -ForegroundColor Green
    mstsc /v:$vmIp
    
    Write-Host "`nYour new password is: $newPassword" -ForegroundColor Yellow
    Write-Host "Keep this password safe if you need to log in from another device." -ForegroundColor Yellow
} else {
    Write-Error "Failed to reset VM password. Ensure the VM is running."
}
