resource "proxmox_virtual_environment_file" "custom_nixos_qcow2" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"

  lifecycle {
    ignore_changes = [source_file]
  }

  source_file {
    path      = "${path.module}/../result-qcow/nixos.qcow2"
    file_name = "nixos-cloudimg-amd64.img"
  }
}
