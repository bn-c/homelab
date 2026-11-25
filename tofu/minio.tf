resource "proxmox_virtual_environment_container" "minio_ct" {
  node_name    = "pve"
  vm_id        = 914
  description  = "MinIO container"
  unprivileged = false

  lifecycle {
    ignore_changes = [initialization, operating_system]
  }

  features {
    nesting = true
  }

  initialization {
    hostname = "minio"
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
    size         = 8
  }

  memory {
    dedicated = 2048
  }

  cpu {
    cores = 2
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

# Daily CT snapshot (tfstate + MinIO data under /var/lib/minio).
resource "proxmox_backup_job" "minio_daily" {
  id          = "minio-daily"
  schedule    = "*-*-* 03:00:00"
  storage     = "local"
  node        = "pve"
  vmid        = [tostring(proxmox_virtual_environment_container.minio_ct.vm_id)]
  mode        = "snapshot"
  compress    = "zstd"
  enabled     = true
  stdexcludes = true
  bwlimit     = 8192 # KiB/s (~8 MiB/s)
  ionice      = 7    # lowest vzdump I/O priority (PVE 0–7)

  prune_backups = {
    keep-last = "7"
  }
}
