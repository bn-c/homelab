{ config, pkgs, ... }:

{
  # Enable NFS support
  boot.supportedFilesystems = [ "nfs" ];

  # Mount NFS share directly to the container's path, matching the previous Ansible setup
  fileSystems."/opt/qbittorrent/downloads" = {
    device = "nfs.local:/srv/nfs/torrent";
    fsType = "nfs";
    options = [ "rw" "sync" "hard" "intr" ];
  };

  # Ensure the config folder exists with correct permissions
  systemd.tmpfiles.rules = [
    "d /opt/qbittorrent/config 0777 qbittorrent qbittorrent -"
  ];

  # Run qbittorrent as a native NixOS service
  services.qbittorrent = {
    enable = true;
    profileDir = "/opt/qbittorrent/config";
    webuiPort = 80;
    torrentingPort = 16881;
    openFirewall = true;
  };
}