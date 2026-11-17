{ config, pkgs, lib, inputs, self, ... }:

{
  imports = [ ../../../home.nix ];

  # WSLg already provides a Wayland compositor. Keep the shell/application
  # configs, but do not start MangoWC or declare Mango-specific bindings here.
  wayland.windowManager.mango.enable = lib.mkForce false;

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };
}
