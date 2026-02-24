# Run this script to generate the JSON for your AZURE_CREDENTIALS GitHub Secret
# You must be logged into Azure CLI (az login)

$subscriptionId = (az account show --query id -o tsv)
$resourceGroupName = "rg-intune-lab"

Write-Host "Creating Service Principal for Resource Group: $resourceGroupName" -ForegroundColor Cyan

az ad sp create-for-rbac --name "github-intune-lab" --role contributor --scopes "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName" --sdk-auth
