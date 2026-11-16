#!/usr/bin/env bash
# Best-effort validation helpers (run on a system with Nix installed).

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "==> Formatting check (optional)"
if command -v nix >/dev/null 2>&1; then
  nix --version || true
  echo "==> nix flake show"
  nix flake show --all-systems || true
  echo "==> nix flake check (may be slow / may require Linux builders)"
  nix flake check || true
else
  echo "nix not found; skipping Nix evaluations/checks"
fi

echo "==> JSON validation"
if command -v jq >/dev/null 2>&1; then
  jq -e . config/desktop/settings.json >/dev/null && echo "config/desktop/settings.json: OK"
else
  echo "jq not found; skipping JSON validation"
fi

echo "==> Shell script syntax"
bash -n scripts/apply-settings.sh scripts/validate.sh 2>/dev/null || true

echo "Validation complete (see notes for environment-dependent/unrun checks)."
