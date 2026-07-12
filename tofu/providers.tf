terraform {
  backend "s3" {
    bucket                      = "tfstate"
    key                         = "homelab/terraform.tfstate"
    endpoint                    = "http://minio.local:9000"
    region                      = "us-east-1"
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style              = true
    access_key                  = "minioadmin"
    secret_key                  = "minioadmin"
  }
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.60.0"
    }
  }
}

provider "proxmox" {
  endpoint = "https://${var.proxmox_host}:8006/"
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = true

  ssh {
    agent    = false
    username = "root"
    password = var.proxmox_ssh_password
    node {
      name    = "pve"
      address = var.proxmox_host
    }
  }
}
