{ config, pkgs, ... }:

{
  services.minio = {
    enable = true;
    listenAddress = "0.0.0.0:9000";
    consoleAddress = "0.0.0.0:9001";
    dataDir = ["/var/lib/minio/data"];
  };

  systemd.services.minio-create-buckets = {
    description = "Create MinIO buckets";
    after = [ "minio.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Environment = "MC_CONFIG_DIR=/var/lib/minio/.mc";
    };
    script = ''
      mkdir -p /var/lib/minio/.mc
      ${pkgs.minio-client}/bin/mc alias set local http://127.0.0.1:9000 minioadmin minioadmin
      ${pkgs.minio-client}/bin/mc mb -p local/tfstate
    '';
  };

  networking.firewall.allowedTCPPorts = [ 9000 9001 ];
}
