{ config, pkgs, lib, ... }:

{
  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    enableBashIntegration = false;
    enableZshIntegration = false;

    settings = {
      add_newline = false;
      command_timeout = 1000;
      format = "$directory$git_branch$git_status$character";
      right_format = "$cmd_duration$nix_shell";

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vimcmd_symbol = "[❮](bold green)";
      };

      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
        style = "bold cyan";
      };

      git_branch = {
        format = " [$branch]($style)";
        style = "bold purple";
      };

      git_status = {
        format = " [$all_status$ahead_behind]($style)";
        style = "bold yellow";
      };

      cmd_duration = {
        min_time = 1500;
        format = " [$duration]($style)";
      };

      nix_shell = {
        format = " [nix:$state]($style)";
        symbol = "";
      };

      # Iris palette can be overlaid by generating a TOML fragment and switching STARSHIP_CONFIG
      # or by regenerating this managed config in a declarative workflow. See docs/theming.md.
    };
  };

  # Runtime overlay option (if using mutable theme file strategy): point Starship to a generated config.
  # home.sessionVariables.STARSHIP_CONFIG = "${config.home.homeDirectory}/.cache/iris/colors-starship.toml";
}
