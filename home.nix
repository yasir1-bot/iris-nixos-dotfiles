{ config, pkgs, lib, inputs, self, ... }:

let
  dotfilesDir = "${config.home.homeDirectory}/.dotfiles"; # expected checkout location for rebuild scripts
  desktopSettings = ./config/desktop/settings.json;
in
{
  imports = [
    ./modules/home/theming.nix
    ./modules/home/quickshell.nix
    ./modules/home/mangowm.nix
    ./modules/home/ghostty.nix
    ./modules/home/nushell.nix
    ./modules/home/starship.nix
    ./modules/home/neovim.nix
    ./modules/home/swiftify.nix
  ];

  home.username = "user";
  home.homeDirectory = "/home/user";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # Theme engine and helpers
    self.packages.${pkgs.stdenv.hostPlatform.system}.iris-colors
    jq
    socat
    libnotify

    # Media/network/bluetooth/brightness helpers used by shell scripts
    playerctl
    brightnessctl
    wireplumber
    networkmanager
    bluez
  ];

  # Central persisted GUI/runtime preferences consumed by Nix modules and/or Quickshell.
  # This file is intended to be edited by the settings UI (with validation) and can be read
  # by modules/scripts for rebuild-time declarative application.
  xdg.configFile."desktop/settings.json".source = desktopSettings;

  # Convenient aliases for applying theme and rebuilding (review scripts before use).
  home.shellAliases = {
    iris-apply = "iris $(cat ${config.xdg.configHome}/iris/current-wallpaper 2>/dev/null || echo '')";
    dots-rebuild = "sudo nixos-rebuild switch --flake ${dotfilesDir}#desktop";
  };

  # Ensure user service env is reasonable for Wayland sessions.
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };
}
