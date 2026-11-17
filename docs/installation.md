# Installation

> **WSL test branch.** This configuration targets NixOS-WSL under WSL2 with WSLg. NixOS-WSL owns the root filesystem; do not generate or declare hardware/boot filesystems here.

## Prerequisites

- Windows 10/11 with WSL2 and WSLg enabled
- NixOS-WSL distro installed from `nix-community/NixOS-WSL` releases
- Flakes enabled (`nix.settings.experimental-features = [ "nix-command" "flakes" ];`)
- Git

## Fresh NixOS install (recommended flow)

1. **Clone the repository**
   ```bash
   git clone <your-repo-url> ~/.dotfiles
   cd ~/.dotfiles
   ```

2. **Optional hardware config (no filesystems)**
   NixOS-WSL provides the root filesystem and kernel environment, so no hardware config is required.
   If you want CPU/PCI/module hints, generate a filesystem-free one with:
   ```bash
   ./scripts/generate-wsl-config.sh
   ```
   This writes `system/hosts/wsl/hardware-configuration.nix` and is imported automatically if present.
   Do **not** use plain `nixos-generate-config --show-hardware-config`: it probes WSLg bind mounts with
   `btrfs subvol show` and emits noisy `ERROR: not a btrfs filesystem: /mnt/wslg/distro` messages.

3. **Review and customize**
   - `system/hosts/wsl/default.nix`: hostname, user, WSL options, and `iris.wsl.rootFsType` (change only if your distro root is btrfs).
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
   sudo nixos-rebuild switch --flake .#wsl
   ```

6. **Log into the WSL distro** with `wsl -d NixOS` and verify the shell/apps. MangoWC is disabled on this branch; WSLg provides the Wayland compositor.

## Updating

```bash
cd ~/.dotfiles
nix flake update        # optional: update inputs
sudo nixos-rebuild switch --flake .#wsl
```

For Home Manager-only testing (where applicable):
```bash
home-manager switch --flake .#user@wsl
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
