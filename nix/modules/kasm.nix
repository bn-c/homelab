{ config, pkgs, lib, ... }:

{
  virtualisation.docker.enable = true;

  services.kasmweb = {
    enable = true;
    listenPort = 443;
    datastorePath = "/var/lib/kasmweb";
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 443 ];
  };
}
