{
  meta = {
    nixpkgs = import <nixpkgs> {
      system = "x86_64-linux";
    };
  };

  qbittorrent = { name, nodes, pkgs, ... }: {
    deployment.targetHost = "qbittorrent.local";
    deployment.targetUser = "root";

    imports = [
      ./nix/modules/qbittorrent.nix
    ];
    
    boot.isContainer = true;
    system.stateVersion = "26.05"; 
  };
}