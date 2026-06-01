resource "proxmox_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"

  overwrite           = false
  overwrite_unmanaged = true

  # URL for Ubuntu 24.04 Cloud Image
  url = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}

resource "proxmox_virtual_environment_file" "custom_nixos_qcow2" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"

  source_file {
    path      = "${path.module}/../result-qcow/nixos.qcow2"
    file_name = "nixos-cloudimg-amd64.img"
  }
}
