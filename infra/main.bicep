targetScope = 'resourceGroup'

param location string = resourceGroup().location
param prefix string = 'intune-lab'
param adminUsername string = 'azureuser'
@secure()
param adminPassword string

module network './modules/network.bicep' = {
  name: 'network-deployment'
  params: {
    location: location
    prefix: prefix
  }
}

module compute './modules/compute.bicep' = {
  name: 'compute-deployment'
  params: {
    location: location
    prefix: prefix
    subnetId: network.outputs.subnetId
    adminUsername: adminUsername
    adminPassword: adminPassword
  }
}

output vmPublicIP string = compute.outputs.publicIP
