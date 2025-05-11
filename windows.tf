                                                                                             # Creates a network interface for the Windows VM
resource "azurerm_network_interface" "cabbage_nic" {
  name                            = "${local.network_interface_prefix}001"                   # Name of the network interface
  location                        = var.location                                             # Azure region for deployment
  resource_group_name             = azurerm_resource_group.cabbage_rg.name                   # Resource group for the NIC
  ip_configuration {
    name                          = "${local.private_ip_prefix}001"                          # Name of the IP configuration
    subnet_id                     = azurerm_subnet.trust_subnet.id                           # Trust subnet for the NIC
    private_ip_address_allocation = "Static"                                                 # Static private IP allocation
    private_ip_address            = "10.4.2.20"                                              # Static private IP for Windows VM
  }
}

                                                                                             # Creates a Windows Server 2022 VM instance in Azure
resource "azurerm_windows_virtual_machine" "windows_instance" {
  name                            = "${local.windows_name_prefix}001"                        # Name of the Windows VM
  computer_name                   = "windows-001"                                            # Computer name for the VM
  resource_group_name             = azurerm_resource_group.cabbage_rg.name                   # Resource group for the VM
  location                        = var.location                                             # Azure region for deployment
  size                            = "Standard_D2s_v3"                                        # VM size (compute resources)
  admin_username                  = local.admin_username                                     # Admin username for the VM
  admin_password                  = var.windows_admin_password                               # Admin password for the VM
  network_interface_ids           = [azurerm_network_interface.cabbage_nic.id]               # Network interface for the VM
  os_disk {
    name                          = "${local.diskos_name}001"                                # Name of the OS disk
    caching                       = "ReadWrite"                                              # Disk caching type
    storage_account_type          = "Standard_LRS"                                           # Storage type for the OS disk
  }
  source_image_reference {
    publisher                     = "MicrosoftWindowsServer"                                 # Publisher of the Windows image
    offer                         = "WindowsServer"                                          # Offer for the Windows image
    sku                           = "2022-Datacenter"                                        # SKU for Windows Server 2022
    version                       = "latest"                                                 # Latest version of the image
  }
}

                                                                                             # Disables the Windows firewall on the VM
resource "azurerm_virtual_machine_extension" "disable_firewall" {
  name                            = "DisableFirewall"                                        # Name of the VM extension
  virtual_machine_id              = azurerm_windows_virtual_machine.windows_instance.id      # VM to apply the extension to
  publisher                       = "Microsoft.Compute"                                      # Publisher of the extension
  type                            = "CustomScriptExtension"                                  # Type of the extension
  type_handler_version            = "1.10"                                                   # Version of the extension handler
  auto_upgrade_minor_version      = true                                                     # Auto-upgrade minor versions
  settings                        = <<SETTINGS
    {
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted -Command \"Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False; Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False > C:\\firewall_status.txt\""
    }
  SETTINGS
}

                                                                                             # Outputs the private IP of the Windows VM for internal networking
output "azure_vm_private_ip" {
  value                           = azurerm_network_interface.cabbage_nic.private_ip_address # Private IP address of the VM
  description                     = "Private IP of the Azure Windows VM"                     # Description of the output
}

                                                                                             # Outputs the admin username for the Windows VM
output "azure_vm_admin_username" {
  value                           = local.admin_username                                     # Admin username for the VM
  description                     = "Admin username for the Azure Windows VM"                # Description of the output
}