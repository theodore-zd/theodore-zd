#!/usr/bin/env bash
# Sync agent skills from this repo into ~/.agents/skills.
# Links every skill in skills/ (dirs containing SKILL.md) into the
# cross-agent standard location; omp and other skills-spec CLIs pick it up.
#
# Usage: scripts/sync-skills.sh [--all]
#   default: link the 10 curated skills below
#   --all:   link every skill in skills/
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$HOME/.agents/skills"

CURATED=(
  code-flow-map
  drill-me
  feral-audit
  feral-componentization
  feral-lang
  feral-org
  feral-ux-audit
  jacob
  mockup
  visual-audit
)

if [[ "${1:-}" == "--all" ]]; then
  names=()
  for dir in "$REPO"/skills/*/; do
    [[ -f "$dir/SKILL.md" ]] && names+=("$(basename "$dir")")
  done
else
  names=("${CURATED[@]}")
fi

mkdir -p "$DEST"
for name in "${names[@]}"; do
  [[ -d "$REPO/skills/$name" ]] || { echo "skip (missing): $name"; continue; }
  ln -sfn "$REPO/skills/$name" "$DEST/$name"
  echo "linked: $name"
done

echo "done — $(omp skill list 2>/dev/null | wc -l) skills visible to omp"
