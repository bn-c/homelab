# Carrier Command 2 Server Setup

To deploy the Carrier Command 2 server, you must first download the game files manually to this machine because `steamcmd` requires interactive authentication.

## Prerequisites

Ensure `steamcmd` is installed on your host machine:

```bash
sudo add-apt-repository multiverse
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install steamcmd
```

## Downloading Game Files

1. Run the following command to download the server files to the required local directory:

```bash
/usr/games/steamcmd \
  +@sSteamCmdForcePlatformType windows \
  +force_install_dir "/root/nfs/homelab/nix/modules/cc2/game_files/" \
  +login techtheawesome \
  +app_update 1489630 validate \
  +app_update 1007 validate \
  +workshop_download_item 1489630 2824746567 \
  +workshop_download_item 1489630 2990101940 \
  +quit
```

2. After the download finishes, verify the files are present:
   `ls -la /root/nfs/homelab/nix/modules/cc2/game_files/`

3. Once verified, run `colmena apply` to deploy the server.
