{ config, pkgs, lib, ... }:

{
  networking.hostName = "sonarr";

  # Enable NFS support
  boot.supportedFilesystems = [ "nfs" ];

  # Mount NFS share directory
  fileSystems."/media" = {
    device = "nfs-nixos.local:/srv/nfs";
    fsType = "nfs";
    options = [ "rw" "sync" "hard" "intr" "_netdev" "x-systemd.after=network-online.target" ];
  };

  # Make sure the mount path has proper permissions
  systemd.tmpfiles.rules = [
    "d /media 0755 root root -"
  ];

  services.sonarr = {
    enable = true;
    openFirewall = true;
  };

  # Use firewall networking to forward port 80 to 8989 for easier access
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 8989 ];
    extraCommands = ''
      iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8989
    '';
    extraStopCommands = ''
      iptables -t nat -D PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8989 || true
    '';
  };
}