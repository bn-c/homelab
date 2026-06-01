resource "proxmox_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"

  overwrite           = false
  overwrite_unmanaged = true

  # URL for Ubuntu 24.04 Cloud Image
  url = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}

resource "proxmox_virtual_environment_file" "custom_nixos_iso" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"

  source_file {
    path      = "${path.module}/../result/iso/nixos-26.11pre1006943.e9a7635a5759-x86_64-linux.iso"
    file_name = "nixos-custom-live.iso"
  }
}
