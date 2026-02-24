param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Start", "Stop", "Status")]
    $Action
)

$rg = "rg-intune-lab"
$vm = "intune-lab-vm"

# Ensure Azure CLI is in path
$env:Path += ";C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin"

switch ($Action) {
    "Start" {
        Write-Host "Starting Lab VM..." -ForegroundColor Green
        az vm start -g $rg -n $vm --no-wait
        Write-Host "VM is starting. It will be ready for RDP in 2-3 minutes."
    }
    "Stop" {
        Write-Host "Deallocating Lab VM (Stopping Billing)..." -ForegroundColor Yellow
        az vm deallocate -g $rg -n $vm --no-wait
        Write-Host "VM is being deallocated. Compute charges have stopped."
    }
    "Status" {
        az vm get-instance-view -g $rg -n $vm --query "instanceView.statuses[1].displayStatus" -o tsv
    }
}
