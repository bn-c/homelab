resource "proxmox_virtual_environment_container" "minecraft_ct" {
  node_name    = "pve"
  vm_id        = 120
  description  = "Minecraft server container"
  unprivileged = true

  features {
    nesting = true
  }

  initialization {
    hostname = "mc-server"
    ip_config {
      ipv4 {
        address = "dhcp"
      }
      ipv6 {
        address = "dhcp"
      }
    }
    user_account {
      password = "techisawesome"
      keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPbpFP/1DMoIMlkxeg1W0BIfQeokpbanE61WldpqjzHe root@coder-bn-c-dev",
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID+nh8Nwmib5blLo1W2rawfg4b6UKkrOwh9QF+3ARZRq tech@desk"
      ]
    }
  }

  operating_system {
    template_file_id = "local:vztmpl/ubuntu-25.04-standard_25.04-1.1_amd64.tar.zst"
    type             = "ubuntu"
  }

  disk {
    datastore_id = "local-lvm"
    size         = 50
  }

  memory {
    dedicated = 20480
  }

  cpu {
    cores = 4
  }

  network_interface {
    name     = "eth0"
    bridge   = "vmbr1lan"
    firewall = true
  }

  console {
    enabled = true
  }

  started = true
}
