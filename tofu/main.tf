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
  unprivileged = false

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
    backup  = true
  }

  network {
    name   = "eth0"
    bridge = "vmbr1lan"
    ip     = "dhcp"
  }

  onboot       = true
  start        = true
  unprivileged = true

}

moved {
  from = proxmox_lxc.omv_lxc
  to   = proxmox_lxc.samba_lxc
}

resource "proxmox_virtual_environment_file" "cloud_init_vendor_data" {
  provider     = bpg
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve"

  source_file {
    path = "user-data.yaml"
  }
}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image_nfs" {
  provider     = bpg
  content_type = "iso"
  datastore_id = "local" 
  node_name    = "pve"   

  # URL for Ubuntu 24.04 Cloud Image
  url = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}

resource "proxmox_virtual_environment_vm" "nfs_vm" {
  provider  = bpg
  name      = "nfs-server"
  node_name = "pve"
  vm_id     = 901

  agent {
    enabled = true
  }

  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = 2048
  }

  started = true
  on_boot = true

  operating_system {
    type = "l26"
  }

  scsi_hardware = "virtio-scsi-single"
  boot_order    = ["scsi0"]

  disk {
    datastore_id = "local-lvm" 
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image_nfs.id
    interface    = "scsi0"
    iothread     = true
    discard      = "on"
    size         = 50 
  }

  network_device {
    bridge = "vmbr1lan"
  }

  initialization {
    user_data_file_id = proxmox_virtual_environment_file.cloud_init_vendor_data.id

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
}

output "nfs_vm_ipv4_address" {
  value = proxmox_virtual_environment_vm.nfs_vm.ipv4_addresses[1][0]
}
