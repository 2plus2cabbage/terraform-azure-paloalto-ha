                                                                                               # Accepts the Marketplace terms for the Palo Alto VM-Series image
resource "azurerm_marketplace_agreement" "paloalto" {
  publisher                         = var.firewall_image_publisher                             # Publisher for VM-Series (paloaltonetworks)
  offer                             = var.firewall_image_offer                                 # Offer for VM-Series (vmseries-flex)
  plan                              = var.firewall_image_sku                                   # Plan for VM-Series (byol)
}

                                                                                               # Creates public IP for the management interface of Firewall A
resource "azurerm_public_ip" "fw_mgmt_pip_a" {
  name                              = "${local.public_ip_prefix}fw-mgmt-001"                   # Name of the public IP (e.g., pip-cabbage-eastus-fw-mgmt-001)
  location                          = var.location                                             # Azure region for deployment
  resource_group_name               = azurerm_resource_group.cabbage_rg.name                   # Resource group for the public IP
  allocation_method                 = "Static"                                                 # Static allocation for management access
  sku                               = "Standard"                                               # SKU for the public IP
}

                                                                                               # Creates public IP for the management interface of Firewall B
resource "azurerm_public_ip" "fw_mgmt_pip_b" {
  name                              = "${local.public_ip_prefix}fw-mgmt-002"                   # Name of the public IP (e.g., pip-cabbage-eastus-fw-mgmt-002)
  location                          = var.location                                             # Azure region for deployment
  resource_group_name               = azurerm_resource_group.cabbage_rg.name                   # Resource group for the public IP
  allocation_method                 = "Static"                                                 # Static allocation for management access
  sku                               = "Standard"                                               # SKU for the public IP
}

                                                                                               # Creates public IP for the floating untrust interface (shared across HA pair)
resource "azurerm_public_ip" "fw_untrust_floating_pip" {
  name                              = "${local.public_ip_prefix}fw-untrust-floating-001"       # Name of the public IP (e.g., pip-cabbage-eastus-fw-untrust-floating-001)
  location                          = var.location                                             # Azure region for deployment
  resource_group_name               = azurerm_resource_group.cabbage_rg.name                   # Resource group for the public IP
  allocation_method                 = "Static"                                                 # Static allocation for untrust floating IP
  sku                               = "Standard"                                               # SKU for the public IP
}

                                                                                               # Creates management network interface for Firewall A
resource "azurerm_network_interface" "fw_mgmt_nic_a" {
  name                              = "${local.network_interface_prefix}fw-mgmt-001"           # Name of the NIC (e.g., nic-cabbage-eastus-fw-mgmt-001)
  location                          = var.location                                             # Azure region for deployment
  resource_group_name               = azurerm_resource_group.cabbage_rg.name                   # Resource group for the NIC
  ip_configuration {
    name                            = "${local.private_ip_prefix}fw-mgmt-001"                  # Name of the IP config
    subnet_id                       = azurerm_subnet.mgmt_subnet.id                            # Management subnet
    private_ip_address_allocation   = "Static"                                                 # Static private IP allocation
    private_ip_address              = "10.4.0.10"                                              # Static IP for Firewall A management
    public_ip_address_id            = azurerm_public_ip.fw_mgmt_pip_a.id                       # Public IP for management access
  }
}

                                                                                               # Creates management network interface for Firewall B
resource "azurerm_network_interface" "fw_mgmt_nic_b" {
  name                              = "${local.network_interface_prefix}fw-mgmt-002"           # Name of the NIC (e.g., nic-cabbage-eastus-fw-mgmt-002)
  location                          = var.location                                             # Azure region for deployment
  resource_group_name               = azurerm_resource_group.cabbage_rg.name                   # Resource group for the NIC
  ip_configuration {
    name                            = "${local.private_ip_prefix}fw-mgmt-002"                  # Name of the IP config
    subnet_id                       = azurerm_subnet.mgmt_subnet.id                            # Management subnet
    private_ip_address_allocation   = "Static"                                                 # Static private IP allocation
    private_ip_address              = "10.4.0.11"                                              # Static IP for Firewall B management
    public_ip_address_id            = azurerm_public_ip.fw_mgmt_pip_b.id                       # Public IP for management access
  }
}

                                                                                               # Creates untrust network interface for Firewall A with floating IP
resource "azurerm_network_interface" "fw_untrust_nic_a" {
  name                              = "${local.network_interface_prefix}fw-untrust-001"        # Name of the NIC (e.g., nic-cabbage-eastus-fw-untrust-001)
  location                          = var.location                                             # Azure region for deployment
  resource_group_name               = azurerm_resource_group.cabbage_rg.name                   # Resource group for the NIC
  ip_forwarding_enabled             = true                                                     # Enable IP forwarding for routing
  ip_configuration {
    name                            = "${local.private_ip_prefix}fw-untrust-001-primary"       # Primary IP config
    subnet_id                       = azurerm_subnet.untrust_subnet.id                         # Untrust subnet
    private_ip_address_allocation   = "Static"                                                 # Static private IP allocation
    private_ip_address              = "10.4.1.10"                                              # Static IP for Firewall A untrust
    primary                         = true                                                     # Designate as primary
  }
  ip_configuration {
    name                            = "${local.private_ip_prefix}fw-untrust-001-floating"      # Floating IP config
    subnet_id                       = azurerm_subnet.untrust_subnet.id                         # Untrust subnet
    private_ip_address_allocation   = "Static"                                                 # Static private IP allocation
    private_ip_address              = "10.4.1.110"                                             # Floating IP for untrust
    public_ip_address_id            = azurerm_public_ip.fw_untrust_floating_pip.id             # Floating public IP for untrust
  }
}

                                                                                               # Creates untrust network interface for Firewall B
resource "azurerm_network_interface" "fw_untrust_nic_b" {
  name                              = "${local.network_interface_prefix}fw-untrust-002"        # Name of the NIC (e.g., nic-cabbage-eastus-fw-untrust-002)
  location                          = var.location                                             # Azure region for deployment
  resource_group_name               = azurerm_resource_group.cabbage_rg.name                   # Resource group for the NIC
  ip_forwarding_enabled             = true                                                     # Enable IP forwarding for routing
  ip_configuration {
    name                            = "${local.private_ip_prefix}fw-untrust-002"               # IP config
    subnet_id                       = azurerm_subnet.untrust_subnet.id                         # Untrust subnet
    private_ip_address_allocation   = "Static"                                                 # Static private IP allocation
    private_ip_address              = "10.4.1.11"                                              # Static IP for Firewall B untrust
    primary                         = true                                                     # Designate as primary
  }
}

                                                                                               # Creates trust network interface for Firewall A with floating IP
resource "azurerm_network_interface" "fw_trust_nic_a" {
  name                              = "${local.network_interface_prefix}fw-trust-001"          # Name of the NIC (e.g., nic-cabbage-eastus-fw-trust-001)
  location                          = var.location                                             # Azure region for deployment
  resource_group_name               = azurerm_resource_group.cabbage_rg.name                   # Resource group for the NIC
  ip_forwarding_enabled             = true                                                     # Enable IP forwarding for routing
  ip_configuration {
    name                            = "${local.private_ip_prefix}fw-trust-001-primary"         # Primary IP config
    subnet_id                       = azurerm_subnet.trust_subnet.id                           # Trust subnet
    private_ip_address_allocation   = "Static"                                                 # Static private IP allocation
    private_ip_address              = "10.4.2.10"                                              # Static IP for Firewall A trust
    primary                         = true                                                     # Designate as primary
  }
  ip_configuration {
    name                            = "${local.private_ip_prefix}fw-trust-001-floating"        # Floating IP config
    subnet_id                       = azurerm_subnet.trust_subnet.id                           # Trust subnet
    private_ip_address_allocation   = "Static"                                                 # Static private IP allocation
    private_ip_address              = "10.4.2.110"                                             # Floating IP for trust
  }
}

                                                                                               # Creates trust network interface for Firewall B
resource "azurerm_network_interface" "fw_trust_nic_b" {
  name                              = "${local.network_interface_prefix}fw-trust-002"          # Name of the NIC (e.g., nic-cabbage-eastus-fw-trust-002)
  location                          = var.location                                             # Azure region for deployment
  resource_group_name               = azurerm_resource_group.cabbage_rg.name                   # Resource group for the NIC
  ip_forwarding_enabled             = true                                                     # Enable IP forwarding for routing
  ip_configuration {
    name                            = "${local.private_ip_prefix}fw-trust-002"                 # IP config
    subnet_id                       = azurerm_subnet.trust_subnet.id                           # Trust subnet
    private_ip_address_allocation   = "Static"                                                 # Static private IP allocation
    private_ip_address              = "10.4.2.11"                                              # Static IP for Firewall B trust
    primary                         = true                                                     # Designate as primary
  }
}

                                                                                               # Creates HA1 network interface for Firewall A
resource "azurerm_network_interface" "fw_ha1_nic_a" {
  name                              = "${local.network_interface_prefix}fw-ha1-001"            # Name of the NIC (e.g., nic-cabbage-eastus-fw-ha1-001)
  location                          = var.location                                             # Azure region for deployment
  resource_group_name               = azurerm_resource_group.cabbage_rg.name                   # Resource group for the NIC
  ip_configuration {
    name                            = "${local.private_ip_prefix}fw-ha1-001"                   # Name of the IP config
    subnet_id                       = azurerm_subnet.ha_subnet.id                              # HA subnet
    private_ip_address_allocation   = "Static"                                                 # Static private IP allocation
    private_ip_address              = "10.4.3.10"                                              # Static IP for Firewall A HA1
  }
}

                                                                                               # Creates HA1 network interface for Firewall B
resource "azurerm_network_interface" "fw_ha1_nic_b" {
  name                              = "${local.network_interface_prefix}fw-ha1-002"            # Name of the NIC (e.g., nic-cabbage-eastus-fw-ha1-002)
  location                          = var.location                                             # Azure region for deployment
  resource_group_name               = azurerm_resource_group.cabbage_rg.name                   # Resource group for the NIC
  ip_configuration {
    name                            = "${local.private_ip_prefix}fw-ha1-002"                   # Name of the IP config
    subnet_id                       = azurerm_subnet.ha_subnet.id                              # HA subnet
    private_ip_address_allocation   = "Static"                                                 # Static private IP allocation
    private_ip_address              = "10.4.3.11"                                              # Static IP for Firewall B HA1
  }
}

                                                                                               # Creates HA2 network interface for Firewall A
resource "azurerm_network_interface" "fw_ha2_nic_a" {
  name                              = "${local.network_interface_prefix}fw-ha2-001"            # Name of the NIC (e.g., nic-cabbage-eastus-fw-ha2-001)
  location                          = var.location                                             # Azure region for deployment
  resource_group_name               = azurerm_resource_group.cabbage_rg.name                   # Resource group for the NIC
  ip_configuration {
    name                            = "${local.private_ip_prefix}fw-ha2-001"                   # Name of the IP config
    subnet_id                       = azurerm_subnet.ha_subnet.id                              # HA subnet
    private_ip_address_allocation   = "Static"                                                 # Static private IP allocation
    private_ip_address              = "10.4.3.110"                                             # Static IP for Firewall A HA2
  }
}

                                                                                               # Creates HA2 network interface for Firewall B
resource "azurerm_network_interface" "fw_ha2_nic_b" {
  name                              = "${local.network_interface_prefix}fw-ha2-002"            # Name of the NIC (e.g., nic-cabbage-eastus-fw-ha2-002)
  location                          = var.location                                             # Azure region for deployment
  resource_group_name               = azurerm_resource_group.cabbage_rg.name                   # Resource group for the NIC
  ip_configuration {
    name                            = "${local.private_ip_prefix}fw-ha2-002"                   # Name of the IP config
    subnet_id                       = azurerm_subnet.ha_subnet.id                              # HA subnet
    private_ip_address_allocation   = "Static"                                                 # Static private IP allocation
    private_ip_address              = "10.4.3.111"                                             # Static IP for Firewall B HA2
  }
}

                                                                                               # Creates Firewall A (Palo Alto VM-Series)
resource "azurerm_virtual_machine" "fw_a" {
  name                              = "${local.firewall_name_prefix}001"                       # Name of the firewall (e.g., fw-cabbage-eastus-001)
  location                          = var.location                                             # Azure region for deployment
  resource_group_name               = azurerm_resource_group.cabbage_rg.name                   # Resource group for the VM
  vm_size                           = "Standard_D4_v2"                                         # VM size for the firewall (supports 5 NICs)
  plan {
    publisher                       = var.firewall_image_publisher                             # Publisher for VM-Series plan
    product                         = var.firewall_image_offer                                 # Offer for VM-Series plan
    name                            = var.firewall_image_sku                                   # SKU for VM-Series plan
  }
  network_interface_ids             = [
    azurerm_network_interface.fw_mgmt_nic_a.id,
    azurerm_network_interface.fw_untrust_nic_a.id,
    azurerm_network_interface.fw_trust_nic_a.id,
    azurerm_network_interface.fw_ha1_nic_a.id,
    azurerm_network_interface.fw_ha2_nic_a.id
  ]                                                                                            # Network interfaces for mgmt, untrust, trust, HA1, HA2
  primary_network_interface_id      = azurerm_network_interface.fw_mgmt_nic_a.id               # Primary NIC for management
  delete_os_disk_on_termination     = true                                                     # Delete OS disk on VM deletion
  delete_data_disks_on_termination  = true                                                     # Delete data disks on VM deletion
  storage_image_reference {
    publisher                       = var.firewall_image_publisher                             # Publisher for VM-Series image
    offer                           = var.firewall_image_offer                                 # Offer for VM-Series image
    sku                             = var.firewall_image_sku                                   # SKU for VM-Series image
    version                         = var.firewall_image_version                               # Version for VM-Series image
  }
  storage_os_disk {
    name                            = "${local.diskos_name}fw-001"                             # Name of the OS disk
    caching                         = "ReadWrite"                                              # Disk caching type
    create_option                   = "FromImage"                                              # Create from image
    managed_disk_type               = "Standard_LRS"                                           # Storage type for the OS disk
  }
  os_profile {
    computer_name                   = "fw-001"                                                 # Computer name for the firewall
    admin_username                  = var.firewall_admin_username                              # Admin username for the firewall
    admin_password                  = var.firewall_admin_password                              # Admin password for the firewall
  }
  os_profile_linux_config {
    disable_password_authentication = false                                                    # Enable password authentication
  }
  depends_on                        = [azurerm_marketplace_agreement.paloalto]                 # Ensure Marketplace terms are accepted
}

                                                                                               # Creates Firewall B (Palo Alto VM-Series)
resource "azurerm_virtual_machine" "fw_b" {
  name                              = "${local.firewall_name_prefix}002"                       # Name of the firewall (e.g., fw-cabbage-eastus-002)
  location                          = var.location                                             # Azure region for deployment
  resource_group_name               = azurerm_resource_group.cabbage_rg.name                   # Resource group for the VM
  vm_size                           = "Standard_D4_v2"                                         # VM size for the firewall (supports 5 NICs)
  plan {
    publisher                       = var.firewall_image_publisher                             # Publisher for VM-Series plan
    product                         = var.firewall_image_offer                                 # Offer for VM-Series plan
    name                            = var.firewall_image_sku                                   # SKU for VM-Series plan
  }
  network_interface_ids             = [
    azurerm_network_interface.fw_mgmt_nic_b.id,
    azurerm_network_interface.fw_untrust_nic_b.id,
    azurerm_network_interface.fw_trust_nic_b.id,
    azurerm_network_interface.fw_ha1_nic_b.id,
    azurerm_network_interface.fw_ha2_nic_b.id
  ]                                                                                            # Network interfaces for mgmt, untrust, trust, HA1, HA2
  primary_network_interface_id      = azurerm_network_interface.fw_mgmt_nic_b.id               # Primary NIC for management
  delete_os_disk_on_termination     = true                                                     # Delete OS disk on VM deletion
  delete_data_disks_on_termination  = true                                                     # Delete data disks on VM deletion
  storage_image_reference {
    publisher                       = var.firewall_image_publisher                             # Publisher for VM-Series image
    offer                           = var.firewall_image_offer                                 # Offer for VM-Series image
    sku                             = var.firewall_image_sku                                   # SKU for VM-Series image
    version                         = var.firewall_image_version                               # Version for VM-Series image
  }
  storage_os_disk {
    name                            = "${local.diskos_name}fw-002"                             # Name of the OS disk
    caching                         = "ReadWrite"                                              # Disk caching type
    create_option                   = "FromImage"                                              # Create from image
    managed_disk_type               = "Standard_LRS"                                           # Storage type for the OS disk
  }
  os_profile {
    computer_name                   = "fw-002"                                                 # Computer name for the firewall
    admin_username                  = var.firewall_admin_username                              # Admin username for the firewall
    admin_password                  = var.firewall_admin_password                              # Admin password for the firewall
  }
  os_profile_linux_config {
    disable_password_authentication = false                                                    # Enable password authentication
  }
  depends_on                        = [azurerm_marketplace_agreement.paloalto]                 # Ensure Marketplace terms are accepted
}

                                                                                               # Outputs the management public IP for Firewall A
output "firewall_a_mgmt_public_ip" {
  value                             = azurerm_public_ip.fw_mgmt_pip_a.ip_address               # Public IP for Firewall A management
  description                       = "Management public IP for Firewall A (fw-cabbage-eastus-001)"
}

                                                                                               # Outputs the management public IP for Firewall B
output "firewall_b_mgmt_public_ip" {
  value                             = azurerm_public_ip.fw_mgmt_pip_b.ip_address               # Public IP for Firewall B management
  description                       = "Management public IP for Firewall B (fw-cabbage-eastus-002)"
}

                                                                                               # Outputs the floating public IP for the untrust interface
output "fw_untrust_floating_public_ip" {
  value                             = azurerm_public_ip.fw_untrust_floating_pip.ip_address     # Floating public IP for untrust
  description                       = "Floating public IP for the untrust interface of the Palo Alto firewalls"
}

                                                                                               # Outputs the floating IP for the untrust interface
output "fw_untrust_floating_ip" {
  value                             = "10.4.1.110"                                             # Floating private IP for untrust
  description                       = "Floating private IP for the untrust interface of the Palo Alto firewalls"
}

                                                                                               # Outputs the floating IP for the trust interface
output "fw_trust_floating_ip" {
  value                             = "10.4.2.110"                                             # Floating private IP for trust
  description                       = "Floating private IP for the trust interface of the Palo Alto firewalls"
}