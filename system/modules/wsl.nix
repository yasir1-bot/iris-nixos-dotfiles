{ config, lib, pkgs, ... }:

let
  cfg = config.iris.wsl;
in
{
  options.iris.wsl = {
    enable = lib.mkEnableOption "NixOS-WSL compatibility tweaks";

    rootFsType = lib.mkOption {
      type = lib.types.enum [ "ext4" "btrfs" ];
      default = "ext4";
      description = ''
        Filesystem used by the WSL distro root.

        WSL2 stores a normal distro root in an ext4 .vhdx, so ext4 is the safe
        default. Change this single setting to "btrfs" only if your WSL distro
        root really is btrfs. This does not format or convert the disk; it only
        makes sure NixOS includes support for the selected filesystem.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    wsl.enable = true;

    # WSL manages mounts. Do not declare fileSystems."/" or /boot here.
    boot.supportedFilesystems = [ cfg.rootFsType ];

    wsl.wslConf.boot.systemd = true;
    wsl.wslConf.automount.enabled = true;
  };
}
