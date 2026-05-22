resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image_nfs" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"

  overwrite           = false
  overwrite_unmanaged = true

  # URL for Ubuntu 24.04 Cloud Image
  url = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}
