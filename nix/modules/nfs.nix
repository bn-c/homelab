{ config, pkgs, ... }:

{
  networking.hostName = "nfs-nixos";
  services.nfs.server = {
    enable = true;
    exports = ''
      /srv/nfs *(rw,sync,no_subtree_check,all_squash,anonuid=65534,anongid=65534)
    '';
  };

  # Ensure the export directories exist
  systemd.tmpfiles.rules = [
    "d /srv/nfs 0777 nobody nogroup -"
    "d /srv/nfs/torrent/downloads 0777 nobody nogroup -"
    "d /srv/nfs/torrent/config 0777 nobody nogroup -"
  ];

  networking.firewall.allowedTCPPorts = [ 2049 ];
}
