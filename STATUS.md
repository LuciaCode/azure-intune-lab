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
- **Networking:** Standard SKU Public IP (IP: `<VM_PUBLIC_IP>`)
- **Auto-Shutdown:** Daily at 19:00 UTC [ACTIVE]

### 3. Operational Status
- **Power State:** [RUNNING]
- **Management Script:** `scripts/manage-lab.ps1` (Start/Stop/Status)
- **Entra ID Status:** Device `intune-lab-vm` is successfully Entra Joined.
- **Intune Policy:** Edge Governance Policy (Block ChatGPT + uBlock Extension) [ACTIVE]
- **Defender Protection:** Network Protection enabled on VM (OS-level block across all browsers) [ACTIVE]
- **Verification Method:** Logged in as `AzureAD\<TEST_USER_UPN>` and manually triggered `PushLaunch` scheduled task.

## GitHub & Secrets
- **Repository:** `https://github.com/LuciaCode/azure-intune-lab`
- **Secrets Configured:** `AZURE_CREDENTIALS`, `AZURE_SUBSCRIPTION_ID`, `AZURE_RESOURCE_GROUP`, `VM_ADMIN_PASSWORD`

## Next Steps Checklist

1. [x] **Core Infrastructure Deployment**
2. [x] **Cost Management Setup** (Budget + Auto-shutdown)
3. [x] **Local Control Script**
4. [x] **Intune Automatic Enrollment**: MDM user scope set to All.
5. [x] **First Login**: VM successfully accessed by local admin and Entra credentials.
6. [x] **Verify Enrollment**: Device appears as "Managed" in Intune portal.
7. [x] **Policy Deployment**: Edge Governance policy manually configured and assigned.
8. [x] **Policy Verification**: Confirmed ChatGPT is blocked and extension is installed.
