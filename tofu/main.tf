resource "proxmox_virtual_environment_file" "cloud_init_user_data" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve"

  source_raw {
    data      = file("${path.module}/user-data.yaml")
    file_name = "user-data.yaml"
  }
}

resource "proxmox_virtual_environment_file" "cloud_init_meta_data" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve"

  source_raw {
    data      = "local-hostname: nfs-server\ninstance-id: nfs-server\n"
    file_name = "meta-data.yaml"
  }
}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image_nfs" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"

  overwrite           = true
  overwrite_unmanaged = true

  # URL for Ubuntu 24.04 Cloud Image
  url = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}

resource "proxmox_virtual_environment_vm" "nfs_vm" {
  name      = "nfs-server"
  node_name = "pve"
  vm_id     = 901

  agent {
    enabled = true
  }

  cpu {
    cores   = 6
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = 8192
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
    type              = "nocloud"
    datastore_id      = "local-lvm"
    user_data_file_id = proxmox_virtual_environment_file.cloud_init_user_data.id
    meta_data_file_id = proxmox_virtual_environment_file.cloud_init_meta_data.id

    ip_config {
      ipv4 {
        address = "dhcp"
      }
      ipv6 {
        address = "dhcp"
      }
    }
  }
}

output "nfs_vm_ipv4_address" {
  value = proxmox_virtual_environment_vm.nfs_vm.ipv4_addresses[1][0]
}
