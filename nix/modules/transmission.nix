{ config, pkgs, lib, ... }:

{
  # Enable NFS support
  boot.supportedFilesystems = [ "nfs" ];

  # Mount NFS share directly to the container's path for torrent downloads
  fileSystems."/opt/transmission/downloads" = {
    device = "nfs.local:/srv/nfs/torrent/downloads";
    fsType = "nfs";
    options = [ "rw" "sync" "hard" "intr" "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" "_netdev" ];
  };

  # Run Transmission as a native NixOS service
  services.transmission = {
    enable = true;
    package = pkgs.transmission_4.overrideAttrs (oldAttrs: {
      postPatch = (oldAttrs.postPatch or "") + ''
        sed -E -i 's/set\(TR_VERSION_MAJOR "[0-9]+"\)/set(TR_VERSION_MAJOR "4")/g' CMakeLists.txt
        sed -E -i 's/set\(TR_VERSION_MINOR "[0-9]+"\)/set(TR_VERSION_MINOR "0")/g' CMakeLists.txt
        sed -E -i 's/set\(TR_VERSION_PATCH "[0-9]+"\)/set(TR_VERSION_PATCH "5")/g' CMakeLists.txt
      '';
    });
    openPeerPorts = true;
    settings = {
      download-dir = "/opt/transmission/downloads";
      rpc-bind-address = "127.0.0.1";
      rpc-port = 9091;
      rpc-whitelist-enabled = false;
      rpc-host-whitelist-enabled = false;
      peer-port = 16881;
    };
  };

  # Modern web UI for Transmission
  services.flood = {
    enable = true;
    host = "0.0.0.0";
    port = 8080;
    extraArgs = [
      "--auth=none"
      "--trurl=http://127.0.0.1:9091/transmission/rpc"
      "--truser=admin"
      "--trpass=admin"
    ];
  };

  # Use firewall networking to forward port 80 to 8080
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 8080 9091 ];
    extraCommands = ''
      iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080
    '';
    extraStopCommands = ''
      iptables -t nat -D PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080 || true
    '';
  };
}