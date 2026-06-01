{ config, pkgs, ... }:

{
  deployment.keys = {
    "cloudflared-cert.pem" = {
      keyFile = ../../secrets/cloudflared/cert.pem;
    };
    "cloudflared-credentials.json" = {
      keyFile = ../../secrets/cloudflared/homelab-nix/70e6ca85-7238-4894-b104-d9635063dc97.json;
    };
  };

  services.cloudflared = {
    enable = true;
    certificateFile = config.deployment.keys."cloudflared-cert.pem".path;
    
    tunnels = {
      "homelab-nix" = {
        credentialsFile = config.deployment.keys."cloudflared-credentials.json".path;
        default = "http_status:404";
        ingress = {
          "owncast.bachnc.dev" = "http://owncast.local";
          "pve.bachnc.dev" = {
            service = "https://192.168.11.2:8006";
            originRequest.noTLSVerify = true;
          };
          "transmission.bachnc.dev" = "http://transmission.local";
          "browser.bachnc.dev" = "http://neko.local:8080";
          "owrt.bachnc.dev" = "http://openwrt.local";
          "siyuan.bachnc.dev" = "http://siyuan.local";
          "prowlarr.bachnc.dev" = "http://prowlarr.local";
        };
      };
    };
  };

  # Automatically run route commands during NixOS activation
  system.activationScripts.routeCloudflareDns = ''
    ${pkgs.lib.concatStringsSep "\n" (
      pkgs.lib.mapAttrsToList (hostname: target: ''
        ${pkgs.cloudflared}/bin/cloudflared tunnel --origincert ${config.deployment.keys."cloudflared-cert.pem".path} route dns homelab-nix ${hostname} || echo "Route for ${hostname} skipped or already exists."
      '') config.services.cloudflared.tunnels."homelab-nix".ingress
    )}
  '';
}
