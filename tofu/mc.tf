resource "proxmox_virtual_environment_container" "minecraft_nixos_ct" {
  node_name    = "pve"
  vm_id        = 121
  description  = "Minecraft server container (NixOS)"
  unprivileged = true

  lifecycle {
    ignore_changes = [initialization, operating_system]
  }

  features {
    nesting = true
  }

  initialization {
    hostname = "mc"
    ip_config {
      ipv4 {
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
    size         = 50
  }

  memory {
    dedicated = 32768
  }

  cpu {
    cores = 8
  }

  network_interface {
    name     = "eth0"
    bridge   = "vmbr1lan"
    firewall = false
  }

  console {
    enabled = true
    type    = "console"
  }

  started = true
}

# Backup every 15m; keep last 4 (~60m of history).
# Path excludes applied separately (see terraform_data below) — bpg/proxmox
# cannot read Proxmox's exclude-path JSON array (CustomCommaSeparatedList bug).
resource "proxmox_backup_job" "minecraft" {
  id          = "minecraft"
  schedule    = "*-*-* *:00/15:00"
  storage     = "local"
  node        = "pve"
  vmid        = [tostring(proxmox_virtual_environment_container.minecraft_nixos_ct.vm_id)]
  mode        = "snapshot"
  compress    = "zstd"
  enabled     = true
  stdexcludes = true

  prune_backups = {
    keep-last = "4"
  }
}

# Longer retention: 1st + 15th of each month (~every 2 weeks), keep last 3.
resource "proxmox_backup_job" "minecraft_biweekly" {
  id          = "minecraft-biweekly"
  schedule    = "*-*-1,15 04:00:00"
  storage     = "local"
  node        = "pve"
  vmid        = [tostring(proxmox_virtual_environment_container.minecraft_nixos_ct.vm_id)]
  mode        = "snapshot"
  compress    = "zstd"
  enabled     = true
  stdexcludes = true

  prune_backups = {
    keep-last = "3"
  }
}

locals {
  minecraft_backup_exclude_paths = [
    "/var/lib/minecraft/.+/mods",
    "/var/lib/minecraft/.+/libraries",
    "/var/lib/minecraft/.+/versions",
    "/var/lib/docker",
  ]
}

# Sets exclude-path via pvesh (provider cannot manage that field).
resource "terraform_data" "minecraft_backup_excludes" {
  input = {
    jobs  = join(",", [proxmox_backup_job.minecraft.id, proxmox_backup_job.minecraft_biweekly.id])
    paths = join("\n", local.minecraft_backup_exclude_paths)
  }

  triggers_replace = [
    sha256(jsonencode({
      jobs  = [proxmox_backup_job.minecraft.id, proxmox_backup_job.minecraft_biweekly.id]
      paths = local.minecraft_backup_exclude_paths
    }))
  ]

  connection {
    type     = "ssh"
    host     = var.proxmox_host
    user     = "root"
    password = var.proxmox_ssh_password
  }

  provisioner "remote-exec" {
    inline = [
      for job in [proxmox_backup_job.minecraft.id, proxmox_backup_job.minecraft_biweekly.id] :
      format(
        "pvesh set /cluster/backup/%s -delete exclude-path %s",
        job,
        join(" ", [for p in local.minecraft_backup_exclude_paths : format("-exclude-path '%s'", p)])
      )
    ]
  }

  depends_on = [
    proxmox_backup_job.minecraft,
    proxmox_backup_job.minecraft_biweekly,
  ]
}

