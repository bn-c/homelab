resource "proxmox_lxc" "minecraft_lxc" {
  hostname    = "mc-server"
  target_node = "pve"

  clone = "110"

  cores  = 4
  memory = 20480
  swap   = 0

  rootfs {
    storage = "local-lvm"
    size    = "50G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr1lan"
    ip     = "dhcp"
  }

  onboot       = true
  start        = true
  unprivileged = true

  features {
    nesting = true
  }
}

resource "proxmox_lxc" "samba_lxc" {
  hostname    = "samba-server"
  target_node = "pve"
  password    = "techisawesome"

  ssh_public_keys = <<-EOT
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID+nh8Nwmib5blLo1W2rawfg4b6UKkrOwh9QF+3ARZRq tech@desk
  EOT

  ostemplate = "local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"

  cores  = 2
  memory = 2048
  swap   = 512

  rootfs {
    storage = "local-lvm"
    size    = "20G"
  }

  # Virtual block device for Samba storage
  mountpoint {
    key     = "0"
    slot    = 0
    storage = "local-lvm"
    mp      = "/srv/samba"
    size    = "100G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr1lan"
    ip     = "dhcp"
  }

  onboot       = true
  start        = true
  unprivileged = true

  features {
    nesting = true
  }
}

moved {
  from = proxmox_lxc.omv_lxc
  to   = proxmox_lxc.samba_lxc
}
