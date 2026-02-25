# Project Status: Azure Intune Lab

## Current State (as of 2026-02-24)

### 1. Azure Configuration
- **Status:** [ACTIVE]
- **Resource Group:** `rg-intune-lab` (East US)
- **Budget:** `save` - $100.00 Monthly Cap [SET]
- **Resource Providers:** Network, Compute, and Storage [REGISTERED]

### 2. Infrastructure (Bicep)
- **VM Name:** `intune-lab-vm`
- **VM Size:** `Standard_D2s_v3` (Note: B-series currently unavailable in eastus)
- **Storage:** `StandardSSD_LRS` (Cost Optimized)
- **Networking:** Standard SKU Public IP (IP: `13.72.72.42`)
- **Auto-Shutdown:** Daily at 19:00 UTC [ACTIVE]

### 3. Operational Status
- **Power State:** [DEALLOCATED] (Billing for compute is paused)
- **Management Script:** `scripts/manage-lab.ps1` (Start/Stop/Status)
- **Entra ID Status:** Device `intune-lab-vm` is successfully Entra Joined.

## GitHub & Secrets
- **Repository:** `https://github.com/LuciaCode/azure-intune-lab`
- **Secrets Configured:** `AZURE_CREDENTIALS`, `AZURE_SUBSCRIPTION_ID`, `AZURE_RESOURCE_GROUP`, `VM_ADMIN_PASSWORD`

## Next Steps Checklist

1. [x] **Core Infrastructure Deployment**
2. [x] **Cost Management Setup** (Budget + Auto-shutdown)
3. [x] **Local Control Script**
4. [ ] **Intune Automatic Enrollment**: Set "MDM user scope" to All in Intune Admin Center.
5. [ ] **First Login**: Start VM via script and RDP using local admin or Entra credentials.
6. [ ] **Verify Enrollment**: Confirm device appears as "Managed" in Intune portal.
