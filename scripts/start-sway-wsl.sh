#!/usr/bin/env bash
set -euo pipefail

# Run sway as a nested compositor inside the WSLg Wayland session.
# Uses wlroots' pixman renderer + shm allocator: no DRM node or custom kernel.

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/wslg-wayland.sh
source "$script_dir/lib/wslg-wayland.sh"

export XDG_CURRENT_DESKTOP=sway
export WLR_RENDERER=pixman

config="${XDG_CONFIG_HOME:-$HOME/.config}/sway/config"
if [[ ! -f "$config" ]]; then
  echo "error: sway config not found at $config; rebuild with: sudo nixos-rebuild switch --flake .#wsl" >&2
  exit 1
fi

if ! command -v sway >/dev/null 2>&1; then
  echo "error: sway is not in PATH; rebuild with: sudo nixos-rebuild switch --flake .#wsl" >&2
  exit 127
fi

exec sway -c "$config" "$@"
