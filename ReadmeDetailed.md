# Detailed Guide - Azure High Availability Firewall and Windows Server Terraform Deployment

This project deploys a high availability (HA) setup with two Palo Alto VM-Series firewalls and a Windows Server 2022 instance in Microsoft Azure. The firewalls are configured in an active/passive HA pair, each with five interfaces: management, untrust, trust, HA1, and HA2. The Windows Server resides in the trust subnet and accesses the internet through the active firewall, ensuring secure and resilient connectivity.

## Project Overview
This Terraform deployment creates a robust network architecture in Azure, featuring:
- A Virtual Network (VNet) with four subnets for distinct traffic types.
- Two Palo Alto firewalls in an HA configuration to ensure failover and redundancy.
- A Windows Server 2022 instance for testing connectivity through the firewall.
- Network Security Groups (NSGs) and route tables to control traffic flow.
- Azure plugin to manage secondary IPs for HA failover.

### Architecture Details
- **Networking**:
  - VNet CIDR: `10.4.0.0/16`.
  - Subnets:
    - Management: `10.4.0.0/24` – Hosts firewall management interfaces.
    - Untrust: `10.4.1.0/24` – Handles external traffic to/from the internet.
    - Trust: `10.4.2.0/24` – Contains the Windows Server and internal traffic.
    - HA: `10.4.3.0/24` – Dedicated for HA communication between firewalls.
  - Route tables direct trust subnet traffic through the firewall’s trust floating IP (`10.4.2.110`), untrust to the internet, and HA within the subnet.

- **Network Security Groups**:
  - **Management Subnet**: Allows HTTPS (443), SSH (22), and ICMP inbound from your public IP; all outbound permitted.
  - **Untrust Subnet**: Permits all inbound traffic (firewall-controlled) and ICMP from your public IP to `10.4.1.110`; all outbound allowed.
  - **Trust Subnet**: Allows all inbound traffic (firewall-controlled) and all outbound traffic.
  - **HA Subnet**: Permits all traffic within `10.4.3.0/24` for HA communication.

- **Firewalls**:
  - **Firewall A** (Active):
    - Management: `10.4.0.10` (public IP assigned).
    - Untrust: `10.4.1.10` (primary), `10.4.1.110` (secondary, with public IP).
    - Trust: `10.4.2.10` (primary), `10.4.2.110` (secondary).
    - HA1: `10.4.3.10`.
    - HA2: `10.4.3.110`.
  - **Firewall B** (Passive):
    - Management: `10.4.0.11` (public IP assigned).
    - Untrust: `10.4.1.11` (primary).
    - Trust: `10.4.2.11` (primary).
    - HA1: `10.4.3.11`.
    - HA2: `10.4.3.111`.

- **Windows Server**: A Windows Server 2022 VM in the trust subnet at `10.4.2.20`, with no public IP. The firewall is disabled for testing purposes.

- **HA Configuration**:
  - The HA setup uses HA1 for control traffic (heartbeat) and HA2 for state synchronization.
  - The Azure plugin (built-in, PAN-OS 11.2.3-h3) manages secondary IPs (`10.4.1.110`, `10.4.2.110`) during failover via Azure API calls.

## Files
The project is organized into multiple files for modularity and clarity:
- `main.tf`: Specifies Terraform provider requirements.
- `azureprovider.tf`: Configures Azure provider with credentials.
- `variables.tf`: Declares input variables (e.g., subscription, region, firewall settings).
- `terraform.tfvars.template`: Template for user-specific values; rename to `terraform.tfvars`.
- `locals.tf`: Defines naming prefixes for resources.
- `resourcegroup.tf`: Creates the resource group (`rg-<environment-name>-<location>-001`).
- `azure-networking.tf`: Creates VNet and subnets (management, untrust, trust, HA).
- `firewall.tf`: Deploys two VM-Series firewalls with secondary IPs and HA setup.
- `securitygroup.tf`: Defines NSG rules for subnets.
- `routing-static.tf`: Configures route tables for traffic routing.
- `windows.tf`: Deploys Windows VM in trust subnet.
- `firewall-configs\firewall-a-config.xml`: Configuration file for Firewall A.
- `firewall-configs\firewall-b-config.xml`: Configuration file for Firewall B.

## Prerequisites
- Azure account with a subscription.
- App Registration with `Contributor` role for Terraform and Azure plugin, noting `subscription_id`, `client_id`, `client_secret`, `tenant_id`.
- Palo Alto VM-Series licensing (BYOL or PAYG; set in `terraform.tfvars`).
- Terraform installed.
- Visual Studio Code (VSCode) or another IDE for editing Terraform files (recommended).
- CPU core quota (18 cores for East US); request increase at https://docs.microsoft.com/en-us/azure/azure-supportability/regional-quota-requests.
- Your public IP address for NSG rules (used in `my_public_ip`).

## Deployment Steps
### Step 1: Update terraform.tfvars with Azure Credentials and Configuration
1. Copy `terraform.tfvars.template` to `terraform.tfvars`.
2. Open `terraform.tfvars` in an editor (e.g., VSCode).
3. Update the following fields:
   - `subscription_id`: Replace `"<your-subscription-id>"` with your Azure subscription ID.
   - `client_id`: Replace `"<your-client-id>"` with your App Registration client ID.
   - `client_secret`: Replace `"<your-client-secret>"` with your App Registration client secret.
   - `tenant_id`: Replace `"<your-tenant-id>"` with your Azure tenant ID.
   - `environment_name`: Replace `"<your-environment-name>"` with your environment name (e.g., `cabbage`).
   - `location`: Replace `"<your-location>"` with your Azure region (e.g., `eastus`).
   - `my_public_ip`: Replace `"<your-public-ip>"` with your public IP for HTTPS/SSH/ICMP access (e.g., `203.0.113.5/32`).
   - `windows_admin_password`: Replace `"<your-admin-password>"` with the Windows VM admin password.
   - `firewall_admin_password`: Replace `"<your-fw-admin-password>"` with the firewall admin password.
   - `firewall_image_sku`: Replace `"<your-firewall-image-sku>"` with the VM-Series SKU (e.g., `byol`).
4. Save the file.

### Step 2: Initialize and Deploy the Azure Project
1. Open a terminal in the project directory.
2. Run `terraform init` to initialize Terraform and download providers.
3. Run `terraform plan` (optional) to preview changes.
4. Run `terraform apply` and type `yes` to deploy the VNet, subnets, firewalls, and Windows Server.

### Step 3: Retrieve the Firewall Public IPs
1. After deployment, note Terraform outputs:
   - `firewall_a_mgmt_public_ip`: Public IP of Firewall A’s management interface (e.g., `52.123.45.67`).
   - `firewall_b_mgmt_public_ip`: Public IP of Firewall B’s management interface (e.g., `52.123.45.68`).
   - `fw_untrust_floating_public_ip`: Public IP of the untrust floating IP (e.g., `52.123.45.69`).
2. Alternatively, find IPs in the Azure Portal:
   - Go to **Virtual Machines**.
   - Locate `fw-<environment-name>-<location>-001` (Firewall A) and `fw-<environment-name>-<location>-002` (Firewall B).
   - Note the public IPs under **Networking**.

### Step 4: SSH to the Firewall Management Interface and Change Admin Password
1. Open a terminal.
2. Connect to Firewall A: `ssh -i <private-key-file> fwadmin@<firewall_a_mgmt_public_ip>` (e.g., `ssh -i azure_key fwadmin@52.123.45.67`).
3. Enter configuration mode: `configure`.
4. Change admin password: `set mgt-config users fwadmin password`.
5. Enter new password, confirm, and commit: `commit`.
6. Exit: `exit`.
7. Repeat for Firewall B using `firewall_b_mgmt_public_ip`.

### Step 5: Update MY-PUBLIC-IP in the XML Configuration File
1. Open `firewall-configs\firewall-a-config.xml` and `firewall-configs\firewall-b-config.xml` in an editor (e.g., VSCode).
2. Replace placeholder IP `5.5.5.5/32` with your public IP (same as `my_public_ip` in `terraform.tfvars`, e.g., `203.0.113.5/32`).
   - Search for `<ip-netmask>5.5.5.5/32</ip-netmask>` under `MY-PUBLIC-IP`.
   - Replace with `<ip-netmask>203.0.113.5/32</ip-netmask>`.
3. Save the files.

### Step 6: Import the XML Configuration to the Firewall via GUI
1. Access Firewall A’s GUI: `https://<firewall_a_mgmt_public_ip>` (e.g., `https://52.123.45.67`).
2. Log in with `fwadmin` and the password set in Step 4.
3. Go to **Device > Setup > Operations > Import Named Configuration Snapshot**.
4. Click **Choose File**, select `firewall-configs\firewall-a-config.xml`, and click **OK**.
5. Go to **Device > Setup > Operations > Load Named Configuration Snapshot**, select the file, and click **Load**.
6. Click **Commit**. Note: Admin password resets to `2Plus2cabbage!` after import.
7. Repeat for Firewall B using `https://<firewall_b_mgmt_public_ip>` and `firewall-configs\firewall-b-config.xml`.

### Step 7: Configure Firewall Azure Plugin
1. Log in to Firewall A’s GUI with `fwadmin`/`2Plus2cabbage!`.
2. Configure Azure plugin:
   - Go to **Device > VM-Series > Azure**.
   - Set `client_id`, `client_secret`, `tenant_id`, `subscription_id`.
   - Resource Group: `rg-<environment-name>-<location>-001`.
   - Floating IPs: `10.4.1.110,10.4.2.110`.
3. Commit changes.
4. Firewall B’s plugin settings sync automatically via HA.

### Step 8: Access the Windows Server via RDP
1. Use `terraform output fw_untrust_floating_public_ip` (e.g., `52.123.45.69`), port 3389, username from `terraform output azure_vm_admin_username`, and password from `terraform.tfvars`.
2. Open Remote Desktop client, connect to the public IP.

### Step 9: Verify Connectivity from the Windows Server
1. On the Windows Server, open Command Prompt or PowerShell.
2. Test internet access: `ping google.com`. Confirm connectivity.

### Step 10: Initiate Failover from Firewall A to Firewall B
1. In Firewall A’s GUI, go to **Device > High Availability > Operational Commands**.
2. Click **Suspend local device** to trigger failover to Firewall B.
3. Verify RDP connection to the Windows Server automatically reconnects.

### Step 11: Clean Up Resources
1. In the terminal, run `terraform destroy`. Type `yes` to confirm.
2. Verify in Azure Portal that all resources (VNet, subnets, VMs) are deleted.

## Potential Costs and Licensing
- Azure resources (firewall instances: Standard_D4_v2, Windows VM) may incur compute and storage charges.
- Check Azure pricing for instances and Marketplace images.
- You are responsible for Palo Alto VM-Series licensing (BYOL or PAYG) and Windows Server licensing.