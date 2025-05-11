variable "subscription_id" {
  type        = string           # Azure subscription ID, found in Azure portal under Subscriptions
  description = "Azure subscription ID, found in Azure portal under Subscriptions"
}

variable "client_id" {
  type        = string           # Azure client ID, found in Azure portal under App Registrations
  description = "Azure client ID, found in Azure portal under App Registrations"
}

variable "client_secret" {
  type        = string           # Azure client secret, generated in Azure portal under App Registrations
  description = "Azure client secret, generated in Azure portal under App Registrations"
}

variable "tenant_id" {
  type        = string           # Azure tenant ID, found in Azure portal under Azure Active Directory
  description = "Azure tenant ID, found in Azure portal under Azure Active Directory"
}

variable "environment_name" {
  type        = string           # Name for your environment, used in resource naming
  description = "Name for your environment, used in resource naming"
}

variable "location" {
  type        = string           # Location identifier, used in resource naming
  description = "Location identifier, used in resource naming"
}

variable "my_public_ip" {
  type        = string           # Your public IP for RDP and firewall management access
  description = "Your public IP for RDP and firewall management access"
}

variable "windows_admin_password" {
  type        = string           # Password for the Windows VM admin user
  description = "Password for the Windows VM admin user"
}

variable "firewall_vm_size" {
  type        = string           # VM size for the Palo Alto firewalls
  description = "VM size for the Palo Alto firewalls"
  default     = "Standard_D4_v2" # Default VM size for Palo Alto VM-Series (supports 5 NICs)
}

variable "firewall_image_publisher" {
  type        = string           # Publisher for the Palo Alto VM-Series image
  description = "Publisher for the Palo Alto VM-Series image"
  default     = "paloaltonetworks" # Default publisher for Palo Alto Networks
}

variable "firewall_image_offer" {
  type        = string           # Offer for the Palo Alto VM-Series image
  description = "Offer for the Palo Alto VM-Series image"
  default     = "vmseries-flex"  # Default offer for VM-Series
}

variable "firewall_image_sku" {
  type        = string           # SKU for the Palo Alto VM-Series image (e.g., BYOL or PAYG)
  description = "SKU for the Palo Alto VM-Series image (e.g., BYOL or PAYG)"
  default     = "byol"           # Default to BYOL; can be changed to PAYG in terraform.tfvars
}

variable "firewall_image_version" {
  type        = string           # Version of the Palo Alto VM-Series image
  description = "Version of the Palo Alto VM-Series image"
  default     = "latest"         # Use the latest available version
}

variable "firewall_admin_username" {
  type        = string           # Admin username for the Palo Alto firewalls
  description = "Admin username for the Palo Alto firewalls"
  default     = "fwadmin"        # Default admin username for firewalls
}

variable "firewall_admin_password" {
  type        = string           # Admin password for the Palo Alto firewalls
  description = "Admin password for the Palo Alto firewalls"
}