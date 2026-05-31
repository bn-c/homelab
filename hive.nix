{
  meta = {
    nixpkgs = import <nixpkgs> {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
  };

  mkLxcNode = host: module: {
    deployment.targetHost = host;
    deployment.targetUser = "root";
    imports = [
      ./nix/modules/common-lxc.nix
      module
    ];
    system.stateVersion = "26.05";
  };

  transmission = mkLxcNode "transmission.local" ./nix/modules/transmission.nix;
  prowlarr = mkLxcNode "prowlarr.local" ./nix/modules/prowlarr.nix;
  kasm = mkLxcNode "kasm.local" ./nix/modules/kasm.nix;
  owncast = mkLxcNode "owncast.local" ./nix/modules/owncast.nix;
  cftest = mkLxcNode "cftest.local" ./nix/modules/cloudflared.nix;
  flaresolverr = mkLxcNode "flaresolverr.local" ./nix/modules/flaresolverr.nix;
  mc = mkLxcNode "mc.local" ./nix/modules/mc.nix;
  nfs = mkLxcNode "nfs-nixos.local" ./nix/modules/nfs.nix;
}
