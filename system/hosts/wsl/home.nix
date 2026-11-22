{ config, pkgs, lib, inputs, self, ... }:

{
  imports = [
    ../../../home.nix
    ../../../desktop/compositor/sway/module.nix
  ];

  # MangoWC is installed and its config validated at build time, but it is not
  # started at login: WSLg owns the default Wayland session. Its nested launcher
  # (`./scripts/start-mango-wsl.sh`) is best-effort only on stock WSL kernels.
  # sway is the working nested fallback here: pixman + shm needs no DRM node or
  # custom kernel. Launch it on demand with `./scripts/start-sway-wsl.sh` too.

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };
}
