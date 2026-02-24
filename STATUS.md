# Project Status: Azure Intune Lab

## Current State (as of 2026-02-24)

### 1. Azure Configuration
- **Status:** [ACTIVE]
- **User:** `dayilutasa@outlook.com`
- **Subscription:** `Subscription 1` (b90f7326-3aba-4d2f-bf6d-d6fa49908026)
- **Tenant:** `41364736-d9c2-48bd-9a22-a52918347aac`

### 2. GitHub & Git Configuration
- **GitHub CLI:** [NOT LOGGED IN]
- **Git Identity:** [NOT SET] (user.name and user.email required)
- **Remote Origin:** [NOT CONFIGURED]

### 3. Infrastructure (Bicep)
- **Files:** `infra/main.bicep`, `infra/modules/`
- **Deployment Status:** [PENDING]
- **Validation:** Syntax and structure appear correct.

## Required GitHub Secrets
Once the repository is pushed, you must set these in **Settings > Secrets and variables > Actions**:
1. `AZURE_CREDENTIALS`: JSON output from Service Principal creation.
2. `AZURE_SUBSCRIPTION_ID`: `b90f7326-3aba-4d2f-bf6d-d6fa49908026`
3. `AZURE_RESOURCE_GROUP`: e.g., `rg-intune-lab`
4. `VM_ADMIN_PASSWORD`: A secure password for the VM.

## Next Steps Checklist

1. [ ] **Git Identity:** Run these commands:
   ```powershell
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```
2. [ ] **GitHub Login:** Run `gh auth login` and follow the prompts.
3. [ ] **Azure Setup (I can help with this):**
   - Create Resource Group: `az group create -n rg-intune-lab -l eastus`
   - Create Service Principal: (Run the script `scripts/generate-credentials.ps1` after updating the RG name).
4. [ ] **Repository Setup:**
   - `git remote add origin <your-repo-url>`
   - `git push -u origin main`
