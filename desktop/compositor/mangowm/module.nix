{ config, pkgs, lib, ... }:

{
  # Declarative MangoWC configuration via upstream Home Manager module.
  # Graphical/UI-managed overrides should be written to a sourced fragment (see docs/architecture.md)
  # to avoid HM/store ownership conflicts; this module provides the stable base.
  wayland.windowManager.mango = {
    enable = true;

    settings = {
      # General behavior
      animations = 1;
      animation_duration_open = 300;
      animation_duration_close = 300;
      animation_duration_focus = 300;
      animation_duration_move = 300;
      animation_duration_tag = 300;
      border_px = 2;
      gap_inner_horizontal = 8;
      gap_inner_vertical = 8;
      gap_outer_horizontal = 8;
      gap_outer_vertical = 8;
      sloppy_focus = 1;

      # Colors: defaults here; Iris-generated fragment can override via source/include workflow.
      # Use Mango's expected format (verify in target version/docs).
      border_color = "0x444444aa";
      focus_color = "0x89b4faaa";

      # Layout/tag defaults (tile is upstream's default layout)
      tag_num = 9;

      bind = [
        "SUPER,Return,spawn,ghostty"
        "SUPER,Space,spawn,qs ipc call shell toggleLauncher"
        "SUPER,Q,killclient"
        "SUPER,F,togglefloating"
        "SUPER,1,view,1"
        "SUPER,2,view,2"
        "SUPER,3,view,3"
        "SUPER,4,view,4"
        "SUPER,5,view,5"
        "SUPER,6,view,6"
        "SUPER,7,view,7"
        "SUPER,8,view,8"
        "SUPER,9,view,9"
        "SUPER SHIFT,R,reload_config"
      ];

      # Start the custom Quickshell shell on session start (adjust command/path as needed)
      exec_once = [
        "quickshell -p ${config.xdg.configHome}/quickshell/shell.qml"
      ];

      # Optional: source a UI-managed fragment for runtime-adjustable settings.
      # source_optional = "${config.xdg.configHome}/desktop/mango-ui.conf";
    };
  };
}
