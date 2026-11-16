# Iris-Centered NixOS Dotfiles (MangoWC + Quickshell)

A cohesive, declarative **NixOS + Flakes + Home Manager** desktop environment built around **Iris** as the central theming engine. It targets **MangoWC** (Wayland compositor/window manager) and a custom **Quickshell** shell inspired heavily by **Noctalia legacy-v4**, with integrated configurations for **Ghostty**, **Nushell**, **Starship**, **Neovim/LazyVim**, and **Swiftify** (best-effort/MPRIS-oriented).

> **Important:** This repository was implemented with mandatory upstream research and honest capability tracking. Not all requested upstream features exist natively (e.g. MangoWC infinite desktop, Swiftify Spotify removal/YouTube Music). See [`docs/upstream-research.md`](docs/upstream-research.md).

## Highlights

- **Single palette source:** Iris-generated colors/templates intended to flow to shell and applications (no per-app independent palette generation).
- **Modular architecture:** flake-based hosts/modules/config separation for maintainability and reproducibility.
- **Quickshell shell (Noctalia-inspired):** bar, launcher, notification center/history, control center, and settings panel scaffolding with Iris-driven theme tokens, MPRIS/notification service integration points.
- **MangoWC integration:** declarative HM module configuration, reload/IPC-aware workflow, and GUI-to-declarative settings design with safety constraints.
- **Application theming:** custom Iris templates/adapters for Ghostty, Nushell, Starship, Neovim/LazyVim, Quickshell, MangoWC fragments, and GTK hints.
- **Research-driven:** upstream issues/PRs/capabilities/limitations documented with links and implementation implications.

## Repository structure

```text
.
├── flake.nix
├── home.nix
├── hosts/desktop/
├── modules/
│   ├── home/              # HM modules: theming, quickshell, mangowm, apps, shell
│   └── nixos/
├── config/
│   ├── desktop/settings.json
│   ├── iris/templates/    # custom Iris templates for app integrations
│   ├── quickshell/        # shell.qml, services, components
│   ├── mangowm/           # UI-managed fragments/notes (as used)
│   ├── ghostty/, nvim/, nushell/, starship/
├── pkgs/iris-colors/      # local Iris package derivation (pin/hash TODO)
├── scripts/               # safe apply/validate helpers
└── docs/                  # architecture, install, theming, troubleshooting, upstream research
```

## Installation

See [`docs/installation.md`](docs/installation.md) for fresh NixOS setup, hardware config generation, hash/pin steps, and rebuild commands.

Quick start (on target NixOS machine, after customization):
```bash
git clone <repo-url> ~/.dotfiles
cd ~/.dotfiles
sudo nixos-generate-config --show-hardware-config > hosts/desktop/hardware-configuration.nix
# edit hosts/desktop/default.nix + flake.nix/home.nix + pkgs/iris-colors pins as needed
sudo nixos-rebuild switch --flake .#desktop
```

## Theming workflow

1. Set/select wallpaper and run Iris (`~/.local/bin/iris-theme <wallpaper> [-1|0|1]`).
2. Iris renders outputs to `~/.cache/iris/` using built-in + custom templates.
3. Apps consume generated files (includes/sources/loaders); reload hooks applied where supported.

Details: [`docs/theming.md`](docs/theming.md)

## Graphical settings -> declarative workflow

- UI preferences are persisted in `config/desktop/settings.json` (and/or sourced fragments for runtime components like MangoWC where appropriate).
- `scripts/apply-settings.sh` provides an allowlisted, safe save-and-optional-rebuild flow.
- Design requires validation, atomic writes, least-privilege escalation (polkit/sudoers), and no arbitrary command execution from UI input.

Details: [`docs/architecture.md`](docs/architecture.md)

## Application integration status

| Component | Status | Notes |
|---|---|---|
| Iris | Integrated as central engine (local package/templates) | No upstream watch/hooks; propagation orchestrated externally |
| MangoWC | Declarative HM/system integration scaffolded | Infinite desktop **not native upstream**; GUI config via safe fragment/reload/rebuild design |
| Quickshell | Noctalia-inspired shell scaffold (bar/launcher/notifications/control center/settings) | Full legacy-v4 parity and backend wiring require further iteration/testing on hardware |
| Ghostty | HM config + Iris theme include | Blur/reload behavior compositor/version dependent |
| Nushell | HM config + Iris color source + Starship integration | Reload on new session/re-source |
| Starship | HM config + Iris palette fragment strategy | Readable, minimal prompt defaults |
| Neovim/LazyVim | LazyVim bootstrap config + Iris Lua theme loader | Runtime lazy.nvim bootstrap; Nix-managed tooling |
| Swiftify | Research + MPRIS integration intent + limitations documented | Spotify-first upstream; no YT Music/provider removal as requested; packaging not completed |

## Testing and validation

- **Performed in this environment:** repository scaffolding, configuration authoring, and documentation of research findings.
- **Not fully verifiable here:** end-to-end graphical runtime on MangoWC/Wayland, hardware-dependent blur/audio/network/bluetooth behavior, and real `nixos-rebuild` on target hardware.
- Use `scripts/validate.sh` and target-system checks (`nix flake show/check`, `mango -c -p`, `quickshell -p ...`, `playerctl -l`, etc.).

## Known limitations

- No native upstream MangoWC infinite desktop/canvas layout (researched 2026-11-16).
- Swiftify cannot meet strict requested changes out-of-box (Spotify removal, YouTube Music, verified `~/Music/Playlist` auto-scan, full window-button removal/theming constraints).
- Iris lacks native templates/hooks for several targets; custom templates and external reload orchestration are required.
- Some visual effects (blur/transparency) and controls depend on compositor/protocol/runtime support.

## Documentation

- [`docs/upstream-research.md`](docs/upstream-research.md)
- [`docs/architecture.md`](docs/architecture.md)
- [`docs/installation.md`](docs/installation.md)
- [`docs/theming.md`](docs/theming.md)
- [`docs/troubleshooting.md`](docs/troubleshooting.md)

## License

TODO: Add a license (e.g. MIT) and verify compatibility with upstream components/configurations you include or adapt.
