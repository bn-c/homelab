{
  meta = {
    nixpkgs = import <nixpkgs> {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
  };

  transmission = { name, nodes, pkgs, modulesPath, ... }: {
    deployment.targetHost = "transmission.local";
    deployment.targetUser = "root";

    imports = [
      ./nix/modules/common-lxc.nix
      ./nix/modules/transmission.nix
    ];
    
    system.stateVersion = "26.05"; 
  };

  prowlarr = { name, nodes, pkgs, modulesPath, ... }: {
    deployment.targetHost = "prowlarr.local";
    deployment.targetUser = "root";

    imports = [
      ./nix/modules/common-lxc.nix
      ./nix/modules/prowlarr.nix
    ];
    
    system.stateVersion = "26.05"; 
  };

  kasm = { name, nodes, pkgs, modulesPath, ... }: {
    deployment.targetHost = "kasm.local";
    deployment.targetUser = "root";

    imports = [
      ./nix/modules/common-lxc.nix
      ./nix/modules/kasm.nix
    ];
    
    system.stateVersion = "26.05"; 
  };

  owncast = { name, nodes, pkgs, modulesPath, ... }: {
    deployment.targetHost = "owncast.local";
    deployment.targetUser = "root";

    imports = [
      ./nix/modules/common-lxc.nix
      ./nix/modules/owncast.nix
    ];
    
    system.stateVersion = "26.05"; 
  };

  cftest = { name, nodes, pkgs, modulesPath, ... }: {
    deployment.targetHost = "cftest.local";
    deployment.targetUser = "root";

    imports = [
      ./nix/modules/common-lxc.nix
      ./nix/modules/cloudflared.nix
    ];
    
    system.stateVersion = "26.05"; 
  };

  flaresolverr = { name, nodes, pkgs, modulesPath, ... }: {
    deployment.targetHost = "flaresolverr.local";
    deployment.targetUser = "root";

    imports = [
      ./nix/modules/common-lxc.nix
      ./nix/modules/flaresolverr.nix
    ];
    
    system.stateVersion = "26.05"; 
  };

  mc = { name, nodes, pkgs, modulesPath, ... }: {
    deployment.targetHost = "mc.local";
    deployment.targetUser = "root";

    imports = [
      ./nix/modules/common-lxc.nix
      ./nix/modules/mc.nix
    ];
    
    system.stateVersion = "26.05"; 
  };

  nfs = { name, nodes, pkgs, modulesPath, ... }: {
    deployment.targetHost = "nfs.local";
    deployment.targetUser = "root";

    imports = [
      ./nix/modules/common-lxc.nix
      ./nix/modules/nfs.nix
    ];
    
    system.stateVersion = "26.05"; 
  };
}
