                                                                        # Creates a virtual network (VNet) to host the subnets and resources
resource "azurerm_virtual_network" "cabbage_vnet" {
  name                  = "${local.vnet_name}1040016"                   # Name of the VNet
  address_space         = ["10.4.0.0/16"]                               # Address space for the VNet
  location              = var.location                                  # Azure region for deployment
  resource_group_name   = azurerm_resource_group.cabbage_rg.name        # Resource group for the VNet
}

                                                                        # Creates a subnet for the management interfaces of the Palo Alto firewalls
resource "azurerm_subnet" "mgmt_subnet" {
  name                  = "${local.subnet_name_prefix}mgmt-1040024"     # Name of the management subnet
  resource_group_name   = azurerm_resource_group.cabbage_rg.name        # Resource group for the subnet
  virtual_network_name  = azurerm_virtual_network.cabbage_vnet.name     # VNet for the subnet
  address_prefixes      = ["10.4.0.0/24"]                               # Address prefix for the management subnet
}

                                                                        # Creates a subnet for the trust interface where the Windows VM resides
resource "azurerm_subnet" "trust_subnet" {
  name                  = "${local.subnet_name_prefix}trust-1042024"    # Name of the trust subnet
  resource_group_name   = azurerm_resource_group.cabbage_rg.name        # Resource group for the subnet
  virtual_network_name  = azurerm_virtual_network.cabbage_vnet.name     # VNet for the subnet
  address_prefixes      = ["10.4.2.0/24"]                               # Address prefix for the trust subnet
}

                                                                        # Creates a subnet for the untrust interface of the Palo Alto firewalls
resource "azurerm_subnet" "untrust_subnet" {
  name                  = "${local.subnet_name_prefix}untrust-1041024"  # Name of the untrust subnet
  resource_group_name   = azurerm_resource_group.cabbage_rg.name        # Resource group for the subnet
  virtual_network_name  = azurerm_virtual_network.cabbage_vnet.name     # VNet for the subnet
  address_prefixes      = ["10.4.1.0/24"]                               # Address prefix for the untrust subnet
}

                                                                        # Creates a subnet for the HA interfaces of the Palo Alto firewalls
resource "azurerm_subnet" "ha_subnet" {
  name                  = "${local.subnet_name_prefix}ha-1043024"       # Name of the HA subnet
  resource_group_name   = azurerm_resource_group.cabbage_rg.name        # Resource group for the subnet
  virtual_network_name  = azurerm_virtual_network.cabbage_vnet.name     # VNet for the subnet
  address_prefixes      = ["10.4.3.0/24"]                               # Address prefix for the HA subnet
}