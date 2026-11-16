{ config, pkgs, lib, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # Tooling managed declaratively by Nix (LazyVim/lazy.nvim can still manage editor plugins).
    extraPackages = with pkgs; [
      git
      ripgrep
      fd
      gcc
      nodejs
      lua-language-server
      stylua
      nil
      nixfmt-rfc-style
      shfmt
      shellcheck
    ];
  };

  # LazyVim-based configuration (starter-style, upstream-compatible).
  # Plugin management is primarily handled by lazy.nvim at runtime for parity with LazyVim;
  # LSP/formatters/tools are provided by Nix above.
  xdg.configFile."nvim".source = ../../config/nvim;
  xdg.configFile."nvim".recursive = true;
}
