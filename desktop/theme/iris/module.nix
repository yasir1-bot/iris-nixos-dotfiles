{ config, pkgs, lib, ... }:

let
  irisTemplatesDir = ./templates;
in
{
  # Iris does not ship native templates/modules for all target apps, so we install
  # custom templates into ~/.config/iris/templates for Iris to render into ~/.cache/iris.
  xdg.configFile."iris/templates/colors-ghostty.conf".source = "${irisTemplatesDir}/colors-ghostty.conf";
  xdg.configFile."iris/templates/colors-nushell.nu".source = "${irisTemplatesDir}/colors-nushell.nu";
  xdg.configFile."iris/templates/colors-starship.toml".source = "${irisTemplatesDir}/colors-starship.toml";
  xdg.configFile."iris/templates/colors-nvim.lua".source = "${irisTemplatesDir}/colors-nvim.lua";
  xdg.configFile."iris/templates/colors-quickshell.qml".source = "${irisTemplatesDir}/colors-quickshell.qml";
  xdg.configFile."iris/templates/colors-mango.conf".source = "${irisTemplatesDir}/colors-mango.conf";
  xdg.configFile."iris/templates/colors-gtk.css".source = "${irisTemplatesDir}/colors-gtk.css";

  # Helper script: generate Iris theme from a wallpaper and run app-specific reload hooks.
  # Iris itself has no watch/hooks; this script orchestrates regeneration + best-effort reloads.
  home.file.".local/bin/iris-theme" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      WALLPAPER="''${1:-}"
      MODE="''${2:--1}" # -1 auto, 0 light, 1 dark
      if [ -z "$WALLPAPER" ]; then
        echo "Usage: iris-theme <wallpaper-path> [--dark -1|0|1]" >&2
        exit 2
      fi

      mkdir -p "''${XDG_CONFIG_HOME:-$HOME/.config}/iris"
      printf '%s\n' "$WALLPAPER" > "''${XDG_CONFIG_HOME:-$HOME/.config}/iris/current-wallpaper"

      # Render templates and JSON outputs into ~/.cache/iris
      iris "$WALLPAPER" --dark "$MODE"

      # Best-effort reload hooks (app/version/session dependent; failures are non-fatal)
      if command -v mmsg >/dev/null 2>&1; then
        mmsg dispatch reload_config >/dev/null 2>&1 || true
      fi
      if command -v pkill >/dev/null 2>&1; then
        pkill -SIGUSR2 ghostty >/dev/null 2>&1 || true
      fi
      # Quickshell/Nushell/Neovim reloads are shell/editor-specific; Quickshell theme loader
      # should watch/read generated files or expose a reload action. Neovim can re-source on FocusGained.
      notify-send "Iris theme applied" "$(basename "$WALLPAPER")" >/dev/null 2>&1 || true
    '';
  };
}
