#!/usr/bin/env bash
# Shared WSLg setup for nested wlroots compositors.
# Source this from a launcher script; do not execute directly.

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

# Nested wlroots compositor: use WSLg's Wayland display and no direct
# libinput/cursor/render-node access.
export WLR_BACKENDS=wayland
export WLR_LIBINPUT_NO_DEVICES=1
export WLR_WL_OUTPUTS=1
export WLR_NO_HARDWARE_CURSORS=1

# An inherited DISPLAY can select the wrong backend.
unset DISPLAY
