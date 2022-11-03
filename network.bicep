// Azure Bicep script to deploy virtual network into landing zone
// Version 1.0
// 01/11/2022

// Must run resourceGroups and networkPreq.bicep before this script

// az cli example below
// small az deployment group create --resource-group 'rg-zt0004-uks-network' --template-file 'network.bicep' --parameters subscriptionName='zt0004' region='uks' location='uksouth' vnetOffering='small' addressSpace='10.0.0.0/23'
// regular az deployment group create --resource-group 'rg-zt0004-uks-network' --template-file 'network.bicep' --parameters subscriptionName='zt0004' region='uks' location='uksouth' vnetOffering='regular' addressSpace='10.0.0.0/22'
// large az deployment group create --resource-group 'rg-zt0004-uks-network' --template-file 'network.bicep' --parameters subscriptionName='zt0004' region='uks' location='uksouth' vnetOffering='large' addressSpace='10.0.0.0/21'

param subscriptionName string
param region string = 'uks'
param addressSpace string = '10.0.0.0/23'
param vnetOffering string
param location string = 'uksouth'

var addressSpaces = array(addressSpace)

var addressSpace1Array = split(addressSpaces[0], '/')
var addressSpace1 = addressSpace1Array[0]
var cidr1 = addressSpace1Array[1]
var octets = split(addressSpace1Array[0], '.')
var octet3add1 = string((int(octets[2]) + 1))
var octet3add2 = string((int(octet3add1) + 1))
var octet3add3 = string((int(octet3add2) + 1))
var octet3add4 = string((int(octet3add3) + 1))
var dnsServers = [
  '10.0.0.1'
  '10.0.0.2'
  '10.0.0.3'
]

// obtain nsg resource ids
resource nsgSubnet1 'Microsoft.Network/networkSecurityGroups@2022-05-01' existing = {
  name: (vnetOffering == 'small') ? 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octets[2]}.0_25' : 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octets[2]}.0_24'
  scope: resourceGroup('rg-${subscriptionName}-${region}-nsg')
}
resource nsgSubnet2 'Microsoft.Network/networkSecurityGroups@2022-05-01' existing = {
  name: (vnetOffering == 'small') ? 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octets[2]}.128_25' : 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add1}.0_24'
  scope: resourceGroup('rg-${subscriptionName}-${region}-nsg')
}
resource nsgSubnet3 'Microsoft.Network/networkSecurityGroups@2022-05-01' existing = {
  name: (vnetOffering == 'small') ? 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add1}.0_25' : 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add2}.0_24'
  scope: resourceGroup('rg-${subscriptionName}-${region}-nsg')
}
resource nsgSubnet4 'Microsoft.Network/networkSecurityGroups@2022-05-01' existing = {
  name: (vnetOffering == 'small') ? 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add1}.128_26' : 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add3}.0_25'
  scope: resourceGroup('rg-${subscriptionName}-${region}-nsg')
}
resource nsgSubnet5 'Microsoft.Network/networkSecurityGroups@2022-05-01' existing = {
  name: (vnetOffering == 'small') ? 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add1}.192_26' : 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add3}.128_25'
  scope: resourceGroup('rg-${subscriptionName}-${region}-nsg')
}
resource nsgSubnet6 'Microsoft.Network/networkSecurityGroups@2022-05-01' existing = if (vnetOffering == 'large') {
  name: 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add4}.0_22'
  scope: resourceGroup('rg-${subscriptionName}-${region}-nsg')
}

// subnet array
var subnets = [
  {
    // 1 - web/front end
    name: (vnetOffering == 'small') ? 'snet-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octets[2]}.0_25' : 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octets[2]}.0_24'
    addressPrefix: (vnetOffering == 'small') ? '${octets[0]}.${octets[1]}.${octets[2]}.0/25' : '${octets[0]}.${octets[1]}.${octets[2]}.0/24'
    privateEndpointNetworkPolicies: 'Disabled'
    networkSecurityGroupId: nsgSubnet1.id
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
      }
      {
        service: 'Microsoft.KeyVault'
      }
    ]
  }
  {
    // 2 - application
    name: (vnetOffering == 'small') ? 'snet-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octets[2]}.128_25' : 'snet-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add1}.0_24'
    addressPrefix: (vnetOffering == 'small') ? '${octets[0]}.${octets[1]}.${octets[2]}.128/25' : '${octets[0]}.${octets[1]}.${octet3add1}.0/24'
    privateEndpointNetworkPolicies: 'Disabled'
    networkSecurityGroupId: nsgSubnet2.id
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
      }
      {
        service: 'Microsoft.KeyVault'
      }
    ]
  }
  {
    // 3 - database
    name: (vnetOffering == 'small') ? 'snet-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add1}.0_25' : 'snet-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add2}.0_24'
    addressPrefix: (vnetOffering == 'small') ? '${octets[0]}.${octets[1]}.${octet3add1}.0/25' : '${octets[0]}.${octets[1]}.${octet3add2}.0/24'
    privateEndpointNetworkPolicies: 'Disabled'
    networkSecurityGroupId: nsgSubnet3.id
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
      }
      {
        service: 'Microsoft.KeyVault'
      }
    ]
  }
  {
    // 4 - Tooling
    name: (vnetOffering == 'small') ? 'snet-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add1}.128_26' : 'snet-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add3}.0_25'
    addressPrefix: (vnetOffering == 'small') ? '${octets[0]}.${octets[1]}.${octet3add1}.128/26' : '${octets[0]}.${octets[1]}.${octet3add3}.0/25'
    privateEndpointNetworkPolicies: 'Disabled'
    networkSecurityGroupId: nsgSubnet4.id
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
      }
      {
        service: 'Microsoft.KeyVault'
      }
    ]
  }
  {
    // 5 - Central Tooling
    name: (vnetOffering == 'small') ? 'snet-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add1}.192_26' : 'snet-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add3}.128_25'
    addressPrefix: (vnetOffering == 'small') ? '${octets[0]}.${octets[1]}.${octet3add1}.192/26' : '${octets[0]}.${octets[1]}.${octet3add3}.128/25'
    privateEndpointNetworkPolicies: 'Disabled'
    networkSecurityGroupId: nsgSubnet5.id
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
      }
      {
        service: 'Microsoft.KeyVault'
      }
    ]
  }
]

module virtualNetwork './modules/Microsoft.Network/virtualNetworks/deploy.bicep' = {
  name: 'vnet-${subscriptionName}-${region}-${addressSpace1}_${cidr1}'
  params: {
    name: 'vnet-${subscriptionName}-${region}-${addressSpace1}_${cidr1}'
    location: location
    addressPrefixes: addressSpaces
    subnets: subnets
    dnsServers: dnsServers
  }
}

module largeSubnet './modules/Microsoft.Network/virtualNetworks/subnets/deploy.bicep' = if (vnetOffering == 'large') {
  // 6 - Customer subnet - Only deploy for large vnet offering
  name: 'snet-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add4}.0_22'
  params: {
    name: 'snet-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add4}.0_22'
    virtualNetworkName: 'vnet-${subscriptionName}-${region}-${addressSpace1}_${cidr1}'
    addressPrefix: '${octets[0]}.${octets[1]}.${octet3add4}.0/22'
    privateEndpointNetworkPolicies: 'Disabled'
    networkSecurityGroupId: nsgSubnet6.id
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
      }
      {
        service: 'Microsoft.KeyVault'
      }
    ]
  }
  dependsOn: [
    virtualNetwork
  ]
}
