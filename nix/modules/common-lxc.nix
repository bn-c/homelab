{ config, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];

  boot.isContainer = true;

  # Enable mDNS resolution
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  # Enable and configure SSH for remote management
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "prohibit-password";
  };
}
