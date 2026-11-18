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

4. **Local package pin**
   - `system/packages/iris-colors/default.nix` pins Iris at upstream `v0.1.2` (`0b7daec66dc5f84dfc557f437c6b73a4b59399c0`) with a verified hash. If you intentionally update the pin, replace both `rev` and `hash` and rebuild:
     ```bash
     nix build .#iris-colors
     ```

5. **Build/switch**
   ```bash
   sudo nixos-rebuild switch --flake .#wsl
   ```

6. **Log into the WSL distro** with `wsl -d NixOS` and verify the shell/apps. WSLg provides the default Wayland session; MangoWC is installed but not started at login.

7. **(Optional) Launch MangoWC in a window**
   ```bash
   ./scripts/start-mango-wsl.sh
   ```
   This connects Mango to WSLg's Wayland socket and opens it as a single nested window using the wlroots Wayland backend with Mesa software GLES2. Close that window or press `Ctrl+C` in the terminal to stop Mango.

   > **WSL limitation:** stock WSL kernels lack `/dev/udmabuf` and WSLg exposes no DRM render node/dma-buf. Mango hardcodes scenefx's GLES2 renderer, so the software path may still fail at allocator creation. See `docs/troubleshooting.md` and `docs/upstream-research.md`; if it fails, Mango cannot be nested on this kernel without a custom kernel/render node.

   Nested Mango windows have no titlebar under WSLg. Use Windows `Alt+Tab`, `Win+Arrow` snapping, or `Alt+Space` → Move to position/resize the window. Inside Mango, `SUPER+Return` opens Ghostty and `SUPER+Space` calls Quickshell's launcher.

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
