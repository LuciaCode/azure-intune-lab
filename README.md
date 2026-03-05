# Project goals

The main objective is to implement a cloud-based laboratory environment to test mobile device management (MDM) and security policy enforcement.

Specifically, the aim is to validate the deployment of Intune Configuration Catalog policies to restrict access to generative AI tools (such as ChatGPT) in the Microsoft Edge browser.

Demonstrate the complete management cycle: from user creation and license assignment to device registration and enforced policy verification at the endpoint.


## Azure Intune Lab

This repository contains Azure Bicep templates to deploy a Windows 11 Virtual Machine that is automatically enrolled in Microsoft Intune via Microsoft Entra ID Join.

## Services & Arquitecture

- **Microsoft Intune**: Used for creating and deploying device configuration profiles.
- **Microsoft Entra ID (Azure AD)**: Used for identity management, security groups, and official device registration.
- **Microsoft 365 Admin Center**: Used for user administration, assigning licenses, and managing groups.
- **Azure Virtual Machines**: Acts as the Windows 11 host to apply and test the restrictions.
- **Microsoft Edge**: The target application where the URLBlocklist policies are applied.

## Repository Structure & Documentation

- **infra/main.bicep**: Orchestrates the deployment by calling the network and compute modules.
- **infra/modules/network.bicep**: Creates the Virtual Network (VNet), Public IP, and Network Security Group (NSG).
- **infra/modules/compute.bicep**: Builds the Windows 11 VM and includes the AADLoginForWindows extension to join Entra ID.
- **STATUS.md**: Tracks the live state of the project, including the Public IP, finished steps, and verification notes.
- **.github/workflows/deploy.yml**: The CI/CD pipeline that tells GitHub Actions to log into Azure and apply Bicep templates upon push.
- **.gitignore**: Keeps private notes and secrets off the internet.

## Features

- **Windows 11 Enterprise VM**: Optimized for Microsoft 365 environments ('Standard_D2s_v3').
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

<img width="1917" height="1016" alt="MDM user scope to All" src="https://github.com/user-attachments/assets/da039e2e-b20f-432a-90b9-60c683a5aaa5" />
[Image 1. MDM user scope set to ALL. Microsoft Entra Admin Center]  

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

## Intune Policy Configuration

To block AI tools like ChatGPT, you must deploy a Settings Catalog profile in Intune.
1. **Create a Security Group**: Intune is optimized to use Security Groups for policy management. Create a group (e.g., Intune - Block ChatGPT) and add your test user to it.
2. **Create the Profile**: In Intune, create a Windows 10 and later profile using the Settings catalog.
3. **Configure Edge Policies**:
   - **URLBlocklist**: Block access to https://chatgpt.com and https://openai.com/chat.
   - **ExtensionInstallForcelist**: Force silent installation of specific extensions using the string cjpalhdlnbpafiamejdnhcphjbkeiagm;https://clients2.google.com/service/update2/crx.
4. **Assign**: Assign this policy to your newly created Security Group.

<img width="957" height="508" alt="Security group dashboar just created" src="https://github.com/user-attachments/assets/2275f9dc-81ab-4dae-af85-f3141cda89e7" />
[Image 2. Security group created succefully. Microsoft 365 Admin Center]

<img width="1914" height="1018" alt="Security group dashboard" src="https://github.com/user-attachments/assets/fc027486-72fa-4c1d-a3f7-51d17c1ce7f8" />
[Image 3. Security group. Microsoft 365 Admin Center]

<img width="959" height="508" alt="Security group dashboard member edited" src="https://github.com/user-attachments/assets/dcffa7c1-9ac2-443b-b518-e4fe51a85fce" />
[Image 4. Security group with member assigned succefully. Microsoft 365 Admin Center]

## Local Management

### Lab Infrastructure
Use the `manage-lab.ps1` script to control the VM state and save costs:  

- **Start Lab**: `.\scripts\manage-lab.ps1 -Action Start`
- **Stop Lab**: `.\scripts\manage-lab.ps1 -Action Stop` (Deallocates the VM to stop billing)
- **Check Status**: `.\scripts\manage-lab.ps1 -Action Status`

### Remote Desktop (RDP) Setup
To access the VM as an Entra ID (Cloud) user:

1. **Classic Login**: Connect with NLA disabled to see the Windows lock screen.
2. **Entra ID Username**: Use `AzureAD\<TEST_USER_UPN>` to ensure Windows authenticates against the cloud.
3. **Fast Pass**: You can also use .\scripts\connect-lab.ps1 to reset the local admin password and automatically launch the RDP window.

<img width="672" height="738" alt="EntraID username edited" src="https://github.com/user-attachments/assets/599956dd-42a7-4d35-8515-5f3c1dd57162" />
[Image 5. Remote access with Entra ID Username. Microsoft Athentication login window]

### Policy Verification & Manual Sync 
If Intune policies (like Edge blocking) aren't appearing immediately:

**Option A: PowerShell (Fastest)** 
Inside the VM, open Windows PowerShell as administrator and run:   ``powershell
   Get-ScheduledTask -TaskName "PushLaunch" | Start-ScheduledTask        
   ``

**Option B: Windows GUI**
Go to Settings > Accounts > Access work or school. Click the account managed by your organization, click Info, scroll down, and click Sync.

<img width="700" height="550" alt="remote desktop chat block edited" src="https://github.com/user-attachments/assets/89fc3c77-8de0-4001-9849-b513032f7a9d" />
[Image 6. Edge Policy. Remote Desktop Connection]

Once synced, open Edge and verify at edge://policy. Navigating to ChatGPT should now show a blocked screen.

### Microsoft Defender (OS-Level Blocking)
To enforce restrictions across **all browsers** (Chrome, Firefox, Edge, etc.):

1. **Enable Network Protection**: Run this script to turn on the local enforcement engine:
   ```powershell
   .\scripts\enable-defender-protection.ps1
   ```
2. **Configure Indicators**: In the [Microsoft Defender Portal](https://security.microsoft.com/), create a **Custom Indicator** (Block) for any URL you want to restrict globally.

### Microsoft Graph (User Management)
Helper scripts to prepare your M365 tenant:

- **Create Test User**: `.\scripts\setup-graph-user.ps1` (Creates a test user and assigns Business Premium).
- **Verify MDM Scope**: `.\scripts\verify-mdm-scope.ps1` (Checks if a user is in the enrollment scope).

## Cost Management

- **Auto-Shutdown**: The VM is configured to automatically shut down at **19:00 UTC** daily to prevent accidental costs.
- **Deallocation**: Use the `Stop` action in the management script to ensure compute charges are paused.
- **Storage**: Uses `StandardSSD_LRS` for a balance of performance and cost.

## Final Result

<img width="876" height="553" alt="edge browser session edited" src="https://github.com/user-attachments/assets/325d1bb5-1655-4f15-9f7d-8942b4ec9012" />
[Image 7. ChatGPT.com is blocked in the edge browser session. Remote Desktop Connection]

