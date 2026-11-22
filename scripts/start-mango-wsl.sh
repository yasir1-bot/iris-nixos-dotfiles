#!/usr/bin/env bash
set -euo pipefail

# Run MangoWC as a nested compositor inside the WSLg Wayland session.
# Best-effort only: stock WSL kernels lack /dev/udmabuf (see docs).

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/wslg-wayland.sh
source "$script_dir/lib/wslg-wayland.sh"

export XDG_CURRENT_DESKTOP=Mango

# Mango uses scenefx's GLES2 renderer, which ignores WLR_RENDERER=pixman and
# insists on a DRM FD. Force Mesa's software GLES2 path instead.
export WLR_RENDERER_FORCE_SOFTWARE=1
export WLR_RENDERER_ALLOW_SOFTWARE=1

if [[ ! -e /dev/udmabuf ]]; then
  echo "warning: /dev/udmabuf is missing; stock WSL kernels often fail the wlroots allocator step" >&2
fi

if ! command -v mango >/dev/null 2>&1; then
  echo "error: mango is not in PATH; rebuild with: sudo nixos-rebuild switch --flake .#wsl" >&2
  exit 127
fi

exec mango "$@"
