# Upstream Research

> Researched on 2026-11-16. This document records upstream findings (capabilities, issues/PRs, limitations) and planned/implemented responses for this dotfiles repository. **Do not fabricate upstream status; verify against linked sources.**

## Table of Contents

- [Iris (Harman1307/iris)](#iris-harman1307iris)
- [Noctalia legacy-v4 + Quickshell](#noctalia-legacy-v4--quickshell)
- [Mangowm / MangoWC](#mangowm--mangowc)
- [Ghostty, Nushell, Starship, Neovim/LazyVim](#ghostty-nushell-starship-neovimlazyvim)
- [Swiftify](#swiftify)
- [Cross-cutting implementation notes](#cross-cutting-implementation-notes)

---

## Iris (Harman1307/iris)

**Repository:** https://github.com/Harman1307/iris  
**API metadata:** https://api.github.com/repos/Harman1307/iris (created 2026-06-19, `pushed_at` 2026-08-05, language Python, license MIT, 3 open issues at time of fetch)  
**Package metadata:** `pyproject.toml` declares `iris-colors` v0.1.0, Python `>=3.9`, deps `Pillow>=10.0`, `numpy>=1.24`, console script `iris = "iris.cli:main"`  
**Key sources:** [README](https://raw.githubusercontent.com/Harman1307/iris/main/README.md), [pyproject.toml](https://raw.githubusercontent.com/Harman1307/iris/main/pyproject.toml), [cli.py](https://raw.githubusercontent.com/Harman1307/iris/main/iris/cli.py), [generator.py](https://raw.githubusercontent.com/Harman1307/iris/main/iris/generator.py), [templates/](https://api.github.com/repos/Harman1307/iris/contents/iris/templates)

### 1. What Iris is / how it works
- **CLI color-scheme generator** ("like pywal or matugen, but with semantic colors"), written in Python. Primary interface is `iris` (entrypoint `iris.cli:main`); no library API documented beyond modules.
- **Pipeline:** takes a wallpaper path, generates or loads cached theme, writes outputs unless `--json-only`.
  - Cache key hashes path + mtime + size + flags (`dark`, `glass`) via `get_cache_key`; theme cache: `~/.cache/wallpaper-colors/<key>.json`.
  - Image handling: thumbnail cache `~/.cache/wallpaper-thumbs/<basename>.thumb.jpg` if present, else source; downscale to 150x150; k-means in LAB (k=14) with spatial weighting.
  - Tone detection (dark/light/pure black/pure white/grayscale heuristics), semantic/UI/syntax color assignment with contrast nudging, fallback themes for errors.
- **Algorithm (README):** LAB k-means, spatial weighting, dominant bg, saturated accent, WCAG-oriented contrast checks, surface/dim variations, red/green/yellow hue assignment, 8 syntax hues rotated from bg hue, per-wallpaper cache, auto dark/light with override.

### 2. CLI, flags, and outputs
From [cli.py](https://raw.githubusercontent.com/Harman1307/iris/main/iris/cli.py):
- Positional: `wallpaper` (optional if `-i/--image` given)
- `-i, --image <path>`: wallpaper path
- `--dark { -1 | 0 | 1 }` (default `-1`): `-1=auto`, `0=light`, `1=dark`
- `--glass`: adjust background for transparency
- `--debug`: debug info to stderr
- `--json-only`: print JSON theme to stdout, **no files written**
- `--compat wal`: also write pywal-compatible files to `~/.cache/wal/`

**Default outputs** (unless `--json-only`): `~/.cache/iris/colors.json`, `colors.sh`, `colors.css` (`:root` vars), `sequences` (ANSI OSC 4/10/11), plus rendered built-in/user templates to `~/.cache/iris/<template-filename>`.
- **User templates:** `$(XDG_CONFIG_HOME or ~/.config)/iris/templates/` (PR #3/issue #2 fixed XDG handling).
- **Template syntax:** `{var}`, `{var.rgb}` (`r, g, b`), `{var.strip}` (hex without `#`). Variables include theme + terminal palette keys (so semantic/syntax keys in theme JSON can be referenced if present).

**Built-in templates:** `colors-kitty.conf`, `colors-hypr.conf`, `colors-waybar.css`, `colors-wayle.toml`.

### 3. Integrations / requested app coverage

| App/target | Native support in repo | Notes |
|---|---|---|
| Kitty | **Yes** | `colors-kitty.conf` (bg/fg/cursor/selection/colors 0–15). |
| Hyprland | **Yes** | `colors-hypr.conf` (`$bg/$fg/$accent/$surface/$red/$green/$yellow`, borders). |
| Waybar | **Yes** | `colors-waybar.css` (`@define-color`). |
| Wayle | **Yes** | `colors-wayle.toml` (added in merged PR #1). |
| Generic terminals | **Yes** | `sequences` (OSC). |
| Shell/CSS/JSON consumers | **Yes** | `colors.sh`, `colors.css`, `colors.json`. |
| pywal consumers | **Partial** | `--compat wal` writes wal-style cache files. |
| Ghostty | **No native template found** | Custom template/generic output likely needed. |
| Nushell | **No native template found** | Custom template likely needed. |
| Starship | **No native template found** | Custom template likely needed. |
| Neovim / LazyVim | **No native integration found** | Custom template/adapter consuming JSON/syntax vars likely needed. |
| Quickshell / QML | **Documented pattern, no native QML template** | README shows `--json-only` + parse stdout in QML `Process`. |
| GTK | **No native template found** | Custom template/adapter likely needed. |
| MPRIS apps / Swiftify | **No evidence** | No references found. |
| Mangowm | **No evidence** | No references found. |

### 4. Palette generation, regeneration/watch, hooks
- **Source:** wallpaper image (required). No manual palette mode found. Auto dark/light with override; `--glass` for transparency-adjusted bg. **Not a Material You engine** (custom algorithm).
- **Caching:** per-wallpaper+flags in `~/.cache/wallpaper-colors/<hash>.json`.
- **Automatic regeneration/watch mode:** **None found** (single-run CLI; no daemon/watcher/service).
- **Hooks/scripts on theme change:** **No built-in mechanism found**. Propagation relies on external reload/import/watch behavior.

### 5. NixOS / Home Manager packaging
- **Upstream repo:** no `flake.nix`, Nix package, HM module, or overlay found.
- **Ecosystem signals:** AUR `iris-colors` documented in README.
  - [#4 "Nixos package"](https://github.com/Harman1307/iris/issues/4) — closed/completed (packaging request).
  - [#5 "Nix package for iris"](https://github.com/Harman1307/iris/issues/5) — open; references community derivation: https://github.com/rootsysc4ll/.flux-dotfiles/blob/main/iris.nix (not independently verified here) and requests nixpkgs packaging.
- **Implication for this repo:** likely need local derivation/flake packaging and HM integration (declarative install + template/output wiring) until/unless upstream/nixpkgs support is confirmed.

### 6. Relevant issues and PRs

| # | State | Title | Relevance | Link |
|---|---|---|---|---|
| 7 | Open (PR) | Average cluster hue as an angle, not as a number | Proposed fix for hue averaging bug (#6); may affect palette correctness. | https://github.com/Harman1307/iris/pull/7 |
| 6 | Open (issue) | Hue is averaged arithmetically... (red image → olive background, green accent) | Algorithm bug/limitation in some wallpapers. | https://github.com/Harman1307/iris/issues/6 |
| 5 | Open (issue) | Nix package for iris | Community Nix derivation linked; nixpkgs/upstream packaging request. | https://github.com/Harman1307/iris/issues/5 |
| 4 | Closed (issue) | Nixos package | NixOS packaging request (closed by reporter). | https://github.com/Harman1307/iris/issues/4 |
| 3 | Closed, merged (PR) | use XDG_CONFIG_HOME when found | Respects `XDG_CONFIG_HOME` for `~/.config/iris/templates`. | https://github.com/Harman1307/iris/pull/3 |
| 2 | Closed (issue) | XDG_CONFIG_HOME not used | Motivation for #3. | https://github.com/Harman1307/iris/issues/2 |
| 1 | Closed, merged (PR) | add wayle theme template + update readme | Added `colors-wayle.toml`. | https://github.com/Harman1307/iris/pull/1 |

**Not found in fetched issues/PRs:** explicit hooks/watch mode, Mangowm support, Ghostty/Nushell/Starship/Neovim/GTK/MPRIS/Quickshell template requests, or HM module (absence-of-evidence).

### 7. Limitations and propagation strategy
- **Known issues (README):** some wallpapers extract bad colors; syntax colors may clash on grayscale wallpapers; first run slower, cached runs faster.
- **Open bug:** hue averaging can mis-hue clusters (#6/#7) — monitor/consider patch if impactful.
- **No watch/hooks:** regeneration and app reload must be orchestrated externally.
- **Propagation approach:** wire apps once to consume generated artifacts (`~/.cache/iris/*`, custom templates, or `colors.json`), rerun Iris on theme/wallpaper changes, and trigger app-specific reloads. Quickshell can consume `--json-only` (documented). Per-app custom templates/adapters expected for Ghostty, Nushell, Starship, Neovim/LazyVim, GTK, Mangowm, and Swiftify.

---

## Noctalia legacy-v4 + Quickshell

> **Scope:** `legacy-v4` is the older QML/Quickshell-style branch; current main/v5 has diverged significantly (C++/Meson hybrid). Items from v5 are labeled when referenced.

### 1. Noctalia legacy-v4 architecture and features
- **Primary sources:** https://github.com/noctalia-dev/noctalia/tree/legacy-v4, [shell.qml](https://raw.githubusercontent.com/noctalia-dev/noctalia/legacy-v4/shell.qml), [Commons/Settings.qml](https://raw.githubusercontent.com/noctalia-dev/noctalia/legacy-v4/Commons/Settings.qml), [ColorSchemeService.qml](https://raw.githubusercontent.com/noctalia-dev/noctalia/legacy-v4/Services/Theming/ColorSchemeService.qml), [Launcher.qml](https://raw.githubusercontent.com/noctalia-dev/noctalia/legacy-v4/Modules/Panels/Launcher/Launcher.qml), [ControlCenterPanel.qml](https://raw.githubusercontent.com/noctalia-dev/noctalia/legacy-v4/Modules/Panels/ControlCenter/ControlCenterPanel.qml), [Notification.qml](https://raw.githubusercontent.com/noctalia-dev/noctalia/legacy-v4/Modules/Notification/Notification.qml), [NotificationHistoryPanel.qml](https://raw.githubusercontent.com/noctalia-dev/noctalia/legacy-v4/Modules/Panels/NotificationHistory/NotificationHistoryPanel.qml), [legacy docs](https://docs.noctalia.dev/noctalia-shell-legacy/), [configure docs](https://docs.noctalia.dev/noctalia-shell-legacy/configuration/configure-noctalia/).
- **Structure:** `shell.qml` root composes **Modules** (Bar, Background, DesktopWidgets, Dock, LockScreen, MainScreen, Notification, OSD, Panels), **Panels** (Launcher, ControlCenter, NotificationHistory, Settings, etc.), **Services** (Compositor/UI/Hardware/Keyboard/Location/Networking/Noctalia/Power/System/Theming), **Commons** (Settings, Color, I18n, Logger, Style, migrations/state helpers), plus `Widgets/` (`N*`), `Assets/`, `Scripts/`, `Shaders/`, `nix/`.
- **Settings/config:** JSON `settings.json` with `settingsVersion` (observed 59 in gathered context) and migration logic; centralized schema/defaults; per-screen overrides; desktop widgets config.
- **Theming:** predefined color schemes (dark/light variants) in assets via `ColorSchemeService`; template/wallpaper-related theming pipeline present in services. **Material You not explicitly evidenced as named implementation** in cited legacy-v4 files — treat as predefined + variant + template/wallpaper-derived theming unless confirmed.
- **Launcher:** panel UI with query/input, provider-driven results/model, selection/activation, preview/details affordances (as implemented in panel QML/services).
- **Notifications:** popup/toast module (`Modules/Notification`) for incoming notifications (lifecycle/stacking/actions/rich content handling per implementation) + `NotificationHistoryPanel` for persisted/history view (grouping/clear/dismiss/DND interactions per panel/settings/services).
- **Control center:** aggregated quick controls/cards (system controls, media, network/bluetooth/power/audio/brightness etc. as available/configured) integrating multiple services.
- **Settings panel:** in-shell management over settings schema (tabs/categories), reflecting documented config surface.
- **Other modules:** bar, dock, lock screen, OSD, desktop widgets, background/main screen, tray/media widgets.
- **Plugins:** legacy-v4 plugin system documented; legacy plugin registry repo is archived: https://github.com/noctalia-dev/noctalia-plugins, docs: https://docs.noctalia.dev/noctalia-shell-legacy/development/plugins/overview/.

### 2. Quickshell capabilities (for native recreation)
- **Sources:** https://quickshell.outfoxxed.me/, https://github.com/quickshell-mirror/quickshell, type docs: [NotificationServer](https://quickshell.org/docs/v0.2.1/types/Quickshell.Services.Notifications/NotificationServer/), [Mpris](https://quickshell.org/docs/v0.2.1/types/Quickshell.Services.Mpris/), [SystemTray](https://quickshell.org/docs/v0.2.1/types/Quickshell.Services.SystemTray/SystemTray/), [Pipewire](https://quickshell.org/docs/v0.2.1/types/Quickshell.Services.Pipewire/), [UPower](https://quickshell.org/docs/v0.2.1/types/Quickshell.Services.UPower/), [Wayland BackgroundEffect](https://quickshell.org/docs/v0.3.0/types/Quickshell.Wayland/BackgroundEffect/), HM module: https://github.com/nix-community/home-manager/blob/master/modules/programs/quickshell.nix.
- **First-class/relevant support:** notification server, MPRIS, system tray (SNI), PipeWire audio, UPower/power profiles, Wayland layer-shell surfaces/panels, QtQuick animations/effects, optional Wayland background/blur effects (protocol/compositor-dependent).
- **Common gaps (require DBus/CLI/custom helpers):** NetworkManager Wi-Fi/cellular/VPN UX, BlueZ device-management UX, brightness/backlight control, idle/inhibitors, wallpaper engines, calendar/weather sources, polkit agents, some compositor-specific workspace/window IPC.
- **NixOS/HM:** HM `programs.quickshell` module exists; Noctalia legacy has NixOS docs/flake (`nix/`, `flake.nix`). nixpkgs PR context: https://github.com/NixOS/nixpkgs/pull/495434.

### 3. Recreating Noctalia-like UX natively in Quickshell
- **Architecture pattern:** `ShellRoot` + per-output surfaces; service singletons for notifications/MPRIS/tray/audio/power/network/brightness/theming/settings; panel/window loaders (layer-shell); models/repeaters for dynamic lists; optional IPC/commands.
- **Theming:** central design tokens (colors/radii/spacing/typography/opacity/blur/animation), curated dark/light palettes + optional wallpaper-derived accents/templates, reactive propagation and cached artifacts. Implement Material You only if palette extraction/generation is actually added.
- **Config:** JSON settings with version/migrations and per-output overrides (legacy pattern), runtime state/cache separate from declarative config.
- **UI parity targets:** bar modules, launcher providers/fuzzy search/keyboard nav, notification popups + history store (persistence/grouping/DND/actions), control center cards/widgets, settings schema UI, OSD/dock/lock/desktop widgets as feasible.
- **Effects:** QtQuick transitions/animations; transparency and blur with compositor/protocol feature-detection and fallbacks.

### 4. Feasibility and risks
| Area | Feasibility | Notes |
|---|---|---|
| Bar, panels, launcher/settings UI, widgets, OSD, animations, theming tokens | High | Core QML/Quickshell work. |
| Notification daemon + popups | High | `NotificationServer`. |
| Notification history center | High–Medium | UI easy; persistence/grouping/retention/action replay is custom. |
| MPRIS controls | High | First-class service; depends on player MPRIS correctness. |
| System tray | Medium–High | SNI/AppIndicator quirks vary by app. |
| Audio/UPower/power profiles | High | On supported stacks (PipeWire/UPower/PPD). |
| Network/Bluetooth/brightness | Medium | Typically DBus/CLI/service glue. |
| Wallpaper-derived dynamic theming | Medium | External generator/template integration effort. |
| Blur/translucent glass | Medium–Low (portability) | Compositor/protocol-dependent (`BackgroundEffect`); needs fallbacks. |
| Cross-compositor workspace/window behavior parity | Medium–Low | Depends on compositor protocols/IPC. |
| Pixel-perfect legacy-v4 clone | Medium | High visual parity feasible; full behavioral/integration parity is significant effort. |

### 5. Relevant issues/PRs and references
- **Noctalia (recent snapshot, mostly v5/main-era):** [#5398](https://github.com/noctalia-dev/noctalia/pull/5398) dock ordering, [#5378](https://github.com/noctalia-dev/noctalia/pull/5378) compositor icon-rect integration, [#5359](https://github.com/noctalia-dev/noctalia/pull/5359) tray left-click behavior (merged), [#5150](https://github.com/noctalia-dev/noctalia/issues/5150) taskbar sorting bug, [#4940](https://github.com/noctalia-dev/noctalia/issues/4940) fullscreen auto-hide, plugin/API items [#5394](https://github.com/noctalia-dev/noctalia/issues/5394)/[#5396](https://github.com/noctalia-dev/noctalia/pull/5396)/[#5393](https://github.com/noctalia-dev/noctalia/pull/5393), [#5391](https://github.com/noctalia-dev/noctalia/pull/5391) DriftWM support (draft). Legacy-v4-specific tracker not cleanly isolated in sampled API results; rely on branch code/docs and archived legacy plugins repo.
- **Quickshell (snapshot):** [#1448](https://github.com/quickshell-mirror/quickshell/pull/1448) Wayland render control/partial damage, [#1481](https://github.com/quickshell-mirror/quickshell/issues/1481) ScreencopyView crash, [#1484](https://github.com/quickshell-mirror/quickshell/issues/1484) iconPath cache/refresh issue, [#1198](https://github.com/quickshell-mirror/quickshell/issues/1198) GTK3 suspend/output SIGSEGV, [#566](https://github.com/quickshell-mirror/quickshell/pull/566) BackgroundEffect-related lineage.
- **Nix references:** HM Quickshell module, Noctalia legacy NixOS docs/flake, nixpkgs PR #495434. Example/reference configs to inspect: [oddlama/nix-config noctalia module](https://github.com/oddlama/nix-config/blob/main/users/malte/graphical/noctalia.nix), [matthew-hre/quickshell-config](https://github.com/matthew-hre/quickshell-config).

---

## Mangowm / MangoWC

**Canonical upstream:** https://github.com/mangowm/mango ("Mango Wayland Compositor"), docs: https://mangowm.github.io/  
**Naming:** `DreamMaoMao/mangowm` 404; older `mangowc/maomaowm` names appear historically. Example config: https://github.com/DreamMaoMao/mango-config.

### 1. NixOS / Home Manager integration
- **Flake outputs:** `hmModules.mango`, `nixosModules.mango`, packages incl. `mango`, `hm-options-json`, `nixos-options-json` ([flake.nix](https://raw.githubusercontent.com/mangowm/mango/main/flake.nix)).
- **HM module:** `wayland.windowManager.mango.*` (`enable`, `package`, `systemd.*`, `settings`, `extraConfig`, `autostart_sh`, `topPrefixes`, `bottomPrefixes`) — [hm-modules.nix](https://raw.githubusercontent.com/mangowm/mango/main/nix/hm-modules.nix), [nix-options](https://mangowm.github.io/docs/nix-options). Generates config from structured settings, can append extra/autostart, **validates** with `mango -c "$out" -p`. Declarative ownership caveat: imperative edits may be overwritten on switch; running session may need explicit reload.
- **NixOS module:** `programs.mango.enable/package/addLoginEntry` (default true). Ref: [NixOS Wiki: Mango](https://wiki.nixos.org/wiki/Mango).

### 2. Configuration, reload, and IPC
- **Config:** `~/.config/mango/config.conf` (or `config.toml`), fallback `/etc/mango/config.conf`; `mango -c <path>` load, `-p` validate. Supports `key=value`, `source/source_optional`, `env`, `var/$name`, `exec_once/exec`.
- **Capabilities:** animations, gaps, borders/radius/colors/opacity/state colors, tags/workspaces/tag rules/scratchpad, layouts (`tile`, `scroller`, `vertical_scroller`, `monocle`, `grid`, `deck`, `center_tile`, `vertical_tile`, `right_tile`, `vertical_grid`, `vertical_deck`, `dwindle`, `fair`, `vertical_fair`), floating/snap, extensive window/tag/layer rules, key/mouse/gesture/switch bindings and `key_mode` submaps.
  - Docs: [Basics](https://mangowm.github.io/docs/configuration/basics), [Layouts](https://mangowm.github.io/docs/window-management/layouts), [Rules](https://mangowm.github.io/docs/window-management/rules), [Bindings](https://mangowm.github.io/docs/bindings/keys), [Theming](https://mangowm.github.io/docs/visuals/theming), [Effects](https://mangowm.github.io/docs/visuals/effects), [Misc](https://mangowm.github.io/docs/configuration/miscellaneous).
- **Reload:** `auto_reload_config` (default 1), `reload_config` dispatcher, `load_config_file,<path>`, temporary `setoption,key,value`; `mangonag` on invalid config.
- **IPC (`mmsg`, socket in `MANGO_INSTANCE_SIGNATURE`):** `get` (version/cursorpos/keymode/keyboardlayout/monitor/client/tag/tags/all-*/last_open_surface), `watch` (monitor/client/tags/all-*/keymode/keyboardlayout/last_open_surface), `dispatch <func>,[args...] [client,<id>]`. [IPC docs](https://mangowm.github.io/docs/ipc).

### 3. "Infinite desktop layout" feasibility
- **No native infinite desktop/canvas layout found upstream.** Layout list has no infinite/canvas; overview/jump/overcircle/switcher and scroller layouts are **not** a pannable infinite 2D canvas.
- **No direct upstream issue/PR/discussion found** implementing/requesting it by name in targeted searches.
- **Non-upstream:** [NaitreHUD](https://github.com/librepup/NaitreHUD) fork advertises `infinite` layout/actions — **fork-specific, not upstream**.
- **Conclusion:** do not claim native support. Approximations: scroller/vertical_scroller + overview workflows, or other compositors/forks if mandatory.

### 4. Quickshell as GUI frontend and safe config updates
- **Compatibility:** layer-shell surfaces supported (`layer_rule`, layer inspection); Quick Start lists Quickshell/shell ecosystem. Validate per setup.
  - Caveat: [#590 ignore_alpha on blur](https://github.com/mangowm/mango/issues/590) (open) affects Quickshell-based shells (Noctalia mentioned).
- **Programmatic flow:** persistent updates via atomic write + `mango -c -p` validation + `reload_config` (or `auto_reload_config` after validation); ephemeral preview via `setoption`; alternate config via `load_config_file`.
- **Nix/HM tension:** GUI mutation of HM-generated config conflicts with declarative ownership; consider isolated `source/source_optional` fragments, clear ownership/sync, or GUI-as-editor feeding validated persisted settings/rebuilds.

### 5. Relevant issues/PRs/discussions
| Item | Status/type | Relevance | Link |
|---|---|---|---|
| GUI config editor request | Discussion #493 (Ideas) | GUI config editor; Nix/HM considerations | https://github.com/mangowm/mango/discussions/493 |
| Structured Configuration Support for HM Module | PR #667 (referenced) | HM structured settings evolution | https://github.com/mangowm/mango/pull/667 |
| feat(nix): add hjem-module based on HM module | PR #1123 (referenced) | Additional Nix integration | https://github.com/mangowm/mango/pull/1123 |
| nix flake forgets to require wev | Issue #971 (referenced) | Nix packaging/integration example | https://github.com/mangowm/mango/issues/971 |
| [Feature Request] ignore_alpha on blur | Issue #590 (open) | Quickshell/shell blur/shadow behavior | https://github.com/mangowm/mango/issues/590 |
| low fps at 4k resolution | Issue #998 (referenced) | Perf caveat in shell-heavy setups | https://github.com/mangowm/mango/issues/998 |
| Ambxst quickshell support | awesome-mango #1 (referenced) | Ecosystem signal | https://github.com/mangowm/awesome-mango/issues/1 |
| Auto Config Reload | v0.18.0 release | `auto_reload_config` context | https://github.com/mangowm/mango/releases/tag/0.18.0 |

### 6. Shell-relevant compositor features
- Layer shell, blur/transparency/shadows/opacity/radius/dim, window/layer animations, XDG portals, XWayland/tearing/VRR/idle inhibit/monitor controls, rich IPC.
- **System tray:** not explicitly documented as compositor feature in fetched docs; typically provided by bar/shell.

---

## Ghostty, Nushell, Starship, Neovim/LazyVim

*Snapshot: 2026-11-16 (upstream docs, HM/Nixpkgs sources, GitHub issues/PRs/discussions).*

### 1. Ghostty
- **Config:** plain text `key = value` (`config.ghostty`), CLI-flag parity, `config-file` (optional `?` prefix), `theme = <name|path>` or light/dark pair, themes in `$XDG_CONFIG_HOME/ghostty/themes` and `$PREFIX/share/ghostty/themes`. Padding (`window-padding-x/y`, `window-padding-balance`) and rich font options.
- **Transparency/blur:** `background-opacity`, `background-opacity-cells`, `background-blur`. **Wayland blur is compositor/protocol/version dependent** (movement toward `ext-background-effect-v1`; KDE/GNOME/GTK transitions have caused regressions/limits). Best-effort, host-gated.
- **Reload/generated themes:** consumes generated theme/config files and optional includes well. **No automatic file-watch reload**. Manual `reload_config`; some options need new surfaces/restart. `SIGUSR2` reload exists in newer/tip contexts (version-dependent).
- **HM:** `programs.ghostty.*` (`enable`, `package`, `settings`, `themes`, `clearDefaultKeybinds`, syntax install, shell integrations, `systemd.enable`).
- **Refs:** [Config](https://ghostty.org/docs/config), [Reference](https://ghostty.org/docs/config/reference), [Theme](https://ghostty.org/docs/features/theme), [HM options](https://home-manager.dev/manual/unstable/options/home-manager/programs/ghostty.html), [module](https://github.com/nix-community/home-manager/blob/master/modules/programs/ghostty.nix). Issues/discussions: [#449](https://github.com/ghostty-org/ghostty/issues/449), [#7747](https://github.com/ghostty-org/ghostty/issues/7747), [#4626](https://github.com/ghostty-org/ghostty/issues/4626), [#10721](https://github.com/ghostty-org/ghostty/issues/10721), [PR #10727](https://github.com/ghostty-org/ghostty/pull/10727), [#8903](https://github.com/ghostty-org/ghostty/issues/8903), [PR #9360](https://github.com/ghostty-org/ghostty/pull/9360), [#3643](https://github.com/ghostty-org/ghostty/discussions/3643), [#3963](https://github.com/ghostty-org/ghostty/discussions/3963), [#4280](https://github.com/ghostty-org/ghostty/discussions/4280), [#10394](https://github.com/ghostty-org/ghostty/discussions/10394), [#10719](https://github.com/ghostty-org/ghostty/discussions/10719), [#13041](https://github.com/ghostty-org/ghostty/discussions/13041), [#13068](https://github.com/ghostty-org/ghostty/discussions/13068), [#13378](https://github.com/ghostty-org/ghostty/discussions/13378), [#13578](https://github.com/ghostty-org/ghostty/discussions/13578).

### 2. Nushell
- **Config/load:** `env.nu`, `config.nu`, vendor/user autoload dirs, `login.nu`. `$env.config` for behavior/UI, `$env.*` for environment.
- **Theming:** `$env.config.color_config`, `LS_COLORS`, prompts/hooks; external config via `source` of generated `.nu`, autoload files, or explicit assignment.
- **Hot reload:** no automatic watch/reapply in running REPL; new session or manual re-source/re-eval.
- **Starship:** prompt env vars/closures calling `starship prompt` or `starship init nu`; HM `programs.starship.enableNushellIntegration`.
- **HM:** `programs.nushell.*` (config/env/login files, extra*, settings -> `$env.config.*`, aliases, plugins). **Caveat:** settings flattening can break whole-record replacements (nested `color_config`) — use `lib.hm.nushell.mkNushellInline` or explicit text assignment ([HM #6750](https://github.com/nix-community/home-manager/issues/6750)).
- **Refs:** [Configuration](https://www.nushell.sh/book/configuration.html), [Environment](https://www.nushell.sh/book/environment.html), [Coloring/Theming](https://www.nushell.sh/book/coloring_and_theming.html), [3rd Party Prompts](https://www.nushell.sh/book/3rdpartyprompts.html), [HM options](https://nix-community.github.io/home-manager/options/home-manager/programs/nushell.html), [module](https://github.com/nix-community/home-manager/blob/master/modules/nushell.nix), [NixOS Wiki](https://wiki.nixos.org/wiki/Nushell). Issues/PRs: [HM #6750](https://github.com/nix-community/home-manager/issues/6750), [HM #6941](https://github.com/nix-community/home-manager/pull/6941), [HM #6484](https://github.com/nix-community/home-manager/issues/6484), [HM #6434](https://github.com/nix-community/home-manager/issues/6434), [nushell #17965](https://github.com/nushell/nushell/issues/17965).

### 3. Starship
- **Config:** TOML (`~/.config/starship.toml`, `STARSHIP_CONFIG`), palettes (`palettes.<name>`, `palette = "..."`) — strong fit for generated palette fragments.
- **Reload:** re-evaluated per prompt (typically next prompt).
- **HM:** `programs.starship.*` (settings, presets, configPath, shell integrations). Runtime mutation conflicts with immutable HM store-symlink configs; use merge/Nix generation, mutable `STARSHIP_CONFIG` path, or rebuild flow.
- **Refs:** [Configuration](https://starship.rs/config/), [Presets](https://starship.rs/presets/), [HM options](https://home-manager.dev/manual/unstable/options/home-manager/programs/starship.html), [module](https://github.com/nix-community/home-manager/blob/master/modules/programs/starship.nix). Issues/PRs: [HM #7297](https://github.com/nix-community/home-manager/issues/7297), [HM #8214](https://github.com/nix-community/home-manager/pull/8214), [noctalia #3101](https://github.com/noctalia-dev/noctalia/issues/3101), [#2467](https://github.com/noctalia-dev/noctalia/issues/2467).

### 4. Neovim / LazyVim
- **LazyVim upstream:** [LazyVim/LazyVim](https://github.com/LazyVim/LazyVim), [lazyvim.org](https://www.lazyvim.org/). Starter bootstraps `lazy.nvim` and imports `lazyvim.plugins` + local `plugins`.
- **NixOS/HM strategy (recommended baseline):** HM/Nix manages Neovim + LSPs/formatters/linters/tools (and optionally parsers/core plugins); keep LazyVim/lazy.nvim Lua config mostly upstream-compatible. Alternatives include Nix-managed plugin/dev-path setups (higher maintenance, may fight Mason/auto-install assumptions — [Discussion #1972](https://github.com/LazyVim/LazyVim/discussions/1972)) or wrapper ecosystems (lazyvim-nix, nixCats, nixvim/nvf) with added abstraction.
- **Dynamic colorscheme:** generate Lua module/file (e.g. `lua/generated/iris.lua` or `colors/iris.lua`) applied via LazyVim/custom spec. Runtime reload needs explicit logic (clear `package.loaded`, reapply highlights on autocmd/focus/event, optional `uv.fs_event` watcher scheduled to UI, or RPC/remote command); plugin highlight refresh may vary.
- **Tooling defaults:** provide LSP/formatter/linter/debugger/build deps via Nix/devShells/PATH, disable/override Mason auto-installs when needed, ensure `git/ripgrep/fd/clipboard/C compiler` as required, prefer `direnv`/`nix develop`.
- **Refs:** [Installation](https://www.lazyvim.org/installation), [Configuration](https://www.lazyvim.org/configuration), [lazy.nvim config](https://www.lazyvim.org/configuration/lazy.nvim), [Neovim autocmd](https://neovim.io/doc/user/autocmd). Ecosystem: [Discussion #1972](https://github.com/LazyVim/LazyVim/discussions/1972), [pfassina/lazyvim-nix](https://github.com/pfassina/lazyvim-nix), [josh/lazy-nvim-nix](https://github.com/josh/lazy-nvim-nix), [b-src/lazy-nix-helper.nvim](https://github.com/b-src/lazy-nix-helper.nvim), [folke/lazy.nvim #488](https://github.com/folke/lazy.nvim/issues/488), [LazyVim #2350](https://github.com/LazyVim/LazyVim/discussions/2350).

### 5. Cross-cutting propagation guidance
| App | Consume generated output | Watch/reload | Notes |
|---|---|---|---|
| Ghostty | `config-file = ?...`, `theme`, or generated theme file | No file watch; manual `reload_config`; `SIGUSR2` on supported versions | Some options need new surfaces/restart; blur compositor-dependent |
| Nushell | `source`/autoload generated `*.nu` | No live REPL reapply; restart or manual `source` | HM `settings` flattening caveat for nested `color_config` |
| Starship | generated palette TOML / merged settings / `STARSHIP_CONFIG` | Typically next prompt | Avoid mutating HM store symlinks at runtime |
| Neovim/LazyVim | generated Lua colorscheme/module | Explicit in-editor watcher/autocmd/RPC/command | Clear `package.loaded` before re-require; plugin refresh varies |

---

## Swiftify

**Repository:** https://github.com/swiftify-org/swiftify | **Homepage:** https://shredos.dev | **Snapshot:** 2026-11-16 (README, releases, issues/PRs, packaging tree)

### 1. What it is
- **Native app (not Electron):** Qt Quick UI on **Rust core wrapping librespot** (Qt 6.10+, QtKeychain, QCoro, CMake/Ninja, C++20, Rust/Corrosion). Linux (Wayland/Hyprland-focused), macOS, Windows.
- **Playback model:** **Spotify-first** (requires **Spotify Premium** + user client ID for Web API/library/playlists/search; playback via librespot). Optional **Spotify Soloist** workaround for some audio-key failures (`SWIFTIFY_PLAYBACK=librespot` to disable). See [#20](https://github.com/swiftify-org/swiftify/issues/20).
- **Features:** Material 3-inspired UI, immersive player, synced lyrics, visualizers, equalizer/tempo/pitch, **local files with local playlists and editable track metadata**, Discord RPC, queue/session restore, stats, CLI flags.
- **Activity:** active (releases reviewed up to v0.25.x, Oct 31 2026 snapshot).

### 2. Requested feature feasibility

| Requested area | Evidence-based status | Feasibility |
|---|---|---|
| **YouTube Music** | No evidence of support in reviewed sources. | **Not feasible (unsupported).** Major backend/UI work/fork required. |
| **Local files / `~/Music/Playlist`** | Local files + local playlists with editable metadata supported; local-file fixes/features exist ([v0.17.1](https://github.com/swiftify-org/swiftify/releases/tag/v0.17.1), [#151](https://github.com/swiftify-org/swiftify/pull/151), [#106](https://github.com/swiftify-org/swiftify/pull/106)). Specific auto-scan/watch for `~/Music/Playlist` **not documented**. | **Supported in principle; workflow/path must be verified in-app/source. Do not assume.** |
| **Remove Spotify provider / Spotify-specific functionality** | Core dependency on Spotify stack; no provider toggle/multi-provider architecture evidenced. | **Not feasible out-of-box; likely deep fork/rearchitecture.** |
| **Remove/hide Apple/macOS-style window buttons** | v0.15.0: toggle for button side; [#155](https://github.com/swiftify-org/swiftify/pull/155) (open/on hold) Linux resize handles. No option to hide/remove entirely found. | **Not feasible out-of-box** (side placement configurable; removal likely QML/UI patch/fork). |
| **Theming/custom CSS** | No custom CSS evidenced; [#144](https://github.com/swiftify-org/swiftify/pull/144) custom theme studio **open/on hold**. | **Limited today;** deep visual customization likely requires source changes. |

### 3. MPRIS / Quickshell integration
- **Linux MPRIS supported/intended:** README documents MPRIS (media keys, `playerctl`, shell widgets), logind, PipeWire/PulseAudio device changes, tray; `-DSWIFTIFY_DESKTOP_INTEGRATION=OFF` disables.
- **History:** [v0.15.0](https://github.com/swiftify-org/swiftify/releases/tag/v0.15.0) added MPRIS; [#14](https://github.com/swiftify-org/swiftify/issues/14) (**closed/completed**, `633df35`) fixed MPRIS instantiation issue (important for older builds).
- **Path:** standard **MPRIS D-Bus** consumption by Quickshell/`playerctl` (no Quickshell-specific API evidenced). Validate with `playerctl -l` and MPRIS inspection in session.
- **Assessment:** **feasible in intent and likely workable** with correct build/runtime.

### 4. NixOS packaging
- **In-repo:** no `flake.nix`/Nix package. No confirmed nixpkgs attribute/official flake found in reviewed sources.
- **Channels:** AUR (`swiftify-bin`, `swiftify`, `swiftify-git`), COPR, prebuilt tarball, source build.
- **Declarative approach:** likely custom derivation/flake (Qt 6.10+ modules, QtKeychain-Qt6, QCoro, Rust, CMake/Ninja, C++20, ALSA/libpulse/OpenSSL/pkg-config/libsecret; Corrosion/font fetches may need vendoring/FOD handling). Runtime: secret service, MPRIS/D-Bus, tray, PipeWire/PulseAudio.

### 5. Relevant issues/PRs
| # | State | Relevance | Link |
|---|---|---|---|
| 14 | Closed/completed | MPRIS instantiation fix (`633df35`) | https://github.com/swiftify-org/swiftify/issues/14 |
| 153 | Open (bug) | Audio distortion on NixOS with Soloist + PipeWire | https://github.com/swiftify-org/swiftify/issues/153 |
| 155 | Open/on hold | Linux frameless window resize handles | https://github.com/swiftify-org/swiftify/pull/155 |
| 151 | Merged | Local-file Discord RPC fallback images | https://github.com/swiftify-org/swiftify/pull/151 |
| 106 | Merged | Volume normalization incl. local files | https://github.com/swiftify-org/swiftify/pull/106 |
| 144 | Open/on hold (draft) | Custom theme studio (not CSS), unmerged | https://github.com/swiftify-org/swiftify/pull/144 |
| 20 | Closed | Spotify audio-key/librespot limitation; Soloist workaround | https://github.com/swiftify-org/swiftify/issues/20 |
| 114 | Open (question) | Ongoing Soloist issue (v0.25.1) | https://github.com/swiftify-org/swiftify/issues/114 |

**Not found in targeted searches:** explicit implementation/requests for YouTube Music, configurable `~/Music/Playlist` auto-scan, Spotify provider removal/disable, custom CSS, or complete window-button hiding (absence not exhaustive proof).

### 6. Bottom line
- **Potential fit:** MPRIS-based shell media controls and local-file playback in principle.
- **Does not meet strict requested spec without major work:** Spotify dependency remains, no YouTube Music, `~/Music/Playlist` workflow unverified, button removal/theming unsupported out-of-box.
- **Project stance:** document limitations honestly, avoid claiming unsupported functionality, prefer MPRIS if included, and evaluate packaging/fork effort or alternative MPRIS-capable players for strict local/YT requirements.

---

## Cross-cutting implementation notes

- **Iris as central engine:** use Iris outputs (`~/.cache/iris/colors.json`, templates, `--json-only`) as single palette source. Add custom Iris templates/adapters for Ghostty, Nushell, Starship, Neovim/LazyVim, Quickshell theme tokens, MangoWC/Mangowm config fragments, and GTK where feasible. Orchestrate regeneration + per-app reloads externally (no Iris watch/hooks).
- **Declarative vs runtime state:** Nix/HM-managed base config + validated generated fragments; prefer stable include/source paths. Avoid runtime mutation of HM store symlinks. GUI-to-declarative workflow must be safe (validation, atomic writes, no arbitrary command execution from UI input, clear rebuild/rollback behavior).
- **MangoWC GUI settings:** feasible via `mmsg`/dispatch + config fragment writes + `mango -c -p` validation + reload, but persistence/ownership with HM must be designed carefully. Infinite desktop not native upstream.
- **Quickshell/Noctalia parity:** high-fidelity recreation feasible for most surfaces; hardest areas are portable blur, network/bluetooth/brightness glue, and cross-compositor behavior parity.
- **Swiftify:** MPRIS integration plausible; requested source/provider/UI changes largely not upstream-supported. Treat as best-effort/integration target with documented constraints, or substitute/augment with a player that natively fits YT Music + local library + MPRIS if required.
- **Testing transparency:** distinguish syntax/eval/static checks from untested graphical/runtime behavior on real hardware/session.

---

## NixOS-WSL (`wsl-test` branch)

- **Upstream:** [nix-community/NixOS-WSL](https://github.com/nix-community/NixOS-WSL) ([docs](https://nix-community.github.io/NixOS-WSL/)).
- **Integration:** add `nixos-wsl.url = "github:nix-community/NixOS-WSL/main"` and include `nixos-wsl.nixosModules.default`; set `wsl.enable = true` ([flakes how-to](https://nix-community.github.io/NixOS-WSL/how-to/nix-flakes.html)).
- **Root filesystem:** upstream docs and module source show WSL owns the distro root; no `fileSystems."/"`, `/boot`, bootloader, or generated hardware config should be declared. No upstream option requires btrfs was found; normal WSL2 distro roots are ext4 `.vhdx` files. The branch exposes `iris.wsl.rootFsType` (default `ext4`, can be set to `btrfs`) only for NixOS filesystem support, not disk conversion.
- **`nixos-generate-config` noise:** the `ERROR: not a btrfs filesystem: /mnt/wslg/distro` / `/tmp/.X11-unix` messages come from `nixos-generate-config` running `btrfs subvol show` on WSLg bind mounts ([source](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/installer/tools/nixos-generate-config.pl)). They are harmless stderr, but the generated `fileSystems` entries are not wanted. Use `--no-filesystems` (and filter stderr) via `scripts/generate-wsl-config.sh`, or skip hardware config entirely.
- **GUI/session:** WSLg provides the Wayland/X11 environment; MangoWC is disabled on this branch to avoid competing with WSLg. Quickshell/app configs remain available for manual launch/testing.
- **Refs:** [module options](https://nix-community.github.io/NixOS-WSL/options.html), [wsl-distro module](https://github.com/nix-community/NixOS-WSL/blob/main/modules/wsl-distro.nix), [flake source](https://github.com/nix-community/NixOS-WSL/blob/main/flake.nix).
