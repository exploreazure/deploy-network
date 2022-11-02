// Azure Bicep script to deploy all resource groups into landing zone
// Version 1.0
// 01/11/2022

// az cli example below
// az deployment group create --resource-group 'rg-zt0004-uks-network' --template-file 'network.bicep' --parameters subscriptionName='zt0004' region='uks' location='uksouth' vnetOffering='small' addressSpace='10.0.0.0/23'

param subscriptionName string
param region string = 'uks'
param addressSpace string = '10.0.0.0/23'
param vnetOffering string
param location string = 'uksouth'

var addressSpaces = array(addressSpace)

var addressSpace1Array = split(addressSpaces[0],'/')
var addressSpace1 = addressSpace1Array[0]
var cidr1 = addressSpace1Array[1]
var octets = split(addressSpace1Array[0],'.')
var octet3add1 = string((int(octets[2]) + 1))
var octet3add2 = string((int(octet3add1) + 1))
var octet3add3 = string((int(octet3add2) + 1))
var octet3add4 = string((int(octet3add3) + 1))

var subnetsSmall = [
  {
    // web/front end
    name: 'snet-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octets[2]}.0_25'
    addressPrefix: '${octets[0]}.${octets[1]}.${octets[2]}.0/25'
  }
  {
    // application
    name: 'snet-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octets[2]}.128_25'
    addressPrefix: '${octets[0]}.${octets[1]}.${octets[2]}.128/25'
  }
  {
    // database
    name: 'snet-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add1}.0_25'
    addressPrefix: '${octets[0]}.${octets[1]}.${octet3add1}.0/25'
  }
  {
    // Tooling
    name: 'snet-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add1}.128_26'
    addressPrefix: '${octets[0]}.${octets[1]}.${octet3add1}.128/26'
  }
  {
    // Central Tooling
    name: 'snet-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add1}.192_26'
    addressPrefix: '${octets[0]}.${octets[1]}.${octet3add1}.192/26'
  }
]

var subnetsRegular = [
  {
    // web/front end
    name: 'snet-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octets[2]}.0_24'
    addressPrefix: '${octets[0]}.${octets[1]}.${octets[2]}.0/24'
  }
  {
    // application
    name: 'snet-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add1}.0_24'
    addressPrefix: '${octets[0]}.${octets[1]}.${octet3add1}.0/24'
  }
  {
    // database
    name: 'snet-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add2}.0_24'
    addressPrefix: '${octets[0]}.${octets[1]}.${octet3add2}.0/24'
  }
  {
    // Tooling
    name: 'snet-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add3}.0_25'
    addressPrefix: '${octets[0]}.${octets[1]}.${octet3add3}.0/25'
  }
  {
    // Central Tooling
    name: 'snet-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add3}.128_25'
    addressPrefix: '${octets[0]}.${octets[1]}.${octet3add3}.128/25'
  }
]

var subnetsLarge = [
  {
    // web/front end
    name: 'snet-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octets[2]}.0_24'
    addressPrefix: '${octets[0]}.${octets[1]}.${octets[2]}.0/24'
  }
  {
    // application
    name: 'snet-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add1}.0_24'
    addressPrefix: '${octets[0]}.${octets[1]}.${octet3add1}.0/24'
  }
  {
    // database
    name: 'snet-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add2}.0_24'
    addressPrefix: '${octets[0]}.${octets[1]}.${octet3add2}.0/24'
  }
  {
    // Tooling
    name: 'snet-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add3}.0_25'
    addressPrefix: '${octets[0]}.${octets[1]}.${octet3add3}.0/25'
  }
  {
    // Central Tooling
    name: 'snet-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add3}.128_25'
    addressPrefix: '${octets[0]}.${octets[1]}.${octet3add3}.128/25'
  }
  {
    // Customer subnet
    name: 'snet-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add4}.0_22'
    addressPrefix: '${octets[0]}.${octets[1]}.${octet3add4}.0/22'
  }
]

module virtualNetworksSmall './modules/Microsoft.Network/virtualNetworks/deploy.bicep' = if (vnetOffering == 'small') {
  name: 'small-vnet-${subscriptionName}-${region}-${addressSpace1}_${cidr1}'
  params: {
    name: 'vnet-${subscriptionName}-${region}-${addressSpace1}_${cidr1}'
    location: location
    addressPrefixes: addressSpaces
    subnets: subnetsSmall
  }
}

module virtualNetworksRegular './modules/Microsoft.Network/virtualNetworks/deploy.bicep' = if (vnetOffering == 'regular') {
  name: 'regular-vnet-${subscriptionName}-${region}-${addressSpace1}_${cidr1}'
  params: {
    name: 'vnet-${subscriptionName}-${region}-${addressSpace1}_${cidr1}'
    location: location
    addressPrefixes: addressSpaces
    subnets: subnetsRegular
  }
}

module virtualNetworksLarge './modules/Microsoft.Network/virtualNetworks/deploy.bicep' = if (vnetOffering == 'large') {
  name: 'large-vnet-${subscriptionName}-${region}-${addressSpace1}_${cidr1}'
  params: {
    name: 'vnet-${subscriptionName}-${region}-${addressSpace1}_${cidr1}'
    location: location
    addressPrefixes: addressSpaces
    subnets: subnetsLarge
  }
}
