{ config, pkgs, ... }:

{
  services.coder = {
    enable = true;
    listenAddress = "0.0.0.0:3000";
    accessUrl = "http://coder-nix.local:3000";
  };

  environment.etc."coder/templates" = {
    source = ./coder/templates;
  };

  environment.systemPackages = [ pkgs.coder ];

  system.activationScripts.coderInit = {
    text = ''
      # Ensure permissions are correct
      chown -R coder:coder /var/cache/coder || true

      ${pkgs.coder}/bin/coder login http://localhost:3000 \
        --first-user-email root.bachnc@gmail.com \
        --first-user-username bn-c \
        --first-user-full-name "bn-c" \
        --first-user-password "techisawesome"
    '';
    deps = [];
  };

  system.activationScripts.coderTemplatePush = {
    text = ''
      cd /etc/coder/templates && ${pkgs.coder}/bin/coder template push -y proxmox-vm -d ./proxmox-vm
    '';
    deps = [ "coderInit" ];
  };

  networking.firewall.allowedTCPPorts = [ 3000 ];
}
