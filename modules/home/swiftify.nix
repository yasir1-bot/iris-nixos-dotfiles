{ config, pkgs, lib, ... }:

{
  # Swiftify integration (best-effort / documented limitations).
  #
  # Upstream research (2026-11-16): Swiftify is a Spotify-first Qt Quick/Rust (librespot) client
  # requiring Spotify Premium + user client ID. No evidence of YouTube Music support, no
  # provider-toggle/Spotify-removal architecture, no complete window-button hiding, and no
  # in-repo Nix flake/package. Linux MPRIS support is intended/documented (see upstream issue #14 fix),
  # so shell media controls should integrate via MPRIS when a working build is installed.
  #
  # Requested behavior NOT feasible out-of-box: remove Spotify provider/UI, YouTube Music backend,
  # guaranteed ~/Music/Playlist auto-scan workflow, and removal of Apple-style window buttons.
  # These would require source verification/forking/major development and must not be claimed as done.
  #
  # TODO: add a verified Nix derivation/flake package for Swiftify (build deps include Qt 6.10+,
  # QtKeychain-Qt6, QCoro, Rust/CMake/Ninja/C++20, Corrosion/fetch steps) or an alternative
  # MPRIS-capable player that natively supports local library + YouTube Music if strict requirements apply.

  home.packages = with pkgs; [
    playerctl # MPRIS inspection/control for shell integration and debugging
  ];

  xdg.desktopEntries.swiftify-note = {
    name = "Swiftify (Integration Notes)";
    comment = "Swiftify requires manual/packaged install; see docs/upstream-research.md for limitations";
    exec = "xdg-open ${config.home.homeDirectory}/.dotfiles/docs/upstream-research.md";
    terminal = false;
    categories = [ "Audio" "AudioVideo" "Player" ];
  };
}
