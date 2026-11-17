# Troubleshooting

## Nix / Flake

- **`nix flake check` or evaluation fails**
  - Ensure inputs are reachable and pinned refs are valid.
  - `system/packages/iris-colors/default.nix` uses placeholder `rev/hash` by design until pinned; run `nix build .#iris-colors` to obtain the correct hash.
  - Quickshell input source/ref may need adjustment for your nixpkgs/HM version and platform.
- **Hardware/session boot issues**
  - Replace `system/hosts/desktop/hardware-configuration.example.nix` with a generated hardware config.
  - Verify bootloader, filesystem UUIDs/labels, GPU drivers, and Wayland prerequisites.

## MangoWC

- **Config not applying**
  - Validate config: `mango -c ~/.config/mango/config.conf -p` (or target file).
  - Trigger reload: `mmsg dispatch reload_config` (requires running Mango session and `MANGO_INSTANCE_SIGNATURE`).
  - Check for `mangonag` error bar output when config is invalid.
- **HM-managed config overwritten**
  - HM owns generated config; persist UI/runtime overrides in a sourced fragment or via declarative settings workflow.

## Quickshell

- **Shell fails to start**
  - Launch manually for logs: `quickshell -p ~/.config/quickshell/shell.qml`
  - Verify required services/deps are available (PipeWire, MPRIS providers, NetworkManager, BlueZ, etc.). Some controls are placeholders and need backend wiring per host.
- **Theme not updating**
  - Confirm `~/.cache/iris/colors-quickshell.qml` or theme source is generated and the shell imports/reloads it.
- **Blur/transparency issues**
  - Dependent on compositor/protocol support and MangoWC/Quickshell capabilities; use fallbacks if unsupported.

## Iris / Theming

- **No outputs generated**
  - Run `iris /path/to/wallpaper.jpg --debug` and verify wallpaper path/readability.
  - Check template installation in `~/.config/iris/templates/` and rendered files in `~/.cache/iris/`.
- **Colors look wrong on some wallpapers**
  - Known upstream limitation; see open hue-averaging issue/PR (#6/#7) in `docs/upstream-research.md`.
- **App not changing theme**
  - Confirm the app consumes the generated file (include/source/import path) and perform the required reload action (see `docs/theming.md`).

## Ghostty / Nushell / Starship / Neovim

- **Ghostty theme unchanged:** ensure `config-file = ?~/.cache/iris/colors-ghostty.conf` resolves and reload config (`SIGUSR2` if supported, or manual reload/new surface).
- **Nushell colors unchanged:** source path must exist; restart shell or re-source generated file.
- **Starship palette unchanged:** prompt updates next render if config path is correct; avoid immutable HM store config mutation at runtime.
- **Neovim colors unchanged:** run `:IrisReload`, ensure `~/.cache/iris/colors-nvim.lua` exists/readable; LazyVim/lazy.nvim bootstrap requires network/git on first run unless adapted for offline/Nix-managed plugins.

## Swiftify / Media

- **MPRIS controls not working**
  - Verify player is running and exposes MPRIS: `playerctl -l`, `playerctl metadata`.
  - Swiftify requires a Linux build with desktop integration/MPRIS enabled (upstream fix in issue #14 relevant for older builds).
- **Requested Swiftify features unavailable**
  - YouTube Music, Spotify provider removal, verified `~/Music/Playlist` auto-scan workflow, and window-button removal are not supported out-of-box per research; see `docs/upstream-research.md`.

## Safe rebuild/settings issues

- `scripts/apply-settings.sh` only performs allowlisted operations (copy/validate settings, optional fixed rebuild command). If rebuild fails, inspect `nixos-rebuild` output and roll back via previous generation/boot entry as appropriate.
- Do not configure UI actions to pass arbitrary command strings; always validate and constrain inputs.
