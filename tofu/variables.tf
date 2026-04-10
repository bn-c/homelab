variable "proxmox_host" {
  type        = string
  description = "The IP or hostname of the Proxmox server"
  default     = "192.168.11.2"
}

variable "proxmox_api_token_id" {
  type        = string
  description = "The Proxmox API Token ID (e.g. root@pam!tofu)"
}

variable "proxmox_api_token_secret" {
  type        = string
  description = "The Proxmox API Token Secret"
  sensitive   = true
}

variable "proxmox_ssh_password" {
  type        = string
  description = "The SSH password for the Proxmox server"
  sensitive   = true
}
