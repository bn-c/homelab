{ pkgs, ... }:
{
  # Enable QEMU guest agent for Proxmox
  services.qemuGuest.enable = true;

  # Enable Cloud-Init so Proxmox VMs can read the `initialization` block (hostname, keys, etc.)
  services.cloud-init.enable = true;
  services.cloud-init.network.enable = true;

  # Enable SSH
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";

  # Trust keys from existing Proxmox nodes
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPbpFP/1DMoIMlkxeg1W0BIfQeokpbanE61WldpqjzHe root@coder-bn-c-dev"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID+nh8Nwmib5blLo1W2rawfg4b6UKkrOwh9QF+3ARZRq tech@desk"
  ];

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    vim
  ];
}
