resource "proxmox_virtual_environment_container" "jackett_ct" {
  node_name = "pve"
  vm_id     = 902
  description = "Jackett container"
  
  initialization {
    hostname = "jackett"
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    user_account {
      password = "techisawesome"
    }
  }

  operating_system {
    template_file_id = "local:vztmpl/ubuntu-25.04-standard_25.04-1.1_amd64.tar.zst"
    type             = "ubuntu"
  }

  disk {
    datastore_id = "local-lvm"
    size         = 8
  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr1lan"
  }

  console {
    enabled = true
  }

  started = true
}
