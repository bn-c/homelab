resource "proxmox_virtual_environment_container" "jellyfin_ct" {
  node_name    = "pve"
  vm_id        = 911
  description  = "Jellyfin container"
  unprivileged = false

  features {
    nesting = true
    mount   = ["nfs"]
  }

  initialization {
    hostname = "jellyfin"
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
    template_file_id = "local:vztmpl/nixos-image-lxc-proxmox-26.05pre-git-x86_64-linux.tar.xz"
    type             = "nixos"
  }

  disk {
    datastore_id = "local-lvm"
    size         = 16
  }

  memory {
    dedicated = 4096
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
    type    = "console"
  }

  started = true
}
