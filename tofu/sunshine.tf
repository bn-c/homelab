resource "proxmox_virtual_environment_file" "sunshine_user_data" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve"

  source_raw {
    data = <<-EOD
#cloud-config
hostname: sunshine
manage_etc_hosts: true

users:
  - default
  - name: root
    ssh_authorized_keys:
      - "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPbpFP/1DMoIMlkxeg1W0BIfQeokpbanE61WldpqjzHe root@coder-bn-c-dev"
      - "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID+nh8Nwmib5blLo1W2rawfg4b6UKkrOwh9QF+3ARZRq tech@desk"
    shell: /run/current-system/sw/bin/bash

password: "techisawesome"
chpasswd:
  expire: False
  list: |
    root:techisawesome
EOD

    file_name = "sunshine-user-data"
  }
}

resource "proxmox_virtual_environment_file" "sunshine_meta_data" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve"

  source_raw {
    data      = "local-hostname: sunshine"
    file_name = "sunshine-meta-data"
  }
}

resource "proxmox_virtual_environment_vm" "sunshine_vm" {
  node_name   = "pve"
  vm_id       = 911
  name        = "sunshine"
  description = "Headless Wayland Desktop (Sunshine)"

  agent {
    enabled = true
  }

  cpu {
    cores = 4
  }

  memory {
    dedicated = 4096
  }

  boot_order = ["virtio0"]

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_file.custom_nixos_qcow2.id
    interface    = "virtio0"
    size         = 32
  }

  initialization {
    user_data_file_id = proxmox_virtual_environment_file.sunshine_user_data.id
    meta_data_file_id = proxmox_virtual_environment_file.sunshine_meta_data.id
    ip_config {
      ipv4 {
        address = "dhcp"
      }
      ipv6 {
        address = "dhcp"
      }
    }
  }

  network_device {
    bridge = "vmbr1lan"
  }

  operating_system {
    type = "l26"
  }
}
