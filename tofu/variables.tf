variable "proxmox_host" {
  type        = string
  description = "The IP or hostname of the Proxmox server"
  default     = "192.168.11.2"
}

variable "proxmox_username" {
  type        = string
  description = "The Proxmox username (e.g. root@pam)"
  default     = "root@pam"
}

variable "proxmox_password" {
  type        = string
  description = "The Proxmox password"
  sensitive   = true
}

variable "proxmox_ssh_password" {
  type        = string
  description = "The SSH password for the Proxmox server"
  sensitive   = true
}
