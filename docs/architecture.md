# Architecture

## Overview

This repository is a modular, declarative NixOS + Flakes + Home Manager dotfiles system centered on **Iris** as the single theme/palette source. The desktop targets **MangoWC** (Wayland compositor/window manager) with a custom **Quickshell** shell inspired heavily by **Noctalia legacy-v4**.

## Layers

1. **Flake (`flake.nix`)**
   - Pins inputs: `nixpkgs`, `home-manager`, `mango` (MangoWC), `quickshell`.
   - Exposes NixOS and Home Manager configurations, local packages/overlays (e.g. `iris-colors`), and checks.
2. **Host configuration (`hosts/desktop/`)**
   - System-level NixOS settings: boot, users, networking, audio, portals, MangoWC system integration, baseline packages.
   - Includes a placeholder/example hardware configuration; real installs must replace it.
3. **Home Manager (`home.nix`, `modules/home/`)**
   - User environment, shell/editor/terminal configs, Quickshell config deployment, MangoWC HM settings, theming orchestration, and desktop settings file.
4. **Application/config assets (`config/`)**
   - `config/iris/templates/`: custom Iris templates rendered into `~/.cache/iris/` for apps without native Iris support.
   - `config/quickshell/`: QML shell (services, components/panels, theme loading).
   - `config/desktop/settings.json`: persisted UI/runtime preferences (graphical settings source of truth for user-facing state).
   - App-specific configs for Ghostty, Nushell, Starship, Neovim/LazyVim.
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
  1. UI writes `config/desktop/settings.json` (and/or Mango fragment) atomically.
  2. Validate schema/values and compositor config (`mango -c <file> -p` for Mango fragments where applicable).
  3. Reload runtime state (`mmsg dispatch reload_config` / `setoption` for previews) as appropriate.
  4. Optional controlled rebuild: fixed allowlisted `nixos-rebuild switch --flake <trusted>#desktop` via `scripts/apply-settings.sh` with proper privilege handling (polkit/sudoers), feedback, and rollback awareness.
- **Never** execute arbitrary shell commands derived from UI input.

## Limitations / design constraints (from research)

- **Infinite desktop:** no native upstream MangoWC support found; represented as requested-but-unavailable in settings/docs.
- **Swiftify:** Spotify-first, no YouTube Music, no provider removal, local `~/Music/Playlist` workflow unverified, window-button removal/theming limited; MPRIS integration is the primary shell path when available.
- **Blur/protocol behavior:** compositor/protocol/version dependent (Ghostty/Quickshell/MangoWC effects).
- **Graphical runtime behavior:** untested in this environment; static/config validation does not prove end-to-end desktop behavior.
