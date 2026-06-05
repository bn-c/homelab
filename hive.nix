let
  mkLxcNode = host: module: {
    deployment.targetHost = host;
    deployment.targetUser = "root";
    deployment.buildOnTarget = true;
    imports = [
      ./nix/modules/common-lxc.nix
      module
    ];
    system.stateVersion = "26.05";
  };
  mkVmNode = host: module: { modulesPath, ... }: {
    deployment.targetHost = host;
    deployment.targetUser = "root";
    deployment.buildOnTarget = true;
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
      module
    ];
    
    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
    
    boot.loader.grub.enable = true;
    boot.loader.grub.device = "/dev/vda";

    services.openssh.enable = true;
    services.openssh.settings.PermitRootLogin = "yes";
    services.qemuGuest.enable = true;
    system.stateVersion = "26.05";
  };
in
{
  meta = {
    nixpkgs = import <nixpkgs> {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
  };

  transmission = mkLxcNode "transmission.local" ./nix/modules/transmission.nix;
  prowlarr = mkLxcNode "prowlarr.local" ./nix/modules/prowlarr.nix;
  kasm = mkLxcNode "kasm.local" ./nix/modules/kasm.nix;
  owncast = mkLxcNode "owncast.local" ./nix/modules/owncast.nix;
  cloudflared = mkLxcNode "cftest.local" ./nix/modules/cloudflared.nix;
  flaresolverr = mkLxcNode "flaresolverr.local" ./nix/modules/flaresolverr.nix;
  mc = mkLxcNode "mc.local" ./nix/modules/mc.nix;
  nfs = mkLxcNode "nfs-nixos.local" ./nix/modules/nfs.nix;
}
