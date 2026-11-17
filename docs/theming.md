# Theming (Iris)

## Central principle

**Iris** is the single source of truth for palette generation in this repository. Applications should consume Iris-generated outputs/templates rather than maintain independent color definitions.

Upstream facts (researched 2026-11-16): Iris is a CLI generator (wallpaper -> palette/theme), caches per wallpaper+flags, renders built-in/user templates to `~/.cache/iris/`, supports `--json-only`, has **no built-in watch/daemon/hooks**, and has no native templates/integrations for several target apps (Ghostty, Nushell, Starship, Neovim/LazyVim, GTK, MangoWC, Swiftify). See `docs/upstream-research.md` for details and issue/PR links.

## Generation workflow

1. Choose wallpaper (and optional mode: auto/light/dark, glass).
2. Run Iris (directly or via helper):
   ```bash
   iris /path/to/wallpaper.jpg --dark -1
   # or
   ~/.local/bin/iris-theme /path/to/wallpaper.jpg -1
   ```
3. Iris writes outputs such as `~/.cache/iris/colors.json`, `colors.sh`, `colors.css`, `sequences`, and any rendered templates.
4. Custom templates installed by this repo (HM-managed) are sourced from `~/.config/iris/templates/` and rendered by Iris to `~/.cache/iris/<name>`.

## Custom templates provided

- `colors-ghostty.conf` -> Ghostty `config-file` include
- `colors-nushell.nu` -> sourced by Nushell config when present
- `colors-starship.toml` -> palette/config fragment (runtime `STARSHIP_CONFIG` or declarative merge strategy)
- `colors-nvim.lua` -> Lua table consumed by `apps/editor/neovim/config/lua/theme/iris.lua`
- `colors-quickshell.qml` -> Quickshell theme token singleton/template (integration/wiring may require runtime path strategy)
- `colors-mango.conf` -> MangoWC color fragment (source/include workflow; verify option names/format per Mango version)
- `colors-gtk.css` -> best-effort GTK color hints (toolkit/app dependent)

## Propagation and reload behavior

| Component | Consumption | Reload behavior | Notes |
|---|---|---|---|
| Quickshell | Generated theme tokens / JSON loader (implementation-dependent) | Reload shell or implement file watch/reload action | Keep tokens centralized in shell theme service |
| Ghostty | `config-file = ?~/.cache/iris/colors-ghostty.conf` | Manual reload or `SIGUSR2` on supported versions; no file watch | Some options apply to new surfaces/restart; blur compositor-dependent |
| Nushell | `source` generated `colors-nushell.nu` if present | New session or manual `source` | HM settings flattening caveats for nested color config (see research) |
| Starship | Palette TOML fragment / config path strategy | Typically next prompt | Avoid runtime mutation of HM store symlinks |
| Neovim/LazyVim | `~/.cache/iris/colors-nvim.lua` loaded by `lua/theme/iris.lua` | On startup, `FocusGained`, and `:IrisReload` | Plugin highlight refresh may vary |
| MangoWC | Sourced color fragment / declarative settings | `mmsg dispatch reload_config` or auto-reload depending on setup | Validate config before applying persistent changes |
| GTK apps | Generated CSS hints / theme integration tooling | App/session dependent | Best-effort; GTK theming varies by toolkit/version |

## Light/dark and wallpaper changes

- Use `iris --dark -1|0|1` to control mode.
- Theme changes should be propagated by regenerating Iris outputs and triggering relevant reload hooks; no per-app manual color edits should be required once wired.
- For automatic propagation on wallpaper change, integrate the `iris-theme` helper into your wallpaper setter/bar action (outside Iris itself).

## Troubleshooting

- Verify templates are installed: `~/.config/iris/templates/`
- Verify rendered outputs: `~/.cache/iris/`
- Validate JSON: `jq . ~/.cache/iris/colors.json`
- Re-run with debug: `iris /path/to/wallpaper.jpg --debug`
- See `docs/troubleshooting.md` for common issues.
