#!/usr/bin/env bash
# Safely persist graphical settings and optionally trigger a NixOS rebuild.
# SECURITY: this script must NEVER execute arbitrary commands from UI/settings input.
# It only copies/validates a known settings file and runs a fixed, allowlisted rebuild command.

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: apply-settings.sh [--rebuild] [--flake <path>#<host>]

Options:
  --rebuild           Run nixos-rebuild switch after saving settings (requires privileges/polkit/sudo setup)
  --flake REF         Flake ref to rebuild (default: $HOME/.dotfiles#desktop)
  -h, --help          Show help

Environment:
  DOTFILES_DIR        Override dotfiles directory (default: $HOME/.dotfiles)
EOF
}

REBUILD=0
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
FLAKE_REF="$DOTFILES_DIR#desktop"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --rebuild) REBUILD=1; shift ;;
    --flake) FLAKE_REF="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 2 ;;
  esac
done

SETTINGS_SRC="${XDG_CONFIG_HOME:-$HOME/.config}/desktop/settings.json"
SETTINGS_DST="$DOTFILES_DIR/desktop/settings/settings.json"

if [[ ! -f "$SETTINGS_SRC" ]]; then
  echo "Settings file not found: $SETTINGS_SRC" >&2
  exit 1
fi

# Basic validation (extend with strict schema validation, e.g. jq checks)
if command -v jq >/dev/null 2>&1; then
  jq -e . "$SETTINGS_SRC" >/dev/null
else
  echo "Warning: jq not found; skipping JSON validation" >&2
fi

mkdir -p "$(dirname "$SETTINGS_DST")"
tmp="$(mktemp "${SETTINGS_DST}.tmp.XXXXXX")"
cp "$SETTINGS_SRC" "$tmp"
mv -f "$tmp" "$SETTINGS_DST"

echo "Saved settings to $SETTINGS_DST"

if [[ "$REBUILD" -eq 1 ]]; then
  # Fixed allowlisted command only. Configure sudoers/polkit separately for passwordless or prompted escalation.
  echo "Running: sudo nixos-rebuild switch --flake $FLAKE_REF"
  sudo nixos-rebuild switch --flake "$FLAKE_REF"
fi
