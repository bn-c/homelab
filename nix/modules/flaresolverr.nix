{ config, pkgs, lib, ... }:

{
  services.flaresolverr = {
    enable = true;
    openFirewall = true;
  };
}