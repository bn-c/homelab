# Homelab IaC

This repository contains the Infrastructure as Code (OpenTofu) and Configuration as Code (Ansible) for managing a Proxmox homelab.

## Directory Structure

- `tofu/`: Contains the OpenTofu code to provision Virtual Machines and LXC containers on Proxmox.
- `ansible/`: Contains Ansible playbooks and inventory to configure the provisioned infrastructure.
- `.env`: Stores environment variables and secrets (like Proxmox API tokens). Note: `.env` is intentionally ignored in source control (if used).

## Getting Started

### 1. Generating a Proxmox API Token

To allow OpenTofu to securely manage your Proxmox server without using the root password, you should create an API token:

1. Log into your Proxmox Web UI (e.g. `https://192.168.11.2:8006`).
2. Go to **Datacenter** (left sidebar) -> **Permissions** -> **Users**.
3. (Optional but recommended) Create a new user e.g. `tofu` at the `pam` or `pve` realm.
4. Go to **Permissions** -> **API Tokens**.
5. Click **Add**, select your user (e.g., `root@pam` or `tofu@pve`), and give the token an ID like `tofu-provisioner`. Uncheck "Privilege Separation" if you want it to have full user permissions, or leave it checked and manually assign permissions to the token.
6. Click **Add**. **IMPORTANT:** Proxmox will display the Token Secret *only once*. Copy it immediately.
7. Go to **Permissions**, click **Add** -> **User Permission** or **API Token Permission**, and assign the `Administrator` role to the user or token at the `/` path to ensure OpenTofu has all necessary privileges.

### 2. Configure Credentials

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```
2. Update `.env` with your newly created Token ID (e.g. `root@pam!tofu-provisioner`) and Token Secret.
3. Also copy `tofu/terraform.tfvars.example` to `tofu/terraform.tfvars` and add your Proxmox credentials there as well:
   ```bash
   cp tofu/terraform.tfvars.example tofu/terraform.tfvars
   ```
   *Note: OpenTofu can also read the `PROXMOX_API_TOKEN_ID` environment variables directly if exported.*

### 3. Provision Infrastructure (OpenTofu)

To create resources on Proxmox:
```bash
# Export secrets from the .env file
export $(grep -v '^#' .env | xargs)

# Initialize OpenTofu (downloads the Proxmox provider)
cd tofu
tofu init

# See what will be created
tofu plan

# Apply the changes
tofu apply
```

### 4. Configure Infrastructure (Ansible)

Once your VMs are created, update their IPs in `ansible/inventory/hosts.ini` and run specific playbooks to configure corresponding services:

```bash
cd ansible
# Example to deploy the NFS server
ansible-playbook playbooks/nfs.yml

# Example to deploy Minecraft
ansible-playbook playbooks/mc.yml

# Other playbooks available:
# jackett.yml, owncast.yml, qbittorrent.yml
```

## Current Services

- **NFS Server** (`nfs.tf`, `nfs.yml`)
- **Minecraft Server** (`mc.tf`, `mc.yml`)
- **Jackett** (`jackett.tf`, `jackett.yml`)
- **Owncast** (`owncast.tf`, `owncast.yml`)
- **qBittorrent** (`qbittorrent.tf`, `qbittorrent.yml`)