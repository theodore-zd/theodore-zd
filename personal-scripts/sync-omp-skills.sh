#!/usr/bin/env bash
# Sync ~/.omp/agent/skills (live omp folder) with this repo's agent-skills/ dir.
#
# The repo's agent-skills/ is the COMMITTED STORE: real skill content lives
# here in git (clone-portable backup). Each live omp skill dir is a symlink
# into the store, so editing a skill through ~/.omp/agent/skills/<name> writes
# the repo's file directly; commit captures it.
#
# Safety rules:
#  - agent-skills/ entries with NO matching omp skill (Atluo-repo mirrors,
#    archived skills) are never touched.
#  - A real dir in the live omp folder whose name already exists in the store
#    with DIFFERENT content aborts (never destroy either copy).
#  - Only agent-skills/ is staged; unrelated repo changes are never committed.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LIVE_DIR="$HOME/.omp/agent/skills"
STORE_DIR="$REPO_DIR/agent-skills"

echo "==> Syncing $LIVE_DIR <-> $STORE_DIR (store is authoritative)"

[ -d "$LIVE_DIR" ] || { echo "!! $LIVE_DIR not found; nothing to sync" >&2; exit 1; }
[ -d "$STORE_DIR" ] || mkdir -p "$STORE_DIR"

changed=0

# 1. Live side: adopt real dirs into the store, verify links point at the store.
for entry in "$LIVE_DIR"/*; do
    [ -e "$entry" ] || continue
    name="$(basename "$entry")"
    store_path="$STORE_DIR/$name"

    if [ -L "$entry" ]; then
        current="$(readlink -f "$entry")"
        want="$(readlink -f "$store_path" 2>/dev/null || echo "$store_path")"
        if [ "$current" != "$want" ]; then
            if [ -e "$store_path" ] || [ -L "$store_path" ]; then
                echo "  ~ $name relink: $(readlink "$entry") -> $(realpath --relative-to "$LIVE_DIR" "$store_path")"
                ln -sfn "$(realpath --relative-to "$LIVE_DIR" "$store_path")" "$entry"
                changed=1
            else
                echo "  ! $name: live link has no store entry (stale; left as-is)"
            fi
        fi
        # else: already linked correctly; nothing to do
    elif [ -d "$entry" ]; then
        # Real dir in the live omp folder. Is it already in the store?
        if [ -d "$store_path" ] || [ -L "$store_path" ]; then
            # Conflict check: store copy must match, or we refuse to clobber.
            if diff -rq "$entry" "$store_path" >/dev/null 2>&1; then
                echo "  ~ $name (identical copy in omp -> symlink into store)"
                rm -rf "$entry"
                ln -s "$(realpath --relative-to "$LIVE_DIR" "$store_path")" "$entry"
                changed=1
            else
                echo "!! $name: real dir in $LIVE_DIR DIFFERS from store copy $STORE_DIR/$name" >&2
                echo "   Two divergent sources; resolve by hand and re-run." >&2
                exit 1
            fi
        else
            # New skill authored in the live omp folder: adopt into the store.
            echo "  + $name (new in omp -> store + symlink)"
            mv "$entry" "$store_path"
            ln -s "$(realpath --relative-to "$LIVE_DIR" "$store_path")" "$entry"
            changed=1
        fi
    fi
done

# 2. Store side: report committed entries the live folder no longer links.
for entry in "$STORE_DIR"/*; do
    [ -e "$entry" ] || continue
    name="$(basename "$entry")"
    if [ ! -e "$LIVE_DIR/$name" ] && [ ! -L "$LIVE_DIR/$name" ]; then
        echo "  ! $name: in store, no live omp entry (backup-only or unlinked; left untouched)"
    fi
done

# 3. Commit store changes.
git -C "$REPO_DIR" add agent-skills
if git -C "$REPO_DIR" diff --cached --quiet; then
    echo "==> No changes to commit"
else
    git -C "$REPO_DIR" commit -m "sync agent-skills store with ~/.omp/agent/skills"
    echo "==> Committed"
fi
