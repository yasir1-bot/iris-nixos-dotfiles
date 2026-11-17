{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [ ../../modules/wsl.nix ];

  iris.wsl = {
    enable = true;

    # Single setting to change if your WSL root filesystem is btrfs.
    rootFsType = "ext4";
  };

  wsl = {
    defaultUser = "user";
    startMenuLaunchers = true;
    useWindowsDriver = true;
  };

  networking.hostName = "wsl";
  time.timeZone = "UTC";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.users.user = {
    isNormalUser = true;
    description = "User";
    home = "/home/user";
    shell = pkgs.nushell;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  security.sudo.wheelNeedsPassword = lib.mkDefault false;
  services.dbus.enable = true;

  # NixOS-WSL recommends the release matching the installed system.
  system.stateVersion = "25.05";
}
