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

# Backup jobs via pvesh: proxmox_backup_job still cannot read jobs once exclude-path
# is set (tested bpg/proxmox 0.118.0 — CustomCommaSeparatedList vs JSON array).
# One-time if plan still refreshes old proxmox_backup_job resources:
#   tofu state rm 'proxmox_backup_job.minecraft' 'proxmox_backup_job.minecraft_biweekly'
locals {
  minecraft_backup_bwlimit_kib = 8192 # ~8 MiB/s
  minecraft_backup_ionice      = 7    # vzdump I/O priority; 7 = lowest (PVE 0–7)

  minecraft_backup_exclude_paths = [
    "/var/lib/minecraft/.+/mods",
    "/var/lib/minecraft/.+/libraries",
    "/var/lib/minecraft/.+/versions",
    "/var/lib/docker",
  ]

  minecraft_backup_jobs = {
    # Every 30m; keep last 2 (~60m of history).
    minecraft = {
      schedule      = "*-*-* *:00/30:00"
      prune_backups = "keep-last=2"
    }
    # 1st + 15th of each month (~every 2 weeks), keep last 3.
    minecraft-biweekly = {
      schedule      = "*-*-1,15 04:00:00"
      prune_backups = "keep-last=3"
    }
  }
}

resource "terraform_data" "minecraft_backup_jobs" {
  triggers_replace = [
    sha256(jsonencode({
      vmid    = proxmox_virtual_environment_container.minecraft_nixos_ct.vm_id
      bwlimit = local.minecraft_backup_bwlimit_kib
      ionice  = local.minecraft_backup_ionice
      jobs    = local.minecraft_backup_jobs
      paths   = local.minecraft_backup_exclude_paths
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
      for job_id, job in local.minecraft_backup_jobs :
      format(
        "pvesh set /cluster/backup/%s --schedule '%s' --storage local --node pve --vmid %d --mode snapshot --compress zstd --enabled 1 --bwlimit %d --ionice %d --prune-backups '%s' --stdexcludes 1 -delete exclude-path %s",
        job_id,
        job.schedule,
        proxmox_virtual_environment_container.minecraft_nixos_ct.vm_id,
        local.minecraft_backup_bwlimit_kib,
        local.minecraft_backup_ionice,
        job.prune_backups,
        join(" ", [for p in local.minecraft_backup_exclude_paths : format("-exclude-path '%s'", p)])
      )
    ]
  }

  depends_on = [proxmox_virtual_environment_container.minecraft_nixos_ct]
}

