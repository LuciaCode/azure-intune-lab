# Azure Intune Lab

This repository contains Azure Bicep templates to deploy a Windows 11 Virtual Machine that is automatically enrolled in Microsoft Intune via Microsoft Entra ID Join.

## Documentation

- **[STATUS.md](./STATUS.md)**: Current deployment status, IP addresses, and cost tracking.

## Features

- **Windows 11 Enterprise VM**: Optimized for Microsoft 365 environments (`Standard_D2s_v3`).
- **Entra ID Join**: Automatically joins the VM to your Microsoft Entra ID tenant.
- **Intune Auto-Enrollment**: Triggered by the Entra Join process.
- **Cost Optimized**: Uses Standard SSD and includes automatic daily shutdown.
- **Management Scripts**: PowerShell scripts to control the lab, generate credentials, and manage M365 users.
- **GitHub Actions**: CI/CD pipeline for automated deployment.

## Prerequisites

Before deploying, ensure the following are configured in your Microsoft 365 / Azure tenant:

1.  **Intune Automatic Enrollment**:
    - Go to **Microsoft Entra ID** -> **Mobility (MDM and MAM)** -> **Microsoft Intune**.
    - Set **MDM user scope** to **All** (or a specific group of users).
2.  **Licenses**:
    - The user account used to log in (or the global settings) must have a valid **Microsoft 365 E3/E5** or **Intune** license.
3.  **Azure CLI**: Installed locally if you wish to use the management scripts.

## Setup & Deployment

### 1. Generate Azure Credentials
Run the helper script to create a Service Principal and generate the required JSON for GitHub:
```powershell
.\scripts\generate-credentials.ps1
```

### 2. Configure GitHub Secrets
Set the following secrets in your GitHub repository:

- `AZURE_CREDENTIALS`: The JSON output from the script above.
- `AZURE_SUBSCRIPTION_ID`: Your Azure Subscription ID.
- `AZURE_RESOURCE_GROUP`: The name of the Resource Group to deploy into (default: `rg-intune-lab`).
- `VM_ADMIN_PASSWORD`: A strong password for the local admin account.

### 3. Deploy
Push this code to your GitHub repository. The GitHub Action `Deploy Azure Intune Lab` will trigger automatically.

## Local Management

### Lab Infrastructure
Use the `manage-lab.ps1` script to control the VM state and save costs:

- **Start Lab**: `.\scripts\manage-lab.ps1 -Action Start`
- **Stop Lab**: `.\scripts\manage-lab.ps1 -Action Stop` (Deallocates the VM to stop billing)
- **Check Status**: `.\scripts\manage-lab.ps1 -Action Status`

### Remote Desktop (RDP) Setup
To access the VM as an Entra ID (Cloud) user like Juan Perez:

1. **Classic Login**: Connect with NLA disabled to see the Windows lock screen.
2. **Entra ID Username**: Use `AzureAD\jperez@cloudcompassconsulting.onmicrosoft.com`.
3. **Manual Sync**: If Intune policies (like Edge blocking) aren't appearing immediately, run this in an admin PowerShell inside the VM:
   ```powershell
   Get-ScheduledTask -TaskName "PushLaunch" | Start-ScheduledTask
   ```

### Microsoft Graph (User Management)
Helper scripts to prepare your M365 tenant:

- **Create Test User**: `.\scripts\setup-graph-user.ps1` (Creates 'Juan Perez' and assigns Business Premium).
- **Verify MDM Scope**: `.\scripts\verify-mdm-scope.ps1` (Checks if a user is in the enrollment scope).

## Cost Management

- **Auto-Shutdown**: The VM is configured to automatically shut down at **19:00 UTC** daily to prevent accidental costs.
- **Deallocation**: Use the `Stop` action in the management script to ensure compute charges are paused.
- **Storage**: Uses `StandardSSD_LRS` for a balance of performance and cost.

## How it works

The Bicep template uses the `AADLoginForWindows` VM extension. When the VM starts, this extension performs the Entra Join. If your tenant has "Automatic MDM Enrollment" enabled, the VM will automatically check into Intune shortly after the join process completes.
