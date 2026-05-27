{
  meta = {
    nixpkgs = import <nixpkgs> {
      system = "x86_64-linux";
    };
  };

  qbittorrent = { name, nodes, pkgs, modulesPath, ... }: {
    deployment.targetHost = "qbittorrent.local";
    deployment.targetUser = "root";

    imports = [
      ./nix/modules/common-lxc.nix
      ./nix/modules/qbittorrent.nix
    ];
    
    system.stateVersion = "26.05"; 
  };
}