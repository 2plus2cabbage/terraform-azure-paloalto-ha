<img align="right" width="150" src="https://github.com/2plus2cabbage/2plus2cabbage/blob/main/images/2plus2cabbage.png">

<img src="https://github.com/2plus2cabbage/2plus2cabbage/blob/main/images/azure-paloalto-ha.png" alt="azure-paloalto-ha" width="300" align="left">
<br clear="left">

# Azure Palo Alto Firewall HA and Windows VM Terraform Deployment

Deploys two Palo Alto VM-Series firewalls in an active/passive high availability (HA) configuration and a Windows Server 2022 VM in Microsoft Azure. The Windows VM resides in a trust subnet, with all traffic routed through the firewalls for security.

## Files
- `main.tf`: Terraform provider block (`hashicorp/azurerm`).
- `azureprovider.tf`: Azure provider config with `subscription_id`, `client_id`, etc.
- `variables.tf`: Variables for subscription, region, firewall settings, etc.
- `terraform.tfvars.template`: Template for sensitive/custom values; rename to `terraform.tfvars`.
- `locals.tf`: Local variables for naming conventions.
- `resourcegroup.tf`: Resource group for all resources.
- `azure-networking.tf`: VNet and subnets (management, untrust, trust, HA) with CIDRs.
- `firewall.tf`: Palo Alto VM-Series firewalls, network interfaces with secondary IPs, and HA setup.
- `securitygroup.tf`: Network security groups for management (HTTPS/SSH), untrust (all traffic), and trust (all traffic, secured by firewall).
- `routing-static.tf`: Route tables for trust (to firewall), untrust (to internet), and HA (isolated to subnet).
- `windows.tf`: Windows VM in trust subnet, with firewall disabled and no public IP.

## How It Works
- **Networking**: VNet (`10.4.0.0/16`) with subnets:
  - Management (`10.4.0.0/24`): Firewall management interfaces with public IPs.
  - Untrust (`10.4.1.0/24`): Firewall external interfaces with secondary floating IP (`10.4.1.110`).
  - Trust (`10.4.2.0/24`): Windows VM, routed through firewall’s trust floating IP (`10.4.2.110`).
  - HA (`10.4.3.0/24`): Firewall HA communication, isolated to subnet.
- **Security**:
  - Management NSG allows HTTPS (443) and SSH (22) from your IP.
  - Untrust and trust NSGs allow all traffic, with Palo Alto firewall enforcing security.
  - Windows VM’s firewall is disabled, as Palo Alto handles security.
- **Firewalls**: Two Palo Alto VM-Series firewalls in active/passive HA, using secondary IPs (`10.4.1.110`, `10.4.2.110`) managed by the Azure plugin for failover.
- **Routing**: Trust subnet routes all traffic to `10.4.2.110`. Untrust subnet routes to the internet. HA subnet is isolated to intra-subnet traffic.
- **Instance**: Windows Server 2022 VM in trust subnet, accessible via firewall (e.g., NAT or VPN).

## Prerequisites
- Azure account with a subscription.
- App Registration with `Contributor` role for Terraform and Azure plugin, noting `subscription_id`, `client_id`, `client_secret`, `tenant_id`.
- Palo Alto VM-Series licensing (BYOL or PAYG; set `firewall_image_sku` in `terraform.tfvars`).
- Terraform installed.
- Sufficient Azure quota for CPU cores (18 cores for East US); request increase if needed at https://docs.microsoft.com/en-us/azure/azure-supportability/regional-quota-requests.

## Deployment Steps
1. Copy `terraform.tfvars.template` to `terraform.tfvars` and update:
   - Azure credentials (`subscription_id`, `client_id`, `client_secret`, `tenant_id`).
   - `environment_name`, `location`, `my_public_ip` (your IP for management).
   - `windows_admin_password`, `firewall_admin_password`.
   - Firewall settings (e.g., `firewall_image_sku = "byol"`).
2. Run `terraform init` to initialize provider.
3. Run `terraform plan` (optional) to preview, then `terraform apply` (type `yes`).
4. Get management IPs: `terraform output firewall_a_mgmt_public_ip`, `firewall_b_mgmt_public_ip`, and untrust floating public IP: `terraform output fw_untrust_floating_public_ip`.
5. Access firewalls via HTTPS (443) or SSH (22) using management IPs and credentials (`firewall_admin_username`, `firewall_admin_password`).
6. Configure Palo Alto firewalls:
   - Install Azure plugin (built-in with PAN-OS 11.2.3-h3).
   - GUI: `Device` > `VM-Series` > `Azure`, set:
     - `client_id`, `client_secret`, `tenant_id`, `subscription_id`.
     - Resource Group: `rg-<environment_name>-<location>-001`.
     - Floating IPs: `10.4.1.110,10.4.2.110`.
     - HA Peer IP: `10.4.3.11` (Firewall A), `10.4.3.10` (Firewall B).
   - Configure untrust interface (`ethernet1/1`): Add `10.4.1.110/24`, `10.4.1.10/32`, `10.4.1.11/32`.
   - Set HA: `Device` > `High Availability` > `General`, enable active/passive, HA1 (`ethernet1/3`), HA2 (`ethernet1/4`).
7. Get Windows VM private IP: `terraform output azure_vm_private_ip`, admin username: `terraform output azure_vm_admin_username`.
8. Access Windows VM via RDP through firewall (e.g., NAT or VPN to `10.4.2.x`).
9. To remove resources: `terraform destroy` (type `yes`).

## Potential costs and licensing
- The resources deployed using this Terraform configuration should generally incur minimal to no costs, provided they are terminated promptly after creation.
- It is important to fully understand your cloud provider's billing structure, trial periods, and any potential costs associated with the deployment of resources in public cloud environments.
- You are also responsible for any applicable software licensing or other charges that may arise from the deployment and usage of these resources.