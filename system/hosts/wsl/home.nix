{ config, pkgs, lib, inputs, self, ... }:

{
  imports = [ ../../../home.nix ];

  # MangoWC is installed and its config validated at build time, but it is not
  # started at login: WSLg owns the default Wayland session. Launch it on demand
  # with `./scripts/start-mango-wsl.sh` to run it nested in a WSLg window.

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };
}
