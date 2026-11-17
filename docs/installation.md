# Installation

> **Status:** This repository provides a complete declarative scaffold and configuration set, but some integrations depend on upstream/Nix availability, hardware, and a running Wayland session. Review `docs/upstream-research.md` and validate on target hardware.

## Prerequisites

- NixOS (recommended: unstable channel alignment with flake inputs, or adjust pins accordingly)
- Flakes enabled (`nix.settings.experimental-features = [ "nix-command" "flakes" ];`)
- Git
- A Wayland-capable GPU/session environment suitable for MangoWC

## Fresh NixOS install (recommended flow)

1. **Clone the repository**
   ```bash
   git clone <your-repo-url> ~/.dotfiles
   cd ~/.dotfiles
   ```

2. **Generate hardware configuration**
   ```bash
   sudo nixos-generate-config --show-hardware-config > system/hosts/desktop/hardware-configuration.nix
   ```
   Update `system/hosts/desktop/default.nix` to import `./hardware-configuration.nix` instead of the example placeholder.

3. **Review and customize**
   - `system/hosts/desktop/default.nix`: hostname, timezone, locale, user name/groups, bootloader, networking, GPU/audio specifics.
   - `home.nix`: username/home directory, dotfiles path assumptions, desired packages.
   - `flake.nix`: input refs/pins as needed (notably `quickshell` source/ref and `iris-colors` src rev/hash).
   - `desktop/settings/settings.json`: default wallpaper path, UI preferences.

4. **Fix local package hashes/pins (if needed)**
   - `system/packages/iris-colors/default.nix` contains placeholders (`rev`, `hash = lib.fakeHash`). Build once to obtain the correct hash:
     ```bash
     nix build .#iris-colors
     ```
     Update the hash/rev accordingly.

5. **Build/switch**
   ```bash
   sudo nixos-rebuild switch --flake .#desktop
   ```

6. **Log into MangoWC session** (via your configured greeter/display manager/session entry) and start/verify Quickshell shell if not auto-started.

## Updating

```bash
cd ~/.dotfiles
nix flake update        # optional: update inputs
sudo nixos-rebuild switch --flake .#desktop
```

For Home Manager-only testing (where applicable):
```bash
home-manager switch --flake .#user@desktop
```

## Theming (Iris)

- Install/select a wallpaper and apply theme:
  ```bash
  ~/.local/bin/iris-theme /path/to/wallpaper.jpg -1
  ```
  (`-1` auto, `0` light, `1` dark)
- Generated outputs are written to `~/.cache/iris/` via Iris + custom templates in `~/.config/iris/templates/`.
- See `docs/theming.md` for per-app propagation and reload behavior.

## Notes

- **Swiftify:** not declaratively packaged by this repo yet and does not satisfy all requested feature constraints upstream; see `docs/upstream-research.md`.
- **Infinite desktop:** requested but not natively supported by upstream MangoWC as of research date.
- **Graphical settings rebuild button:** implemented as a safe, allowlisted workflow design/script hook; privilege escalation (polkit/sudoers) must be configured explicitly on the target system.
