{ config, pkgs, ... }:

{
  networking.hostName = "sunshine";

  # Wayland/Graphical Session Configuration
  programs.sway.enable = true;
  programs.xwayland.enable = true;
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.sway}/bin/sway";
        user = "root";
      };
    };
  };

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
    package = pkgs.sunshine;
    settings = {
      bind_address = "0.0.0.0";
    };
  };
}
