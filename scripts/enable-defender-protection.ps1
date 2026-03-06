# PowerShell script to enable Microsoft Defender Network Protection
# This enforces web blocks at the OS level across all browsers (Chrome, Firefox, Edge)

Write-Host "Checking current Microsoft Defender Network Protection status..." -ForegroundColor Cyan
$status = Get-MpPreference | Select-Object -ExpandProperty EnableNetworkProtection

if ($status -eq 1) {
    Write-Host "Network Protection is already Enabled." -ForegroundColor Green
} else {
    Write-Host "Enabling Network Protection (Block mode)..." -ForegroundColor Yellow
    # 0 = Disabled, 1 = Enabled (Block), 2 = Audit Mode
    Set-MpPreference -EnableNetworkProtection Enabled
    
    # Disable Secure DNS (DoH) to ensure Defender can inspect DNS traffic
    Write-Host "Disabling Secure DNS (DoH) at the OS level..." -ForegroundColor Yellow
    if (-not (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" -Force
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" -Name "EnableAutoDoh" -Value 0
    
    Write-Host "Network Protection and DNS Policy have been successfully updated." -ForegroundColor Green
}
