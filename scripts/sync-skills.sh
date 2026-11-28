#!/usr/bin/env bash
# Interactively choose an agent harness and the repo skills linked into it.
# Up/down moves, Space toggles, Enter applies the selection.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$REPO/skills"

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  cat <<'EOF'
Usage: scripts/sync-skills.sh

Choose one installed agent harness, then select the repository skills to
system-link into it. Skills already linked from this repository start checked.
Uncheck a skill and press Enter to remove its link.

Controls: Up/Down arrows move, Space checks/unchecks, Enter confirms, q quits.
EOF
  exit 0
elif (($# > 0)); then
  echo "Unknown argument: $1 (try --help)" >&2
  exit 2
fi

if [[ ! -t 0 || ! -t 1 ]]; then
  echo "This script needs an interactive terminal." >&2
  exit 2
fi

if [[ -n "${NO_COLOR:-}" || "${TERM:-}" == "dumb" ]]; then
  RESET=''
  BOLD=''
  DIM=''
  CYAN=''
  GREEN=''
  YELLOW=''
  REVERSE=''
else
  RESET=$'\033[0m'
  BOLD=$'\033[1m'
  DIM=$'\033[2m'
  CYAN=$'\033[36m'
  GREEN=$'\033[32m'
  YELLOW=$'\033[33m'
  REVERSE=$'\033[7m'
fi

shopt -s nullglob
skill_dirs=("$SKILLS_DIR"/*/)
skill_names=()
for dir in "${skill_dirs[@]}"; do
  [[ -f "$dir/SKILL.md" ]] && skill_names+=("$(basename "$dir")")
done
if ((${#skill_names[@]} == 0)); then
  echo "No skills with SKILL.md found in $SKILLS_DIR" >&2
  exit 1
fi

# Known user-level skill directories. Include them in the picker even when the
# harness has not been installed yet; creating the directory is part of linking.
HARNESS_NAMES=("Agents standard" "Codex" "Claude Code" "OpenCode / OMP" "Pi" "Goose" "Hermes")
HARNESS_DIRS=(
  "$HOME/.agents/skills"
  "$HOME/.codex/skills"
  "$HOME/.claude/skills"
  "$HOME/.omp/agent/skills"
  "$HOME/.pi/agent/skills"
  "$HOME/.config/goose/skills"
  "$HOME/.hermes/skills"
)

selected=()
linked=()
for _ in "${skill_names[@]}"; do
  selected+=(0)
  linked+=(0)
done

restore_terminal() {
  stty "$OLD_STTY" 2>/dev/null || true
  printf '\033[?25h\033[0m\n'
}
trap restore_terminal EXIT
trap 'restore_terminal; exit 130' INT TERM
OLD_STTY="$(stty -g)"
stty -echo -icanon time 0 min 1
printf '\033[?25l'

read_key() {
  local key
  IFS= read -rsn1 key || true
  if [[ "$key" == $'\033' ]]; then
    local sequence
    IFS= read -rsn2 -t 0.1 sequence || true
    case "$sequence" in
      '[A') REPLY=up ;;
      '[B') REPLY=down ;;
      *) REPLY=other ;;
    esac
  else
    case "$key" in
      ' ') REPLY=space ;;
      '') REPLY=enter ;;
      q|Q) REPLY=quit ;;
      *) REPLY=other ;;
    esac
  fi
}

draw_harnesses() {
  printf '\033[2J\033[H'
  printf '%s%sSelect a harness%s\n' "$BOLD" "$CYAN" "$RESET"
  printf '%sChoose where to manage this repository’s skill links.%s\n\n' "$DIM" "$RESET"
  for i in "${!HARNESS_NAMES[@]}"; do
    local marker='not set up' color="$DIM"
    if [[ -d "${HARNESS_DIRS[$i]}" ]]; then
      marker='detected'
      color="$GREEN"
    fi
    if ((i == cursor)); then
      printf '%s > %s%-20s%s  %s%s%s\n' "$REVERSE" "$BOLD" "${HARNESS_NAMES[$i]}" "$RESET" "$color" "$marker" "$RESET"
    else
      printf '   %-20s %s%s%s\n' "${HARNESS_NAMES[$i]}" "$color" "$marker" "$RESET"
    fi
  done
  printf '\n%sUp/Down%s move  %sEnter%s choose  %sq%s quit\n' "$BOLD" "$RESET" "$BOLD" "$RESET" "$BOLD" "$RESET"
}

cursor=0
while true; do
  draw_harnesses
  read_key
  case "$REPLY" in
    up) cursor=$(((cursor + ${#HARNESS_NAMES[@]} - 1) % ${#HARNESS_NAMES[@]})) ;;
    down) cursor=$(((cursor + 1) % ${#HARNESS_NAMES[@]})) ;;
    enter) harness_index=$cursor; break ;;
    quit) exit 0 ;;
  esac
done

DEST="${HARNESS_DIRS[$harness_index]}"

same_link_target() {
  local entry="$1" source="$2" resolved
  [[ -L "$entry" ]] || return 1
  resolved="$(readlink -f -- "$entry" 2>/dev/null || true)"
  [[ "$resolved" == "$source" ]]
}

for i in "${!skill_names[@]}"; do
  source="$SKILLS_DIR/${skill_names[$i]}"
  entry="$DEST/${skill_names[$i]}"
  if same_link_target "$entry" "$source"; then
    linked[$i]=1
    selected[$i]=1
  fi
done

draw_skills() {
  printf '\033[2J\033[H'
  printf '%s%s%s  %s%s\n' "$BOLD" "$CYAN" "${HARNESS_NAMES[$harness_index]}" "$RESET" "$DEST"
  printf '%sSelect skills to link. Existing links from this repo start checked.%s\n\n' "$DIM" "$RESET"
  for i in "${!skill_names[@]}"; do
    local box='[ ]' state='' box_color="$DIM" state_color="$DIM"
    if ((selected[$i])); then
      box='[✓]'
      box_color="$GREEN"
    fi
    if [[ -e "$DEST/${skill_names[$i]}" || -L "$DEST/${skill_names[$i]}" ]]; then
      if ((linked[$i])); then
        state=' linked'
        state_color="$GREEN"
      else
        state=' conflict: existing path belongs elsewhere'
        state_color="$YELLOW"
      fi
    fi
    if ((i == cursor)); then
      printf '%s > %s%-4s%s %-34s%s%s%s\n' "$REVERSE" "$box_color" "$box" "$RESET" "${skill_names[$i]}" "$state_color" "$state" "$RESET"
    else
      printf '   %s%-4s%s %-34s%s%s%s\n' "$box_color" "$box" "$RESET" "${skill_names[$i]}" "$state_color" "$state" "$RESET"
    fi
  done
  printf '\n%sUp/Down%s move  %sSpace%s check/uncheck  %sEnter%s apply  %sq%s cancel\n' "$BOLD" "$RESET" "$BOLD" "$RESET" "$BOLD" "$RESET" "$BOLD" "$RESET"
}

cursor=0
while true; do
  draw_skills
  read_key
  case "$REPLY" in
    up) cursor=$(((cursor + ${#skill_names[@]} - 1) % ${#skill_names[@]})) ;;
    down) cursor=$(((cursor + 1) % ${#skill_names[@]})) ;;
    space) selected[$cursor]=$((1 - selected[$cursor])) ;;
    enter) break ;;
    quit) exit 0 ;;
  esac
done

mkdir -p "$DEST"
changed=0
for i in "${!skill_names[@]}"; do
  name="${skill_names[$i]}"
  source="$SKILLS_DIR/$name"
  entry="$DEST/$name"
  if ((selected[$i])); then
    if ((linked[$i])); then
      continue
    fi
    if [[ -e "$entry" || -L "$entry" ]]; then
      printf 'skipped (path already exists): %s\n' "$name"
      continue
    fi
    ln -s -- "$source" "$entry"
    printf 'linked: %s\n' "$name"
    ((changed += 1))
  elif ((linked[$i])); then
    rm -- "$entry"
    printf 'unlinked: %s\n' "$name"
    ((changed += 1))
  fi
done

if ((changed == 0)); then
  printf 'No link changes for %s.\n' "${HARNESS_NAMES[$harness_index]}"
else
  printf 'Updated %d skill link(s) for %s.\n' "$changed" "${HARNESS_NAMES[$harness_index]}"
fi
