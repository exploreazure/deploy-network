// Azure Bicep script to deploy all resource groups into landing zone
// Version 1.0
// 01/11/2022

// az cli example below
// az deployment sub create --location uksouth --parameters subscriptionName='zt0004' region='uks' --template-file 'resourceGroups.bicep'

param subscriptionName string
param region string = 'uks'
param location string = 'uksouth'

targetScope = 'subscription'

// Module to deploy Network Resource Group
// Will deploy resource lock, once all networking components have been deployed by pipeline
module resourceGroupsNetwork './modules/Microsoft.Resources/resourceGroups/deploy.bicep' = {
  name: 'rg-${subscriptionName}-${region}-network'
  params: {
    name: 'rg-${subscriptionName}-${region}-network'
    location: location
  }
}

// Module to deploy Network Resource Groups
module resourceGroupsNSG './modules/Microsoft.Resources/resourceGroups/deploy.bicep' = {
  name: 'rg-${subscriptionName}-${region}-nsg'
  params: {
    name: 'rg-${subscriptionName}-${region}-nsg'
    location: location
  }
}
