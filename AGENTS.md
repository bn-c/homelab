# AGENTS.md

This document provides context and instructions for AI agents working on this repository.

## Repository Overview

This repository is a homelab setup utilizing Infrastructure as Code (IaC) and Configuration as Code (CaC).
- **Infrastructure:** OpenTofu (Terraform fork) located in the `tofu/` directory. It is used to provision Virtual Machines and LXC containers on a Proxmox server.
- **NixOS Configuration:** Colmena located in the `hive.nix` and `nix/` directory. It configures the infrastructure for NixOS LXC containers.

## Key Technologies

- **OpenTofu (tofu):** Used instead of standard Terraform. Always use `tofu` commands (e.g., `tofu init`, `tofu plan`, `tofu apply`).
- **Proxmox:** The underlying hypervisor.
- **Colmena (NixOS):** Used for configuration management on new nodes. System definitions are in `hive.nix` and custom modules are defined in `nix/modules/`.
- **Docker:** Used inside some VMs (e.g., Minecraft uses docker-compose).

## Agent Instructions

When modifying or analyzing this repository, keep the following rules in mind:

### 1. General Principles
- Understand the separation of concerns: OpenTofu is for creating VMs/containers (infrastructure), while NixOS configuration is for installing software and configuring them (configuration).
- Do not commit secrets. Ensure files like `.env`, `terraform.tfvars`, and other sensitive files within the `secrets/` directory are handled properly and gitignored.

### 2. OpenTofu (`tofu/`)
- Always use the `tofu` CLI tool instead of `terraform`.
- Proxmox provider configuration relies on API tokens (e.g., `PROXMOX_API_TOKEN_ID` and `PROXMOX_API_TOKEN_SECRET`).
- Before applying changes, always run `tofu plan` to verify what will be created/modified.

### 3. Colmena / NixOS Configuration
- Utilize `hive.nix` for node registration.
- For all Proxmox LXC containers configured via Colmena, import `./nix/modules/common-lxc.nix` so that they have baseline capabilities like mDNS (Avahi), SSH access configured, and the `proxmox-lxc` virtualisation profile.
- There is a custom base VM image available at `nix/iso.nix` which can be built as a qcow2 cloud image.
- This custom image is uploaded to Proxmox via `tofu/main.tf` (`proxmox_virtual_environment_file.custom_nixos_qcow2`) sourced from `../result-qcow/nixos.qcow2` so it can be used as the base image for deploying declarative NixOS VMs.
- Store specific service definitions inside `nix/modules/<service_name>.nix` and limit configuration strictly to Nix declarations instead of standard bash scripts whenever possible.
- Run `colmena apply` after modifying NixOS nodes.

### 4. Workflow
- If asked to provision a new service snippet via NixOS:
  1. Add the defined node inside `hive.nix` targeting the IP or `.local` mDNS address.
  2. Import `./nix/modules/common-lxc.nix` for base configuration (for LXCs). For VMs, ensure you boot them from the `proxmox_virtual_environment_file.custom_nixos_qcow2` reference.
  3. Create your custom configuration in `nix/modules/<service_name>.nix` and import it.
  4. Ensure `colmena apply` runs smoothly.
