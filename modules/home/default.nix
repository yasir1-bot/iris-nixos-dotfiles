{ ... }:
{
  # Aggregator for Home Manager modules (optional; home.nix currently imports modules explicitly).
  imports = [
    ./theming.nix
    ./quickshell.nix
    ./mangowm.nix
    ./ghostty.nix
    ./nushell.nix
    ./starship.nix
    ./neovim.nix
    ./swiftify.nix
  ];
}
