#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
NIRI_SRC="$REPO_DIR/niri-config"
NOCTALIA_SRC="$REPO_DIR/noctalia-config"
NIRI_DEST="$HOME/.config/niri"
NOCTALIA_DEST="$HOME/.config/noctalia"

echo "==> Restoring configs from $REPO_DIR"

if [ -d "$NIRI_SRC" ]; then
    echo "  -> niri configs: $NIRI_SRC -> $NIRI_DEST"
    rm -rf "$NIRI_DEST"
    cp -r "$NIRI_SRC" "$NIRI_DEST"
else
    echo "  !! niri-config not found in repo"
fi

if [ -d "$NOCTALIA_SRC" ]; then
    echo "  -> noctalia configs: $NOCTALIA_SRC -> $NOCTALIA_DEST"
    rm -rf "$NOCTALIA_DEST"
    cp -r "$NOCTALIA_SRC" "$NOCTALIA_DEST"
else
    echo "  !! noctalia-config not found in repo"
fi

echo "==> Done. Reload niri for changes to take effect."
