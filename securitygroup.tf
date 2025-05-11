                                                                                     # Creates a network security group for the management subnet
resource "azurerm_network_security_group" "mgmt_nsg" {
  name                          = "${local.security_group_name_prefix}mgmt-001"      # Name of the management NSG
  location                      = var.location                                       # Azure region for deployment
  resource_group_name           = azurerm_resource_group.cabbage_rg.name             # Resource group for the NSG
  security_rule {
    name                        = "allow-https"                                      # Rule to allow HTTPS
    priority                    = 100                                                # Rule priority
    direction                   = "Inbound"                                          # Direction of traffic
    access                      = "Allow"                                            # Allow traffic
    protocol                    = "Tcp"                                              # Protocol for HTTPS
    source_port_range           = "*"                                                # Source port range
    destination_port_range      = "443"                                              # Destination port for HTTPS
    source_address_prefix       = var.my_public_ip                                   # Source IP for management access
    destination_address_prefix  = "*"                                                # Destination IP range
  }
  security_rule {
    name                        = "allow-ssh"                                        # Rule to allow SSH
    priority                    = 101                                                # Rule priority
    direction                   = "Inbound"                                          # Direction of traffic
    access                      = "Allow"                                            # Allow traffic
    protocol                    = "Tcp"                                              # Protocol for SSH
    source_port_range           = "*"                                                # Source port range
    destination_port_range      = "22"                                               # Destination port for SSH
    source_address_prefix       = var.my_public_ip                                   # Source IP for management access
    destination_address_prefix  = "*"                                                # Destination IP range
  }
}

                                                                                     # Creates a network security group for the untrust subnet
resource "azurerm_network_security_group" "untrust_nsg" {
  name                          = "${local.security_group_name_prefix}untrust-001"   # Name of the untrust NSG
  location                      = var.location                                       # Azure region for deployment
  resource_group_name           = azurerm_resource_group.cabbage_rg.name             # Resource group for the NSG
  security_rule {
    name                        = "allow-all-inbound"                                # Rule to allow all inbound traffic
    priority                    = 100                                                # Rule priority
    direction                   = "Inbound"                                          # Direction of traffic
    access                      = "Allow"                                            # Allow traffic
    protocol                    = "*"                                                # All protocols
    source_port_range           = "*"                                                # Source port range
    destination_port_range      = "*"                                                # Destination port range
    source_address_prefix       = "0.0.0.0/0"                                        # Source IP range
    destination_address_prefix  = "0.0.0.0/0"                                        # Destination IP range
  }
  security_rule {
    name                        = "allow-all-outbound"                               # Rule to allow all outbound traffic
    priority                    = 101                                                # Rule priority
    direction                   = "Outbound"                                         # Direction of traffic
    access                      = "Allow"                                            # Allow traffic
    protocol                    = "*"                                                # All protocols
    source_port_range           = "*"                                                # Source port range
    destination_port_range      = "*"                                                # Destination port range
    source_address_prefix       = "0.0.0.0/0"                                        # Source IP range
    destination_address_prefix  = "0.0.0.0/0"                                        # Destination IP range
  }
}

                                                                                     # Creates a network security group for the trust subnet
resource "azurerm_network_security_group" "trust_nsg" {
  name                          = "${local.security_group_name_prefix}trust-001"     # Name of the trust NSG
  location                      = var.location                                       # Azure region for deployment
  resource_group_name           = azurerm_resource_group.cabbage_rg.name             # Resource group for the NSG
  security_rule {
    name                        = "allow-all-inbound"                                # Rule to allow all inbound traffic
    priority                    = 100                                                # Rule priority
    direction                   = "Inbound"                                          # Direction of traffic
    access                      = "Allow"                                            # Allow traffic
    protocol                    = "*"                                                # All protocols
    source_port_range           = "*"                                                # Source port range
    destination_port_range      = "*"                                                # Destination port range
    source_address_prefix       = "0.0.0.0/0"                                        # Source IP range
    destination_address_prefix  = "0.0.0.0/0"                                        # Destination IP range
  }
  security_rule {
    name                        = "allow-all-outbound"                               # Rule to allow all outbound traffic
    priority                    = 101                                                # Rule priority
    direction                   = "Outbound"                                         # Direction of traffic
    access                      = "Allow"                                            # Allow traffic
    protocol                    = "*"                                                # All protocols
    source_port_range           = "*"                                                # Source port range
    destination_port_range      = "*"                                                # Destination port range
    source_address_prefix       = "0.0.0.0/0"                                        # Source IP range
    destination_address_prefix  = "0.0.0.0/0"                                        # Destination IP range
  }
}

                                                                                     # Associates the management NSG with the management subnet
resource "azurerm_subnet_network_security_group_association" "mgmt_nsg_subnet" {
  subnet_id                     = azurerm_subnet.mgmt_subnet.id                      # Management subnet
  network_security_group_id     = azurerm_network_security_group.mgmt_nsg.id         # Management NSG
}

                                                                                     # Associates the untrust NSG with the untrust subnet
resource "azurerm_subnet_network_security_group_association" "untrust_nsg_subnet" {
  subnet_id                     = azurerm_subnet.untrust_subnet.id                   # Untrust subnet
  network_security_group_id     = azurerm_network_security_group.untrust_nsg.id      # Untrust NSG
}

                                                                                     # Associates the trust NSG with the trust subnet
resource "azurerm_subnet_network_security_group_association" "trust_nsg_subnet" {
  subnet_id                     = azurerm_subnet.trust_subnet.id                     # Trust subnet
  network_security_group_id     = azurerm_network_security_group.trust_nsg.id        # Trust NSG
}