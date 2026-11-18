#!/usr/bin/env bash
set -euo pipefail

# Run MangoWC as a nested compositor inside the WSLg Wayland session.
# The result is one normal Windows/Wayland window containing MangoWC.

wslg_socket="/mnt/wslg/runtime-dir/wayland-0"
runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
socket_link="$runtime_dir/wayland-0"

if [[ ! -S "$wslg_socket" ]]; then
  echo "error: WSLg Wayland socket not found at $wslg_socket" >&2
  echo "Run this inside WSL 2 with WSLg enabled." >&2
  exit 1
fi

if [[ ! -d "$runtime_dir" ]]; then
  install -d -m 0700 "$runtime_dir"
fi
export XDG_RUNTIME_DIR="$runtime_dir"

# WSLg publishes its socket under /mnt/wslg; expose it where wlroots expects it.
if [[ -S "$socket_link" ]]; then
  : # already a usable socket (for example, XDG_RUNTIME_DIR is the WSLg dir)
elif [[ -L "$socket_link" ]]; then
  ln -sfn "$wslg_socket" "$socket_link"
elif [[ -e "$socket_link" ]]; then
  echo "error: $socket_link exists and is not a Wayland socket" >&2
  exit 1
else
  ln -s "$wslg_socket" "$socket_link"
fi

export WAYLAND_DISPLAY=wayland-0
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=Mango

# Nested wlroots compositor: use WSLg's Wayland display and no direct
# libinput/cursor/render-node access.
export WLR_BACKENDS=wayland
export WLR_LIBINPUT_NO_DEVICES=1
export WLR_WL_OUTPUTS=1
export WLR_NO_HARDWARE_CURSORS=1

# Mango uses scenefx's GLES2 renderer, which ignores WLR_RENDERER=pixman and
# insists on a DRM FD. Force Mesa's software GLES2 path instead.
export WLR_RENDERER_FORCE_SOFTWARE=1
export WLR_RENDERER_ALLOW_SOFTWARE=1

if [[ ! -e /dev/udmabuf ]]; then
  echo "warning: /dev/udmabuf is missing; stock WSL kernels often fail the wlroots allocator step" >&2
fi

# Force pure Wayland; an inherited DISPLAY can select the wrong backend.
unset DISPLAY

if ! command -v mango >/dev/null 2>&1; then
  echo "error: mango is not in PATH; rebuild with: sudo nixos-rebuild switch --flake .#wsl" >&2
  exit 127
fi

exec mango "$@"
