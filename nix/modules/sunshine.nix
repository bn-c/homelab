{ config, pkgs, ... }:

{
  # --------------------------------------------------------------------------
  # 1. Pipeline & Graphics setup
  # --------------------------------------------------------------------------

  # Ensure virtual/dummy graphics for Mesa to support headless wlroots
  hardware.opengl = {
    enable = true;
    # Mesa provides a generic software rasterizer fallback if GPU is absent (llvmpipe).
  };

  # --------------------------------------------------------------------------
  # 2. Audio (Pipewire)
  # --------------------------------------------------------------------------
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --------------------------------------------------------------------------
  # 3. Desktop Environment (Headless Sway)
  # --------------------------------------------------------------------------
  programs.sway.enable = true;

  # Create a dedicated user for remote desktop
  users.users.rdpuser = {
    isNormalUser = true;
    description = "Remote Desktop User";
    extraGroups = [ "wheel" "video" "audio" "input" ];
    password = "changeme"; # Set a secure password here or via sops/agenix
  };

  # Launch Sway headlessly on boot
  systemd.services.headless-sway = {
    description = "Headless Sway Compositor";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-user-sessions.service" ];
    
    # Needs to be run as our user
    serviceConfig = {
      Type = "simple";
      User = "rdpuser";
      Environment = [
        "WLR_BACKENDS=headless"
        "WLR_LIBINPUT_NO_DEVICES=1"
        "WLR_RENDERER=pixman" # Use CPU rendering (pixman) since there is no GPU
        "WAYLAND_DISPLAY=wayland-1"
        "XDG_RUNTIME_DIR=/run/user/1000"
      ];
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /run/user/1000 && ${pkgs.coreutils}/bin/chown rdpuser:rdpuser /run/user/1000";
      # Start sway and drop a terminal or xfce4-panel inside it. 
      ExecStart = "${pkgs.sway}/bin/sway -d";
      Restart = "always";
      RestartSec = 3;
    };
  };

  # --------------------------------------------------------------------------
  # 4. Sunshine Server
  # --------------------------------------------------------------------------
  
  services.sunshine = {
    enable = true;
    autoStart = false; # We will manage it via our custom systemd service
    capSysAdmin = true; # Required to capture display output
    openFirewall = true;
  };

  # Start Sunshine targeting the Headless Wayland session
  systemd.services.sunshine-headless = {
    description = "Sunshine (Headless)";
    wantedBy = [ "multi-user.target" ];
    after = [ "headless-sway.service" "network.target" ];
    requires = [ "headless-sway.service" ];
    
    serviceConfig = {
      Type = "simple";
      User = "rdpuser";
      # Require access to uinput to inject controls
      ExecStartPre = "+${pkgs.coreutils}/bin/chmod a+rw /dev/uinput"; 
      Environment = [
        "WAYLAND_DISPLAY=wayland-1"
        "XDG_RUNTIME_DIR=/run/user/1000"
      ];
      ExecStart = "${config.security.wrapperDir}/sunshine";
      Restart = "always";
      RestartSec = 5;
    };
  };

  # Some productivity apps to access inside the environment
  environment.systemPackages = with pkgs; [
    foot            # terminal for sway
    xfce.thunar     # file manager
    firefox         # web browser
  ];

}