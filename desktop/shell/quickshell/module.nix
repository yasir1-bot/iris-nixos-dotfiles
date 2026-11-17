{ config, pkgs, lib, inputs, ... }:

let
  qsDir = ./config;
in
{
  # Install the Quickshell shell configuration. HM `programs.quickshell` can be used if
  # available/preferred in the target nixpkgs/HM version; this keeps config explicit.
  xdg.configFile."quickshell" = {
    source = qsDir;
    recursive = true;
  };

  home.packages = [
    # Prefer the flake input package when available for the target system.
    inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default
  ] ++ (
    # Runtime dependencies commonly needed for shell controls/widgets (best-effort baseline).
    with pkgs; [
      networkmanager
      bluez
      brightnessctl
      wireplumber
      playerctl
      libnotify
    ]
  );
}
