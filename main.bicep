param location string = resourceGroup().location

@description('Name of the App Service Plan')
param ASP_Name string = 'asp'

@description('Name of the Virtual Network for both the Application Gateway and App Service Environment')
param Vnet_Name string = 'vnet'

@description('Address Prefix for the Virtual Network')
param Vnet_AddressPrefix string = '10.0.0.0/16'

param Subnet_AppGW_AddressPrefix string = '10.0.1.0/25'

param Subnet_ASE_AddressPrefix string = '10.0.1.128/25'

@description('Name of the App Service')
param Website_Name string =  'jamesgsite${substring(uniqueString(resourceGroup().id), 0, 5)}'

@description('Name of the Network Security Group on the App Service Environment subnet')
param ASE_NSG_Name string = 'ase_nsg'

@description('Name of the Application Gateway')
param AppGW_Name string = 'appgw'

@description('Name of the Public IP Address resource of the Applciation Gateway')
param AppGW_PIP_Name string = 'appgw_pip'

@description('Private IP Address of the Private Frontend IP of the Application Gateway')
param AppGW_PrivateIP_Address string = '10.0.1.124' // Should use an IP address at the end of the Subnet_AppGW_AddressPrefix range

@description('Name of the Web Application Firewall of the Application Gateway')
param AppGW_WAF_Name string = 'appgw_waf'

@description('Name of the Network Security Group on the Application Gateway subnet')
param AppGW_NSG_Name string = 'appgw_nsg'


module network 'website_vnet.bicep' = {
  name: 'network'
  params: {
    location: location
    Vnet_Name: Vnet_Name
    Vnet_AddressPrefix: Vnet_AddressPrefix
    Subnet_AppGW_AddressPrefix: Subnet_AppGW_AddressPrefix
    Subnet_ASE_AddressPrefix: Subnet_ASE_AddressPrefix
    AppGW_NSG_Name: AppGW_NSG_Name
    ASE_NSG_Name: ASE_NSG_Name
  }
}

module site 'site.bicep' = {
  name: 'site'
  params: {
    ASP_Name: ASP_Name
    location: location
    Vnet_Name: network.outputs.vnetName
    ASE_Subnet_Name: network.outputs.aseSubnetName
    Website_Name: Website_Name
  }
}

module AppGW 'ApplicationGateway.bicep' = {
  name: 'AppGW'
  params: {
    AppGW_Name: AppGW_Name
    AppGW_PIP_Name: AppGW_PIP_Name
    AppGW_PrivateIP_Address: AppGW_PrivateIP_Address
    AppGW_WAF_Name: AppGW_WAF_Name
    location: location
    Vnet_Name: network.outputs.vnetName
    AppGW_Subnet_Name: network.outputs.appgwSubnetName
    backendPoolFQDN: site.outputs.websiteFQDN
  }
}
