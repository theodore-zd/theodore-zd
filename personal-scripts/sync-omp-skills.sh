#!/usr/bin/env bash
# Sync the global omp skills folder (~/.omp/agent/skills) into this repo's
# agent-skills/ dir as per-skill symlinks, then commit the link set.
#
# Why symlinks: editing a skill in ~/.omp/agent/skills is instantly reflected
# here (git stores only the link). NOTE: a clone of this repo does NOT carry
# skill content — the links point at ~/.omp/agent/skills on this machine.
#
# Safety rules:
#  - A real dir in agent-skills/ is replaced ONLY when byte-identical to the
#    matching omp skill; anything different aborts (never destroy content).
#  - Real dirs with no matching omp skill (Atluo-repo mirrors, archived) are
#    left untouched and reported.
#  - Only agent-skills/ is staged; unrelated repo changes are never committed.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OMP_SKILLS="$HOME/.omp/agent/skills"
BACKUP_SKILLS="$REPO_DIR/agent-skills"
REL_TARGET_PREFIX="../../../.omp/agent/skills"

echo "==> Syncing $OMP_SKILLS -> $BACKUP_SKILLS"

[ -d "$OMP_SKILLS" ] || { echo "!! $OMP_SKILLS not found; nothing to sync" >&2; exit 1; }
mkdir -p "$BACKUP_SKILLS"

for skill_dir in "$OMP_SKILLS"/*/; do
    name="$(basename "$skill_dir")"
    link="$BACKUP_SKILLS/$name"
    target="$REL_TARGET_PREFIX/$name"

    if [ -L "$link" ]; then
        current="$(readlink "$link")"
        if [ "$current" = "$target" ]; then
            echo "  = $name (already linked)"
        else
            echo "  ~ $name relink: $current -> $target"
            ln -sfn "$target" "$link"
        fi
    elif [ -e "$link" ]; then
        # Real dir/copy exists. Replace only when byte-identical to the omp skill.
        if diff -rq "$skill_dir" "$link" >/dev/null 2>&1; then
            echo "  ~ $name (identical copy -> symlink)"
            rm -rf "$link"
            ln -s "$target" "$link"
        else
            echo "!! $name exists in $BACKUP_SKILLS and DIFFERS from $OMP_SKILLS/$name" >&2
            echo "   Refusing to replace; resolve by hand and re-run." >&2
            exit 1
        fi
    else
        echo "  + $name"
        ln -s "$target" "$link"
    fi
done

# Report backup entries with no matching omp skill (never touched by this script).
for entry in "$BACKUP_SKILLS"/*; do
    [ -e "$entry" ] || continue
    name="$(basename "$entry")"
    if [ -L "$entry" ]; then
        [ -d "$OMP_SKILLS/$name" ] || echo "  ! $name: symlink with no omp skill (stale? left untouched)"
    else
        [ -d "$OMP_SKILLS/$name" ] || echo "  ! $name: real dir, no matching omp skill (left untouched)"
    fi
done

git -C "$REPO_DIR" add agent-skills
if git -C "$REPO_DIR" diff --cached --quiet; then
    echo "==> No changes to commit"
else
    git -C "$REPO_DIR" commit -m "sync agent-skills symlinks with ~/.omp/agent/skills"
    echo "==> Committed"
fi
