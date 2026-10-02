# Homelab IaC

This repository contains the Infrastructure as Code (OpenTofu) and Configuration as Code (Colmena/NixOS) for managing a Proxmox homelab.

## Directory Structure

- `tofu/`: Contains the OpenTofu code to provision Virtual Machines and LXC containers on Proxmox.
- `nix/`: Contains NixOS configuration modules and host definitions.
- `.env`: Stores environment variables and secrets (Proxmox password). Note: `.env` is intentionally ignored in source control.

## Getting Started

### 1. Configure Credentials

OpenTofu authenticates to Proxmox with username/password (`tofu/providers.tf`).

1. Edit `.env` (already created from `.env.example`) and set your Proxmox passwords.
2. Or edit `tofu/terraform.tfvars` (same values). Either works; OpenTofu reads `TF_VAR_*` and/or `terraform.tfvars`.
3. [direnv](https://direnv.net/) auto-loads `.env` via `.envrc` when you `cd` into the repo (`direnv allow` once if prompted).

### 2. Provision Infrastructure (OpenTofu)

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

### 3. Configure Infrastructure (Colmena/NixOS)

Once your infrastructure is provisioned, use Colmena to apply NixOS configurations to the containers:

```bash
# Apply configurations to all defined nodes
colmena apply
```

### 4. Custom NixOS Live ISO (For VMs)

To build a fresh, customized standard NixOS Live ISO for future Proxmox VM deployments, we use `nixos-generators` powered by the configuration in `nix/iso.nix`:

```bash
# Optional: Clear garbage to free up root space first
nix-collect-garbage -d 

# Build the custom ISO into the result/ directory
nix --extra-experimental-features "nix-command flakes" run nixpkgs#nixos-generators -- -f qcow -c nix/iso.nix -o result-qcow
```

OpenTofu then automatically uploads this synced ISO to Proxmox via tracking the `proxmox_virtual_environment_file.custom_nixos_iso` resource in `tofu/main.tf`, allowing new standard NixOS VMs to easily mount it via the `cdrom` block and begin configuring themselves.

## Current Services

- **NFS Server** (`nfs.tf`, `nix/modules/nfs.nix`)
- **Minecraft Server** (`mc.tf`, `nix/modules/mc.nix`)
- **Owncast** (`owncast.tf`, `nix/modules/owncast.nix`)
- **qBittorrent** (`transmission.tf`, `nix/modules/transmission.nix`)
- **Cloudflared** (`cloudflared.tf`, `nix/modules/cloudflared.nix`)
- **Flaresolverr** (`flaresolverr.tf`, `nix/modules/flaresolverr.nix`)
- **Kasm** (`kasm.tf`, `nix/modules/kasm.nix`)
- **Prowlarr** (`prowlarr.tf`, `nix/modules/prowlarr.nix`)
