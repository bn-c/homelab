{ config, pkgs, ... }:

{
  # Enable NFS support
  boot.supportedFilesystems = [ "nfs" ];

  # Mount NFS share directly to the container's path for torrent downloads
  fileSystems."/opt/qbittorrent/downloads" = {
    device = "nfs.local:/srv/nfs/torrent/downloads";
    fsType = "nfs";
    options = [ "rw" "sync" "hard" "intr" ];
  };

  # Mount NFS share directly to the container's path for the config profile
  fileSystems."/opt/qbittorrent/config" = {
    device = "nfs.local:/srv/nfs/torrent/config";
    fsType = "nfs";
    options = [ "rw" "sync" "hard" "intr" ];
  };

  # Run qbittorrent as a native NixOS service
  services.qbittorrent = {
    enable = true;
    profileDir = "/opt/qbittorrent/config";
    webuiPort = 80;
    torrentingPort = 16881;
    openFirewall = true;
    extraArgs = [ "--confirm-legal-notice" ];
  };

  # Allow qBittorrent to bind to privileged ports (like 80)
  systemd.services.qbittorrent.serviceConfig = {
    AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
    CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
  };
}