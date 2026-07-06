{ pkgs, lib, ... }:
let
  dockerfile = pkgs.writeText "Dockerfile" (builtins.readFile ./cc2/Dockerfile);
  serverConfig = pkgs.writeText "server_config.xml" (builtins.readFile ./cc2/server_config.xml);
  gameFiles = ./cc2/game_files;
in {
  imports = [ ./common-lxc.nix ];
  networking.hostName = "cc2";

  networking.firewall.allowedUDPPorts = [ 24999 25000 25001 25002 ];

  virtualisation.oci-containers.backend = "docker";
  virtualisation.docker.enable = true;
  virtualisation.docker.autoPrune.enable = true;

  # Ensure data directory exists
  system.activationScripts.cc2-data-dir = {
    text = "mkdir -p /var/lib/cc2/saved_games /var/lib/cc2/game_files /var/lib/cc2/logs";
    deps = [];
  };

  # Automatically build the docker image.
  # Any change to 'cc2/Dockerfile' triggers this service to rebuild on deploy.
  systemd.services.build-cc2-image = {
    description = "Build Carrier Command 2 Server Docker Image";
    after = [ "docker.service" ];
    wants = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      echo "Updating Dockerfile in /var/lib/cc2/ from Nix store..."
      cp -f ${dockerfile} /var/lib/cc2/Dockerfile

      echo "Copying game files from host..."
      cp -r ${gameFiles}/* /var/lib/cc2/game_files/

      echo "Building cc2-server:latest image (Docker will use layer caching)..."
      ${pkgs.docker}/bin/docker build -t cc2-server:latest /var/lib/cc2
    '';
  };

  # Configure the container service
  systemd.services.docker-cc2-server = {
    after = [ "build-cc2-image.service" ];
    wants = [ "build-cc2-image.service" ];
    
    # Copy configuration file before container startup.
    # Because this references the 'serverConfig' store path, any change to
    # 'cc2/server_config.xml' changes this script's hash, which triggers Colmena
    # to restart the container with the updated config on deploy.
    preStart = ''
      echo "Deploying server_config.xml from Nix store..."
      cp -f ${serverConfig} /var/lib/cc2/server_config.xml
      chmod 644 /var/lib/cc2/server_config.xml
    '';
  };

  virtualisation.oci-containers.containers = {
    "cc2-server" = {
      image = "cc2-server:latest";
      autoStart = true;
      extraOptions = [ "--network=host" ];
      volumes = [
        "/var/lib/cc2/server_config.xml:/home/steam/cc2_server/server_config.xml"
        "/var/lib/cc2/saved_games:/home/steam/cc2_server/saved_games"
        "/var/lib/cc2/logs:/home/steam/logs"
      ];
    };
  };
}
