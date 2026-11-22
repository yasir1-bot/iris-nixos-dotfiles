{ config, pkgs, lib, ... }:

{
  # WSL-only nested sway fallback. Deliberately does not use Home Manager's
  # wayland.windowManager.sway module: WSLg owns the session and sway must be
  # launched on demand via scripts/start-sway-wsl.sh, never at login.
  home.packages = with pkgs; [ sway ];

  xdg.configFile."sway/config".source = ./config;
}
