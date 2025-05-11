                                                                             # Creates route table for the trust subnet
resource "azurerm_route_table" "trust_route_table" {
  name                          = "${local.route_table_prefix}trust-001"     # Name of the route table (e.g., rt-cabbage-eastus-trust-001)
  location                      = var.location                               # Azure region for deployment
  resource_group_name           = azurerm_resource_group.cabbage_rg.name     # Resource group for the route table
  route {
    name                        = "default_to_firewall"                      # Route name
    address_prefix              = "0.0.0.0/0"                                # Route all traffic
    next_hop_type               = "VirtualAppliance"                         # Next hop is a virtual appliance
    next_hop_in_ip_address      = "10.4.2.110"                               # Trust floating IP
  }
}

                                                                             # Creates route table for the untrust subnet
resource "azurerm_route_table" "untrust_route_table" {
  name                          = "${local.route_table_prefix}untrust-001"   # Name of the route table (e.g., rt-cabbage-eastus-untrust-001)
  location                      = var.location                               # Azure region for deployment
  resource_group_name           = azurerm_resource_group.cabbage_rg.name     # Resource group for the route table
  route {
    name                        = "default_to_internet"                      # Route name
    address_prefix              = "0.0.0.0/0"                                # Route all traffic
    next_hop_type               = "Internet"                                 # Next hop is the internet
  }
}

                                                                             # Creates route table for the HA subnet
resource "azurerm_route_table" "ha_route_table" {
  name                          = "${local.route_table_prefix}ha-001"        # Name of the route table (e.g., rt-cabbage-eastus-ha-001)
  location                      = var.location                               # Azure region for deployment
  resource_group_name           = azurerm_resource_group.cabbage_rg.name     # Resource group for the route table
  route {
    name                        = "local_subnet"                             # Route name
    address_prefix              = "10.4.3.0/24"                              # HA subnet CIDR
    next_hop_type               = "VnetLocal"                                # Route within the VNet
  }
}

                                                                             # Associates the trust route table with the trust subnet
resource "azurerm_subnet_route_table_association" "trust_subnet_association" {
  subnet_id                     = azurerm_subnet.trust_subnet.id             # Trust subnet
  route_table_id                = azurerm_route_table.trust_route_table.id   # Trust route table
}

                                                                             # Associates the untrust route table with the untrust subnet
resource "azurerm_subnet_route_table_association" "untrust_subnet_association" {
  subnet_id                     = azurerm_subnet.untrust_subnet.id           # Untrust subnet
  route_table_id                = azurerm_route_table.untrust_route_table.id # Untrust route table
}

                                                                             # Associates the HA route table with the HA subnet
resource "azurerm_subnet_route_table_association" "ha_subnet_association" {
  subnet_id                     = azurerm_subnet.ha_subnet.id                # HA subnet
  route_table_id                = azurerm_route_table.ha_route_table.id      # HA route table
}