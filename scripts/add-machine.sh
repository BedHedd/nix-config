#!/usr/bin/env bash
# scripts/add-machine.sh
# ------------------------------------------------------------
set -euo pipefail

echo "=== New-machine bootstrap ==="
read -rp "Machine (host) name       : " MACHINE
read -rp "Primary username          : " USERNAME
read -rp "Directory with current configuration.nix [/etc/nixos]: " ETC_DIR
ETC_DIR=${ETC_DIR:-/etc/nixos}

REPO_ROOT="$(git -C "$(pwd)" rev-parse --show-toplevel 2>/dev/null || pwd)"
TEMPLATE_DIR="$REPO_ROOT/modules/machine-template"
DEST_DIR="$REPO_ROOT/machines/$MACHINE"

[[ -d $TEMPLATE_DIR ]] || { echo "❌ $TEMPLATE_DIR not found"; exit 1; }
[[ ! -e $DEST_DIR ]]   || { echo "❌ $DEST_DIR already exists"; exit 1; }

echo "→ Copying template → $DEST_DIR"
mkdir -p "$DEST_DIR"
cp -r "$TEMPLATE_DIR"/. "$DEST_DIR/"

# ------------------------------------------------------------
# 1) Substitute placeholders in the new machine files
echo "→ Rewriting placeholders in configuration.nix, home.nix, users.nix"
sed -i \
  -e "s/generic-machine/${MACHINE}/g" \
  -e "s/generic-user/${USERNAME}/g" \
  "$DEST_DIR/configuration.nix" \
  "$DEST_DIR/home.nix" \
  "$DEST_DIR/users.nix"

# ------------------------------------------------------------
# 2) Copy live hardware config (if present)
if [[ -f "$ETC_DIR/hardware-configuration.nix" ]]; then
  echo "→ Copying hardware-configuration.nix"
  cp "$ETC_DIR/hardware-configuration.nix" "$DEST_DIR/"
fi
if [[ -f "$ETC_DIR/configuration.nix" ]]; then
  echo "→ Saving current /etc/nixos/configuration.nix (as reference)"
  cp "$ETC_DIR/configuration.nix" "$DEST_DIR/original-configuration.nix"
fi

# ------------------------------------------------------------
# 3) Create per-user file from generic-user.nix in one go
USER_FILE="$REPO_ROOT/users/${USERNAME}.nix"
TEMPLATE_USER="$REPO_ROOT/users/generic-user.nix"

if [[ ! -f $TEMPLATE_USER ]]; then
  echo "❌ Template user file not found: $TEMPLATE_USER"
  exit 1
fi

if [[ -f $USER_FILE ]]; then
  echo "→ users/${USERNAME}.nix already exists – leaving it unchanged"
else
  echo "→ Generating users/${USERNAME}.nix from template"
  sed "s/generic-user/${USERNAME}/g" "$TEMPLATE_USER" > "$USER_FILE"
fi

# ------------------------------------------------------------
# 4) Ensure the new user file is imported by this machine’s users.nix
if ! grep -q "${USERNAME}.nix" "$DEST_DIR/users.nix"; then
  echo "→ Adding import to machines/${MACHINE}/users.nix"
  sed -i '/^  imports = \[/ a\    ../../users/'"${USERNAME}"'.nix' \
    "$DEST_DIR/users.nix"
fi

echo -e "\n✅  All set!"
echo "Now you can run:"
echo "  sudo nixos-rebuild switch --flake \"$REPO_ROOT#$MACHINE\""
