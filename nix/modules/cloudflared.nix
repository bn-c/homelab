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
          "pve.bachnc.dev" = "http://pve.local:8006";
          "transmission.bachnc.dev" = "http://transmission.local";
        };
      };
    };
  };
}
