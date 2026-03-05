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
    Write-Host "Network Protection has been successfully enabled." -ForegroundColor Green
}
