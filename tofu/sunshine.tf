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

  cdrom {
    enabled   = true
    file_id   = proxmox_virtual_environment_file.custom_nixos_iso.id
    interface = "ide2"
  }

  disk {
    datastore_id = "local-lvm"
    file_format  = "raw"
    interface    = "virtio0"
    size         = 32
  }

  initialization {
    hostname = "sunshine"
    ip_config {
      ipv4 {
        address = "dhcp"
      }
      ipv6 {
        address = "dhcp"
      }
    }
    user_account {
      keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPbpFP/1DMoIMlkxeg1W0BIfQeokpbanE61WldpqjzHe root@coder-bn-c-dev",
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID+nh8Nwmib5blLo1W2rawfg4b6UKkrOwh9QF+3ARZRq tech@desk"
      ]
      password = "techisawesome"
    }
  }

  network_device {
    bridge = "vmbr1lan"
  }

  operating_system {
    type = "l26"
  }
}
