# Project goals

The main objective is to implement a cloud-based laboratory environment to test mobile device management (MDM) and security policy enforcement.

Specifically, the aim is to validate and compare two different architectures to restrict access to generative AI tools (such as ChatGPT) on corporate devices:
1. **Application-Level Enforcement**: Using Intune Configuration Catalog policies for browser-specific lockdowns.
2. **OS/Network-Level Enforcement**: Using Microsoft Defender Network Protection to block access across all browsers (Chrome, Firefox, etc.) and CLI tools.

Demonstrate the complete management cycle: from user creation and license assignment to device registration and enforced policy verification at the endpoint.

## Services & Arquitecture

- **Microsoft Intune**: Used for creating and deploying device configuration profiles.
- **Microsoft Defender for Business**: Used for enforcing OS-level Web Content Filtering and Network Protection.
- **Microsoft Entra ID (Azure AD)**: Used for identity management, security groups, and official device registration.
- **Microsoft 365 Admin Center**: Used for user administration, assigning licenses, and managing groups.
- **Azure Virtual Machines**: Acts as the Windows 11 host to apply and test the restrictions.

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

## Method 1: Intune Policy Configuration (Edge-Only)

- Action: Deploys a URLBlocklist directly to the browser.
- Best for: Organizations that strictly enforce Microsoft Edge as the only allowed browser.
- Vulnerability: Users can bypass this by simply downloading a different browser (like Firefox) that doesn't respect Intune's Edge/Chrome policies.

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

### Method 2: Defender Network Protection (OS-Wide)

- Action: The Windows OS itself monitors network requests. If any app (even a command-line tool) tries to reach a blocked domain, the OS kills the connection.
- Best for: Organizations that want to prevent "Shadow IT" bypasses where users download third-party browsers (Chrome, Firefox, Brave) to evade Edge policies.
- Result: ChatGPT is blocked in Edge, Chrome, Firefox, and even via PowerShell.

This Method uses a four-layered "trap" to ensure AI governance:
Layer,Component,Function
1. Defender Indicators: Identifies chatgpt.com as a restricted domain in the cloud. ---> The Brain.
2. Network Protection: The OS-level engine that physically kills the connection. ---> The Muscle.
3. QUIC Disabled:"Prevents browsers from using ""secret"" UDP tunnels to bypass the muscle." ---> The Tunnel Guard.
4. DoH Disabled: Prevents browsers from hiding the destination name via encrypted DNS. --> The Encryption Guard

To enforce restrictions across **all browsers** (Chrome, Firefox, Edge, etc.) using Microsoft Defender for Business:

#### 1. Enable Network Protection on the VM
Run this script to turn on the local enforcement engine:
```powershell
.\scripts\enable-defender-protection.ps1
```

#### 2. Configure Defender Portal (Security Center)
Since cloud configurations require manual portal access, follow these steps:

1. **Enable Custom Indicators (One-time setup)**:
   - Go to [security.microsoft.com](https://security.microsoft.com/) > **Settings** > **Endpoints** > **Advanced features**.
   - Scroll to **Custom network indicators** and toggle it **On**. Click **Save preferences**.
  
<img width="959" height="508" alt="Custom network indicators" src="https://github.com/user-attachments/assets/30f722ac-f2db-4773-80e0-dff699ac03f4" />
[Image 5. Enable Custom network indicator. Microsoft Defender]


2. **Create the Block Rule**:
   - Go to **Settings** > **Endpoints** > **Indicators**.
   - Select the **URLs/Domains** tab and click **Add item**.
   - **URL/Domain**: `chatgpt.com`
   - **Action**: Select **Block execution**.
   - **Title**: `AI Governance - Block ChatGPT`
   - **Scope**: Select **All devices in my scope**.
   - Click **Save**.
  
<img width="959" height="509" alt="summary indicator Defender" src="https://github.com/user-attachments/assets/807ce88f-8f72-4600-9a68-9d5ad2037a5c" />

[Image 6. Block Rule summary. Microsoft Defender]

After setting the previous Block rule, Windows Security will trigger a informative alert like the image below

<img width="289" height="161" alt="block chatgpt firefox full windows alert cut" src="https://github.com/user-attachments/assets/64763e4d-f750-40a0-9e94-9361c90cb774" />

[Image 7. Windows Security alert. Remote Desktop Connection]

3. **Close the "QUIC" Tunnel**:
Google Chrome and Edge often use the QUIC protocol (UDP 443), which can sneak past traditional web filters. We disabled this via Intune to force all traffic through standard, inspectable TCP channels.

4. **DNS-over-HTTPS (DoH)**:
Modern browsers "whisper" website names to the internet using encrypted DNS. We disabled DoH to ensure the OS can see the request for chatgpt.com and block it.

- Configuration: Applied via Intune Settings Catalog: Control the mode of DNS-over-HTTPS as well as QUIC -> Disabled.

<img width="1914" height="1002" alt="DNS over HTTPS" src="https://github.com/user-attachments/assets/a1f0529a-abdc-4db2-af6e-a1187ea000fa" />
[Image 8. QUIC protocol and DNS-over-HTTPS disable. Microsoft Intune Admin Center]


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
[Image 9. Remote access with Entra ID Username. Microsoft Athentication login window]

### Policy Verification & Manual Sync 
If Intune policies (like Edge blocking) aren't appearing immediately:

**Option A: PowerShell (Fastest)** 
Inside the VM, open Windows PowerShell as administrator and run:   ``powershell
   Get-ScheduledTask -TaskName "PushLaunch" | Start-ScheduledTask        
   ``

**Option B: Windows GUI**
Go to Settings > Accounts > Access work or school. Click the account managed by your organization, click Info, scroll down, and click Sync.

<img width="700" height="550" alt="remote desktop chat block edited" src="https://github.com/user-attachments/assets/89fc3c77-8de0-4001-9849-b513032f7a9d" />
[Image 10. Edge Policy. Remote Desktop Connection]

Once synced, open Edge and verify at edge://policy. Navigating to ChatGPT should now show a blocked screen.

### Microsoft Graph (User Management)
Helper scripts to prepare your M365 tenant:

- **Create Test User**: `.\scripts\setup-graph-user.ps1` (Creates a test user and assigns Business Premium).
- **Verify MDM Scope**: `.\scripts\verify-mdm-scope.ps1` (Checks if a user is in the enrollment scope).

## Cost Management

- **Auto-Shutdown**: The VM is configured to automatically shut down at **19:00 UTC** daily to prevent accidental costs.
- **Deallocation**: Use the `Stop` action in the management script to ensure compute charges are paused.
- **Storage**: Uses `StandardSSD_LRS` for a balance of performance and cost.

## Final Result

Once the policies and rules are apply, chatgpt should be succefully block like in the images below.

<img width="876" height="553" alt="edge browser session edited" src="https://github.com/user-attachments/assets/325d1bb5-1655-4f15-9f7d-8942b4ec9012" />

[Image 11. ChatGPT.com is blocked in the Edge browser session while applying Method 1.Intune Policy Configuration. Remote Desktop Connection]


<img width="1596" height="1093" alt="chat block firefox windows alert" src="https://github.com/user-attachments/assets/31a10962-2ca4-424d-a0ba-f4fcc342cfff" />

[Image 12. ChatGPT.com is blocked in FireFox browser while applying Method 2.Defender Network Protection. Remote Desktop Connection] 

