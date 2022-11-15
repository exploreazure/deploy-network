// Azure Bicep script to deploy nsg's into landing zone
// Version 1.0
// 02/11/2022

// Must run resourceGroups before this script

// az cli example below - must run az login and az account set --subscription "<subname>" to setup environment
// small - az deployment group create --resource-group 'rg-zt0004-uks-nsg' --template-file 'networkNSGs.bicep' --parameters subscriptionName='zt0004' region='uks' location='uksouth' vnetOffering='small' addressSpace='10.0.0.0/23'
// regular az deployment group create --resource-group 'rg-zt0004-uks-nsg' --template-file 'networkNSGs.bicep' --parameters subscriptionName='zt0004' region='uks' location='uksouth' vnetOffering='regular' addressSpace='10.0.0.0/22'
// large az deployment group create --resource-group 'rg-zt0004-uks-nsg' --template-file 'networkNSGs.bicep' --parameters subscriptionName='zt0004' region='uks' location='uksouth' vnetOffering='large' addressSpace='10.0.0.0/21' cidrLarge='23'

// PowerShell
// Connect-AzAccount
// Get-AzSubscription
//
// Small New-AzResourceGroupDeployment -ResourceGroupName 'rg-zt0004-uks-nsg' -TemplateFile 'networkNSGs.bicep' -subscriptionName 'zt0004' -region 'uks' -location 'uksouth' -vnetOffering 'small' -addressSpace '10.10.0.0/23'
// Regular New-AzResourceGroupDeployment -ResourceGroupName 'rg-zt0004-uks-nsg' -TemplateFile 'networkNSGs.bicep' -subscriptionName 'zt0004' -region 'uks' -location 'uksouth' -vnetOffering 'regular' -addressSpace '10.0.0.0/22'
// large New-AzResourceGroupDeployment -ResourceGroupName 'rg-zt0004-uks-nsg' -TemplateFile 'networkNSGs.bicep' -subscriptionName 'zt0004' -region 'uks' -location 'uksouth' -vnetOffering 'large' -addressSpace '10.0.0.0/21' -cidrLarge '23'



param subscriptionName string
param region string = 'uks'
param addressSpace string = '10.0.0.0/23'
param vnetOffering string
param location string = 'uksouth'
param cidrLarge string = ''

var addressSpaces = array(addressSpace)

var addressSpace1Array = split(addressSpaces[0],'/')
var octets = split(addressSpace1Array[0],'.')
var octet3add1 = string((int(octets[2]) + 1))
var octet3add2 = string((int(octet3add1) + 1))
var octet3add3 = string((int(octet3add2) + 1))
var octet3add4 = string((int(octet3add3) + 1))
var defaultSecurityRules = [
  {
    name: 'vnetLocal'
    properties: {
      access: 'Allow'
      priority: 4094
      direction: 'Inbound'
      description: 'Allow Local virtual network data flow'
      destinationAddressPrefix: 'VirtualNetwork'
      destinationPortRange: '*'
      sourceAddressPrefix: 'VirtualNetwork'
      sourcePortRange: '*'
      protocol: '*'
    }
  }
  {
    name: 'vnetLoadBalancer'
    properties: {
      access: 'Allow'
      priority: 4095
      direction: 'Inbound'
      description: 'Allow Load Balancer network data flow'
      destinationAddressPrefix: 'AzureLoadBalancer'
      destinationPortRange: '*'
      sourceAddressPrefix: 'AzureLoadBalancer'
      sourcePortRange: '*'
      protocol: '*'
    }
  }
  {
    name: 'denyAllInbound'
    properties: {
      access: 'Deny'
      priority: 4096
      direction: 'Inbound'
      description: 'Deny All Other Traffic'
      destinationAddressPrefix: '*'
      destinationPortRange: '*'
      sourceAddressPrefix: '*'
      sourcePortRange: '*'
      protocol: '*'
    }
  }
  {
    name: 'internalOut'
    properties: {
      access: 'Allow'
      priority: 4094
      direction: 'Outbound'
      description: 'Allow private address ranges'
      destinationAddressPrefix: '10.0.0.0/8'
      destinationPortRange: '*'
      sourceAddressPrefix: '10.0.0.0/8'
      sourcePortRange: '*'
      protocol: '*'
    }
  }
  {
    name: 'allVnetOutbound'
    properties: {
      access: 'Allow'
      priority: 4095
      direction: 'Outbound'
      description: 'Allow Virtual Network data flow'
      destinationAddressPrefix: 'VirtualNetwork'
      destinationPortRange: '*'
      sourceAddressPrefix: 'VirtualNetwork'
      sourcePortRange: '*'
      protocol: '*'
    }
  }
  {
    name: 'denyAllOutbound'
    properties: {
      access: 'Deny'
      priority: 4096
      direction: 'Outbound'
      description: 'Deny All Other Traffic'
      destinationAddressPrefix: '*'
      destinationPortRange: '*'
      sourceAddressPrefix: '*'
      sourcePortRange: '*'
      protocol: '*'
    }
  }
]

// deploy nsgs
module nsgSubnet1 './modules/Microsoft.Network/networkSecurityGroups/deploy.bicep' = {
  name: 'nsgSubnet1-nsg'
  params: {
    name: (vnetOffering == 'small') ? 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octets[2]}.0_25' : 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octets[2]}.0_24'
    location: location
    securityRules: defaultSecurityRules
  }
}


module nsgSubnet2 './modules/Microsoft.Network/networkSecurityGroups/deploy.bicep' = {
  name: 'nsgSubnet2-nsg'
  params: {
    name: (vnetOffering == 'small') ? 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octets[2]}.128_25' : 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add1}.0_24'
    location: location
    securityRules: defaultSecurityRules
  }
}

module nsgSubnet3 './modules/Microsoft.Network/networkSecurityGroups/deploy.bicep' = {
  name: 'nsgSubnet3-nsg'
  params: {
    name: (vnetOffering == 'small') ? 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add1}.0_25' : 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add2}.0_24'
    location: location
    securityRules: defaultSecurityRules
  }
}

module nsgSubnet4 './modules/Microsoft.Network/networkSecurityGroups/deploy.bicep' = {
  name: 'nsgSubnet4-nsg'
  params: {
    name: (vnetOffering == 'small') ? 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add1}.128_26' : 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add3}.0_25'
    location: location
    securityRules: defaultSecurityRules
  }
}

module nsgSubnet5 './modules/Microsoft.Network/networkSecurityGroups/deploy.bicep' = {
  name: 'nsgSubnet5-nsg'
  params: {
    name: (vnetOffering == 'small') ? 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add1}.192_26' : 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add3}.128_25'
    location: location
    securityRules: defaultSecurityRules
  }
}

// Only deploy this nsg if offerig equals large
module nsgSubnet6 './modules/Microsoft.Network/networkSecurityGroups/deploy.bicep' = if (vnetOffering == 'large') {
  name: 'nsgSubnet6-nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add4}.0_${cidrLarge}'
  params: {
    name: 'nsg-${subscriptionName}-${region}-${octets[0]}.${octets[1]}.${octet3add4}.0_${cidrLarge}'
    location: location
    securityRules: defaultSecurityRules
  }
}
