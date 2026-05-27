{ config, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];

  boot.isContainer = true;

  services.resolved = {
    enable = true;
    domains = [ "~local" ];
  };

  # Enable and configure SSH for remote management
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "prohibit-password";
  };
}
