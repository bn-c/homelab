{ pkgs, lib, ... }: {
  networking.hostName = "mc";

  # Base requirements for Minecraft
  networking.firewall.allowedTCPPorts = [ 25565 25566 ];
  networking.firewall.allowedUDPPorts = [ 25565 25566 ];

  # Use Docker to manage containers
  virtualisation.oci-containers.backend = "docker";
  virtualisation.docker.enable = true;
  virtualisation.docker.autoPrune.enable = true;

  # Ensure data directory exists
  system.activationScripts.minecraft-data-dir = {
    text = ''
      mkdir -p /var/lib/minecraft/stoneblock4
      mkdir -p /var/lib/minecraft/gtnh
    '';
    deps = [];
  };

  # Define Minecraft containers
  virtualisation.oci-containers.containers = {
    "minecraft-stoneblock4" = {
      image = "itzg/minecraft-server:java21";
      autoStart = true;
      ports = [ "25565:25565" ];
      environment = {
        EULA = "TRUE";
        TYPE = "AUTO_CURSEFORGE";
        CF_PAGE_URL = "https://www.curseforge.com/minecraft/modpacks/ftb-stoneblock-4";
        MEMORY = "10G";
        CF_API_KEY = "$$2a$$10$$DmicWKdlkD4kVfA8.uBdFO7jFsDw5pGjOJhDVH.S8AE08RT6TaN3G";
        OPS = "techtheawesome";
        VIEW_DISTANCE = "24";
        SPAWN_PROTECTION = "0";
        ALLOW_FLIGHT = "true";
        ENABLE_COMMAND_BLOCK = "true";
        DIFFICULTY = "hard";
      };
      extraOptions = [ "--health-cmd" "none" ];
      volumes = [ "/var/lib/minecraft/stoneblock4:/data" ];
    };

    "minecraft-gtnh" = {
      image = "itzg/minecraft-server:java25";
      autoStart = true;
      ports = [ "25566:25566" ];
      environment = {
        SERVER_PORT = "25566";
        MEMORY = "10G";
        EULA = "TRUE";
        TYPE = "GTNH";
        GTNH_DELETE_BACKUPS = "true";
        CF_API_KEY = "2a10DmicWKdlkD4kVfA8.uBdFO7jFsDw5pGjOJhDVH.S8AE08RT6TaN3G";
        OPS = "techtheawesome";
        VIEW_DISTANCE = "24";
        SPAWN_PROTECTION = "0";
        ALLOW_FLIGHT = "true";
        ENABLE_COMMAND_BLOCK = "true";
        DUMP_SERVER_PROPERTIES = "TRUE";
        LEVEL = "world";
        SEED = "xX_BigYahuTelAviv_Xx";
        # Force IPv4
        JAVA_TOOL_OPTIONS = "-Djava.net.preferIPv4Stack=true";
        GENERIC_PACKS_DISABLE_MODS = "JourneyMapServer1.0.5_MC1.7.10.jar";
        MODS = lib.concatStringsSep "," [
          "https://github.com/Kynake/BetterFoliage/releases/download/1.2.1/BetterFoliage-LegacyEdition-1.2.1.jar"
          "https://github.com/GTNewHorizons/SharedProspecting/releases/download/2.0.5/sharedprospecting-2.0.5.jar"
          "https://cdn.modrinth.com/data/lfHFW1mp/versions/lTcFpNxW/journeymap-1.7.10-v5.2.17-unlimited.jar"
        ];
      };
      extraOptions = [ "--health-cmd" "none" ];
      volumes = [ "/var/lib/minecraft/gtnh:/data" ];
    };
  };

  systemd.services = {
    "docker-minecraft-stoneblock4" = {
      serviceConfig = {
        Restart = lib.mkForce "always";
        RestartSec = "10s";
      };
    };
    
    "docker-minecraft-gtnh" = {
      serviceConfig = {
        Restart = lib.mkForce "always";
        RestartSec = "10s";
      };
    };
  };
}
