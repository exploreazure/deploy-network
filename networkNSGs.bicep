// Azure Bicep script to deploy nsg's into landing zone
// Version 1.0
// 02/11/2022

// Must run resourceGroups before this script

// az cli example below
// small - az deployment group create --resource-group 'rg-zt0004-uks-nsg' --template-file 'networkNSGs.bicep' --parameters subscriptionName='zt0004' region='uks' location='uksouth' vnetOffering='small' addressSpace='10.0.0.0/23'
// regular az deployment group create --resource-group 'rg-zt0004-uks-nsg' --template-file 'networkNSGs.bicep' --parameters subscriptionName='zt0004' region='uks' location='uksouth' vnetOffering='regular' addressSpace='10.0.0.0/22'
// large az deployment group create --resource-group 'rg-zt0004-uks-nsg' --template-file 'networkNSGs.bicep' --parameters subscriptionName='zt0004' region='uks' location='uksouth' vnetOffering='large' addressSpace='10.0.0.0/21'

param subscriptionName string
param region string = 'uks'
param addressSpace string = '10.0.0.0/23'
param vnetOffering string
param location string = 'uksouth'

var addressSpaces = array(addressSpace)

var addressSpace1Array = split(addressSpaces[0],'/')
var octets = split(addressSpace1Array[0],'.')
var octet3add1 = string((int(octets[2]) + 1))
var octet3add2 = string((int(octet3add1) + 1))
var octet3add3 = string((int(octet3add2) + 1))
var octet3add4 = string((int(octet3add3) + 1))

//TODO: Custom NSG rules

// deploy nsgs
module nsgSubnet1 './modules/Microsoft.Network/networkSecurityGroups/deploy.bicep' = {
  name: 'nsgSubnet1-nsg'
  params: {
    name: (vnetOffering == 'small') ? 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octets[2]}.0_25' : 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octets[2]}.0_24'
    location: location
  }
}


module nsgSubnet2 './modules/Microsoft.Network/networkSecurityGroups/deploy.bicep' = {
  name: 'nsgSubnet2-nsg'
  params: {
    name: (vnetOffering == 'small') ? 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octets[2]}.128_25' : 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add1}.0_24'
    location: location
  }
}

module nsgSubnet3 './modules/Microsoft.Network/networkSecurityGroups/deploy.bicep' = {
  name: 'nsgSubnet3-nsg'
  params: {
    name: (vnetOffering == 'small') ? 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add1}.0_25' : 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add2}.0_24'
    location: location
  }
}

module nsgSubnet4 './modules/Microsoft.Network/networkSecurityGroups/deploy.bicep' = {
  name: 'nsgSubnet4-nsg'
  params: {
    name: (vnetOffering == 'small') ? 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add1}.128_26' : 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add3}.0_25'
    location: location
  }
}

module nsgSubnet5 './modules/Microsoft.Network/networkSecurityGroups/deploy.bicep' = {
  name: 'nsgSubnet5-nsg'
  params: {
    name: (vnetOffering == 'small') ? 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add1}.192_26' : 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add3}.128_25'
    location: location
  }
}

// Only deploy this nsg if offerig equals large
module nsgSubnet6 './modules/Microsoft.Network/networkSecurityGroups/deploy.bicep' = if (vnetOffering == 'large') {
  name: 'nsgSubnet6-nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add4}.0_22'
  params: {
    name: 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add4}.0_22'
    location: location
  }
}

