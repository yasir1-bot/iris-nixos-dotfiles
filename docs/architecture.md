# Architecture

## Overview

This repository is a modular, declarative NixOS + Flakes + Home Manager dotfiles system centered on **Iris** as the single theme/palette source. The desktop targets **MangoWC** (Wayland compositor/window manager) with a custom **Quickshell** shell inspired heavily by **Noctalia legacy-v4**.

## Repository layout (dendritic)

```text
.
├── flake.nix                 # flake entrypoint/outputs
├── home.nix                  # Home Manager entrypoint/module aggregator
├── system/                   # host configs, shared NixOS modules, local packages
│   ├── hosts/desktop/
│   ├── modules/
│   └── packages/iris-colors/
├── desktop/                  # theme, compositor, shell, persisted settings
│   ├── settings/
│   ├── theme/iris/
│   ├── compositor/mangowm/
│   └── shell/quickshell/
├── apps/                     # terminal, editor, media integrations
│   ├── terminal/ghostty/
│   ├── editor/neovim/
│   └── media/swiftify/
├── shell/                    # shell environment modules (Nushell, Starship)
├── scripts/                  # safe apply/validate helpers
└── docs/                     # architecture, install, theming, troubleshooting, research
```

## Layers

1. **Flake (`flake.nix`)**
   - Pins inputs: `nixpkgs`, `home-manager`, `mango` (MangoWC), `quickshell`.
   - Exposes NixOS and Home Manager configurations, local packages/overlays (e.g. `iris-colors`), and checks.
2. **Host configuration (`system/hosts/desktop/`)**
   - System-level NixOS settings: boot, users, networking, audio, portals, MangoWC system integration, baseline packages.
   - Includes a placeholder/example hardware configuration; real installs must replace it.
3. **Home Manager (`home.nix`)**
   - User environment and module aggregation. Modules are organized under the `desktop/`, `apps/`, and `shell/` branches.
4. **Application/config assets**
   - `desktop/theme/iris/templates/`: custom Iris templates rendered into `~/.cache/iris/` for apps without native Iris support.
   - `desktop/shell/quickshell/config/`: QML shell (services, components/panels, theme loading).
   - `desktop/settings/settings.json`: persisted UI/runtime preferences (graphical settings source of truth for user-facing state).
   - App-specific modules/configs under `apps/terminal/ghostty/`, `shell/nushell/`, `shell/starship/`, and `apps/editor/neovim/`.
5. **Scripts (`scripts/`)**
   - Safe helpers for applying settings and validation (allowlisted commands only; no arbitrary UI-driven execution).

## Theming data flow (Iris-centered)

1. User selects wallpaper/mode (CLI or shell UI action).
2. `iris-theme`/Iris generates palette + outputs to `~/.cache/iris/` (and cache under `~/.cache/wallpaper-colors/`).
3. Custom Iris templates render app-specific artifacts (Ghostty, Nushell, Starship, Neovim Lua, Quickshell tokens, Mango fragment, GTK hints).
4. Apps consume generated artifacts via includes/sources/imports or runtime loaders.
5. Best-effort reload hooks are triggered where supported (e.g. Mango `reload_config`, Ghostty `SIGUSR2` on supported versions, Neovim autocmd/user command). Some apps require restart/new session/next prompt.

> Iris has no built-in watch/daemon/hooks (per upstream research). Propagation is orchestrated externally.

## Quickshell shell architecture (Noctalia-inspired)

- **`shell.qml`**: root composition, per-screen surfaces, panel visibility/state, notification server wiring.
- **Services**: theme tokens/defaults, notification history model, and integration points for MPRIS/PipeWire/UPower/SystemTray/NetworkManager/BlueZ/brightness (some require DBus/CLI helpers).
- **Components/Panels**: bar, launcher, notification center, control center, settings panel (layer-shell surfaces).
- **Design goals**: cohesive Material You-inspired look driven by Iris tokens, rounded/translucent surfaces, animations, and modular widgets.

## MangoWC integration and GUI-to-declarative settings

- **Base config**: declarative via `wayland.windowManager.mango.settings` (HM module validates generated config at build time).
- **Runtime/GUI adjustments**: prefer a sourced fragment (e.g. `source_optional` to a UI-managed file) or persisted settings that drive regeneration, to avoid mutating HM-owned store files.
- **Apply flow (intended/safe):**
  1. UI writes `desktop/settings/settings.json` (and/or Mango fragment) atomically.
  2. Validate schema/values and compositor config (`mango -c <file> -p` for Mango fragments where applicable).
  3. Reload runtime state (`mmsg dispatch reload_config` / `setoption` for previews) as appropriate.
  4. Optional controlled rebuild: fixed allowlisted `nixos-rebuild switch --flake <trusted>#desktop` via `scripts/apply-settings.sh` with proper privilege handling (polkit/sudoers), feedback, and rollback awareness.
- **Never** execute arbitrary shell commands derived from UI input.

## Limitations / design constraints (from research)

- **Infinite desktop:** no native upstream MangoWC support found; represented as requested-but-unavailable in settings/docs.
- **Swiftify:** Spotify-first, no YouTube Music, no provider removal, local `~/Music/Playlist` workflow unverified, window-button removal/theming limited; MPRIS integration is the primary shell path when available.
- **Blur/protocol behavior:** compositor/protocol/version dependent (Ghostty/Quickshell/MangoWC effects).
- **Graphical runtime behavior:** untested in this environment; static/config validation does not prove end-to-end desktop behavior.
