{ config, pkgs, ... }:

{
  proxmoxLXC.privileged = false;

  services.owncast = {
    enable = true;
    listen = "0.0.0.0";
    port = 8080;
    rtmp-port = 1935;
    dataDir = "/opt/owncast/data";
    openFirewall = true;
  };

  networking.firewall = {
    allowedTCPPorts = [ 80 ];
    extraCommands = ''
      iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8080
    '';
    extraStopCommands = ''
      iptables -t nat -D PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8080 || true
    '';
  };

  # Make sure the data directory exists with the correct permissions
  systemd.tmpfiles.rules = [
    "d /opt/owncast/data 0755 owncast owncast -"
  ];
}
