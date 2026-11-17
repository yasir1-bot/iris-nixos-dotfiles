#!/usr/bin/env bash
# Generate an optional WSL hardware config without filesystem entries.
# WSL owns the root filesystem, so generated fileSystems blocks for
# /mnt/wslg/distro and /tmp/.X11-unix are not wanted here.
#
# The "ERROR: not a btrfs filesystem: ..." lines are stderr noise from
# nixos-generate-config probing WSLg bind mounts with `btrfs subvol show`;
# they are harmless and are filtered by this wrapper.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT_DIR/system/hosts/wsl/hardware-configuration.nix"

TMP="$(mktemp)"
cleanup() { rm -f "$TMP"; }
trap cleanup EXIT INT TERM

# --no-filesystems omits fileSystems/swap from the generated output.
# stderr is filtered because the btrfs probe writes harmless errors for
# WSLg's non-btrfs bind mounts.
if ! nixos-generate-config --no-filesystems --show-hardware-config 2> >(
  grep -v 'ERROR: not a btrfs filesystem:' >&2
) > "$TMP"; then
  echo "nixos-generate-config failed" >&2
  exit 1
fi

mkdir -p "$(dirname "$OUT")"
mv -f "$TMP" "$OUT"
trap - EXIT INT TERM

echo "Wrote $OUT (filesystems omitted; WSL owns the root filesystem)"
echo "Review it, then rebuild with: sudo nixos-rebuild switch --flake .#wsl"
