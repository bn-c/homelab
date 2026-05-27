{
  meta = {
    nixpkgs = import <nixpkgs> {
      system = "x86_64-linux";
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
}