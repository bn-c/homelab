{ config, pkgs, ... }:

{
  services.coder = {
    enable = true;
    listenAddress = "0.0.0.0:3000";
    accessUrl = "http://coder-nix.local:3000";
  };

  networking.firewall.allowedTCPPorts = [ 3000 ];
}

