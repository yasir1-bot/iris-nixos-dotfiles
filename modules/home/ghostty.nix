{ config, pkgs, lib, ... }:

{
  programs.ghostty = {
    enable = true;
    enableBashIntegration = false;
    enableZshIntegration = false;
    enableFishIntegration = false;
    settings = {
      # Visual identity (Iris colors are applied via optional generated theme include)
      background-opacity = 0.92;
      # background-blur is compositor/protocol/version dependent; enable/tune per host if supported.
      window-padding-x = 12;
      window-padding-y = 12;
      font-family = "JetBrainsMono Nerd Font";
      font-size = 12;

      # Iris-generated theme fragment (written to ~/.cache/iris/colors-ghostty.conf by custom template)
      config-file = "?${config.home.homeDirectory}/.cache/iris/colors-ghostty.conf";

      # Nushell as default interactive shell in terminal sessions
      command = "${pkgs.nushell}/bin/nu";
    };
  };
}
