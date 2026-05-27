{ config, pkgs, lib, ... }:

{
  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  # Use firewall networking to forward port 80 to 9696
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 9696 ];
    extraCommands = ''
      iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 9696
    '';
    extraStopCommands = ''
      iptables -t nat -D PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 9696 || true
    '';
  };
}
