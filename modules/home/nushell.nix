{ config, pkgs, lib, ... }:

{
  programs.nushell = {
    enable = true;

    # Keep base config declarative; Iris colors are sourced from a generated file.
    extraConfig = ''
      # Source Iris-generated Nushell color/prompt overrides if present.
      const iris_colors = "${config.home.homeDirectory}/.cache/iris/colors-nushell.nu"
      if ($iris_colors | path exists) { source $iris_colors }

      $env.config = ($env.config | merge {
        show_banner: false
        edit_mode: vi
        render_right_prompt_on_last_line: false
      })

      # Useful aliases/functions
      alias ll = ls -la
      alias la = ls -a
      alias gs = git status
      alias gd = git diff

      def dots [] { cd ${config.home.homeDirectory}/.dotfiles }
    '';

    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake ${config.home.homeDirectory}/.dotfiles#desktop";
    };
  };

  # Ensure Nushell is available as a login shell option.
  home.packages = [ pkgs.nushell ];
}
