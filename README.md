# Azure Intune Lab

This repository contains Azure Bicep templates to deploy a Windows 11 Virtual Machine that is automatically enrolled in Microsoft Intune via Microsoft Entra ID Join.

## Features

- **Windows 11 Enterprise VM**: Optimized for Microsoft 365 environments.
- **Entra ID Join**: Automatically joins the VM to your Microsoft Entra ID tenant.
- **Intune Auto-Enrollment**: Triggered by the Entra Join process.
- **GitHub Actions**: CI/CD pipeline for automated deployment.

## Prerequisites

Before deploying, ensure the following are configured in your Microsoft 365 / Azure tenant:

1.  **Intune Automatic Enrollment**:
    - Go to **Microsoft Entra ID** -> **Mobility (MDM and MAM)** -> **Microsoft Intune**.
    - Set **MDM user scope** to **All** (or a specific group of users).
2.  **Licenses**:
    - The user account used to log in (or the global settings) must have a valid **Microsoft 365 E3/E5** or **Intune** license.
3.  **Azure Service Principal**:
    - Create a Service Principal with `Contributor` access to your resource group for GitHub Actions.

## GitHub Secrets

Set the following secrets in your GitHub repository:

- `AZURE_CREDENTIALS`: The JSON output from `az ad sp create-for-rbac`.
- `AZURE_SUBSCRIPTION_ID`: Your Azure Subscription ID.
- `AZURE_RESOURCE_GROUP`: The name of the Resource Group to deploy into.
- `VM_ADMIN_PASSWORD`: A strong password for the local admin account.

## Deployment

1.  Push this code to your GitHub repository.
2.  The GitHub Action `Deploy Azure Intune Lab` will trigger automatically.
3.  Once deployed, log in to the VM using your **Microsoft Entra ID credentials** (User Principal Name).

## How it works

The Bicep template uses the `AADLoginForWindows` VM extension. When the VM starts, this extension performs the Entra Join. If your tenant has "Automatic MDM Enrollment" enabled, the VM will automatically check into Intune shortly after the join process completes.
