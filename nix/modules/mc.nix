{ pkgs, lib, ... }: {
  networking.hostName = "mc";

  # Base requirements for Minecraft
  networking.firewall.allowedTCPPorts = [ 25565 25566 ];
  networking.firewall.allowedUDPPorts = [ 25565 25566 ];

  # Use Podman or Docker to manage containers
  virtualisation.oci-containers.backend = "podman";
  virtualisation.podman.enable = true;
  virtualisation.podman.autoPrune.enable = true;

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
        MEMORY = "12G";
        CF_API_KEY = "$$2a$$10$$DmicWKdlkD4kVfA8.uBdFO7jFsDw5pGjOJhDVH.S8AE08RT6TaN3G";
        OPS = "techtheawesome";
        VIEW_DISTANCE = "24";
        SPAWN_PROTECTION = "0";
        ALLOW_FLIGHT = "true";
        ENABLE_COMMAND_BLOCK = "true";
        DIFFICULTY = "hard";
      };
      extraOptions = [ "--tty" "--interactive" "--health-cmd" "none" ];
      volumes = [ "/var/lib/minecraft/stoneblock4:/data" ];
    };

    "minecraft-gtnh" = {
      image = "itzg/minecraft-server:java25";
      autoStart = true;
      ports = [ "25566:25565" ];
      environment = {
        MEMORY = "12G";
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
        MODS = "https://github.com/Kynake/BetterFoliage/releases/download/1.2.1/BetterFoliage-LegacyEdition-1.2.1.jar";
      };
      extraOptions = [ "--tty" "--interactive" "--health-cmd" "none"];
      volumes = [ "/var/lib/minecraft/gtnh:/data" ];
    };
  };

  systemd.services = {
    "podman-minecraft-stoneblock4" = {
      serviceConfig = {
        Restart = lib.mkForce "always";
        RestartSec = "10s";
      };
    };
    
    "podman-minecraft-gtnh" = {
      serviceConfig = {
        Restart = lib.mkForce "always";
        RestartSec = "10s";
      };
    };
  };
}
