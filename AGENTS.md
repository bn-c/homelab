# AGENTS.md

This document provides context and instructions for AI agents working on this repository.

## Repository Overview

This repository is a homelab setup utilizing Infrastructure as Code (IaC) and Configuration as Code (CaC).
- **Infrastructure:** OpenTofu (Terraform fork) located in the `tofu/` directory. It is used to provision Virtual Machines and LXC containers on a Proxmox server.
- **Configuration:** Ansible located in the `ansible/` directory. It configures the infrastructure provisioned by OpenTofu.

## Key Technologies

- **OpenTofu (tofu):** Used instead of standard Terraform. Always use `tofu` commands (e.g., `tofu init`, `tofu plan`, `tofu apply`).
- **Proxmox:** The underlying hypervisor.
- **Ansible:** Used for configuration management. Playbooks are in `ansible/playbooks/`, and inventory is in `ansible/inventory/`. The project relies on direct playbooks rather than roles.
- **Docker:** Used inside some VMs (e.g., Minecraft uses docker-compose).

## Agent Instructions

When modifying or analyzing this repository, keep the following rules in mind:

### 1. General Principles
- Understand the separation of concerns: OpenTofu is for creating VMs/containers (infrastructure), while Ansible is for installing software and configuring them (configuration).
- Do not commit secrets. Ensure files like `.env`, `terraform.tfvars`, and sensitive Ansible vault files are handled properly and gitignored.

### 2. OpenTofu (`tofu/`)
- Always use the `tofu` CLI tool instead of `terraform`.
- Proxmox provider configuration relies on API tokens (e.g., `PROXMOX_API_TOKEN_ID` and `PROXMOX_API_TOKEN_SECRET`).
- Before applying changes, always run `tofu plan` to verify what will be created/modified.

### 3. Ansible (`ansible/`)
- Maintain idempotency in Ansible playbooks. Run tasks so they only make changes when necessary.
- Update `ansible/inventory/hosts.ini` with correct IP addresses when new infrastructure is provisioned.
- Service specific playbooks (like `mc.yml`, `qbittorrent.yml`) run tasks directly instead of using separate roles.
- Docker Compose and configuration files for specific services reside in `ansible/playbooks/files/<service_name>/`.

### 4. Workflow
- If asked to provision a new service:
  1. Add the necessary VM/LXC definition in `tofu/<service_name>.tf` (and update variables if needed).
  2. Create or update the corresponding Ansible playbook in `ansible/playbooks/<service_name>.yml`. Keep associated files in `ansible/playbooks/files/<service_name>/`.
  3. Update the Ansible inventory (`ansible/inventory/hosts.ini`).
  4. Ensure the playbook deploys the necessary configuration and starts the service.
