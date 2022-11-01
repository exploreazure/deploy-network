// Azure Bicep script to deploy all resource groups into landing zone
// Version 1.0
// 01/11/2022

// az cli example below
// az deployment sub create --location uksouth --parameters subscriptionName='zt0004' region='uks' --template-file 'resourceGroups.bicep'


param subscriptionName string
param region string = 'uks'
param addressSpaces array = ['10.0.0.0/24']
// param tshirtSize string
param location string = 'uksouth'

var addressSpace1Array = split(addressSpaces[0],'/')
var addressSpace1 = addressSpace1Array[0]
var cidr1 = addressSpace1Array[1]

module virtualNetworks './modules/Microsoft.Network/virtualNetworks/deploy.bicep' = {
  name: 'vnet-${subscriptionName}-${region}-${addressSpace1}_${cidr1}'
  params: {
    name: 'vnet-${subscriptionName}-${region}-${addressSpace1}_${cidr1}'
    location: location
    addressPrefixes: addressSpaces
  }
}
