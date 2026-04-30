param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Start", "Stop", "Status")]
    $Action
)

# --- CONFIGURATION ---
$rg = "rg-intune-lab"
$prefix = "intune-lab"
$vmName = "$prefix-vm"
$nicName = "$prefix-nic"
$pipName = "$prefix-pip"
$location = "eastus" 
$localEnvPath = "./scripts/local-env.ps1" # Corrected path to scripts folder

# Ensure Azure CLI is in path for this session
$env:Path += ";C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin"

function Get-OSDiskName {
    return az vm show -g $rg -n $vmName --query "storageProfile.osDisk.name" -o tsv
}

switch ($Action) {
    "Start" {
        Write-Host "--- Restoring Lab Environment ---" -ForegroundColor Cyan     
        
        # 1. Create/Restore Public IP
        Write-Host "Recreating Public IP..."
        az network public-ip create -g $rg -n $pipName --sku Standard --allocation-method Static -l $location --output none

        # 2. Re-attach to NIC
        Write-Host "Attaching IP to NIC..."
        az network nic ip-config update -g $rg --nic-name $nicName --name "ipconfig1" --public-ip-address $pipName --output none

        # 3. Upgrade Disk for work performance
        $osDiskName = Get-OSDiskName
        Write-Host "Upgrading Disk ($osDiskName) to Premium SSD..."
        az disk update -g $rg -n $osDiskName --sku Premium_LRS --output none     

        # 4. Start VM
        Write-Host "Starting VM..." -ForegroundColor Green
        az vm start -g $rg -n $vmName --no-wait

        # 5. Update local-env.ps1 with the new IP
        $newIp = az network public-ip show -g $rg -n $pipName --query "ipAddress" -o tsv
        if (Test-Path $localEnvPath) {
            $content = Get-Content $localEnvPath
            $newContent = $content -replace 'VmIp\s+=\s+".*"', "VmIp          = `"$newIp`""
            $newContent | Set-Content $localEnvPath
            Write-Host "Updated $localEnvPath with new IP: $newIp" -ForegroundColor Yellow
        }
    }

    "Stop" {
        Write-Host "--- Entering Cold Storage (Cost Saving Mode) ---" -ForegroundColor Cyan
        
        # 1. Deallocate (Stops Compute billing)
        Write-Host "Deallocating VM..."
        az vm deallocate -g $rg -n $vmName

        # 2. Downgrade Disk to Standard HDD (Lowest storage cost)
        $osDiskName = Get-OSDiskName
        Write-Host "Downgrading Disk ($osDiskName) to Standard HDD..."
        az disk update -g $rg -n $osDiskName --sku Standard_LRS --output none    

        # 3. Detach and Delete Public IP (Stops IP reservation billing)
        Write-Host "Removing and Deleting Public IP..."
        az network nic ip-config update -g $rg --nic-name $nicName --name "ipconfig1" --public-ip-address null --output none
        az network public-ip delete -g $rg -n $pipName --output none

        Write-Host "Lab is now costing near $0.00/hour." -ForegroundColor Green  
    }

    "Status" {
        $status = az vm get-instance-view -g $rg -n $vmName --query "instanceView.statuses[1].displayStatus" -o tsv
        $osDiskName = Get-OSDiskName
        $tier = az disk show -g $rg -n $osDiskName --query "sku.name" -o tsv     
        Write-Host "VM Status: $status | Disk Tier: $tier"
    }
}
