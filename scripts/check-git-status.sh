#!/bin/bash
# Check git status in all subdirectories for unpushed changes.
# Scans here and one level deep (e.g. __back_burner__/ holds nested repos).
# Reports false positives: repos with no remote, branches missing from origin,
# and detached HEADs — all of which silently look "clean" in a naive check.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

count=0
needs_attention=0

echo -e "${BOLD}📂 Scanning repositories...${NC}\n"

# maxdepth 3 covers ./__back_burner__/ai-exploration/.git
repos=$(find . -maxdepth 3 \( -name ".git" -type d \) 2>/dev/null | sed 's|/\.git$||' | sort)

for repo in $repos; do
  count=$((count + 1))

  branch=$(git -C "$repo" branch --show-current 2>/dev/null)

  if [ -z "$branch" ]; then
    echo -e "  ${BLUE}${BOLD}${repo} ${NC}— ${RED}detached HEAD${NC}"
    needs_attention=$((needs_attention + 1))
    continue
  fi

  origin_url=$(git -C "$repo" remote get-url origin 2>/dev/null)
  uncommitted=$(git -C "$repo" status --porcelain 2>/dev/null)

  if [ -z "$origin_url" ]; then
    echo -e "  ${RED}${BOLD}${repo} ${NC}on ${BOLD}${branch}${NC} — ${RED}no remote configured${NC}"
    needs_attention=$((needs_attention + 1))
    continue
  fi

  git -C "$repo" fetch origin "$branch" >/dev/null 2>&1

  if git -C "$repo" rev-parse --verify --quiet "@{upstream}" >/dev/null 2>&1; then
    ahead=$(git -C "$repo" rev-list --count "@{upstream}..HEAD" 2>/dev/null)
    behind=$(git -C "$repo" rev-list --count "HEAD..@{upstream}" 2>/dev/null)
    : "${ahead:=0}"
    : "${behind:=0}"
    upstream_ok=1
  else
    # Upstream unset or origin/$branch doesn't exist yet.
    upstream_ok=0
    ahead=0
    behind=0
  fi

  if [ "$ahead" -gt 0 ] || [ "$behind" -gt 0 ] || [ -n "$uncommitted" ] || [ "$upstream_ok" -eq 0 ]; then
    needs_attention=$((needs_attention + 1))

    if [ "$ahead" -gt 0 ]; then
      echo -e "  ${YELLOW}${BOLD}${repo} ${NC}on ${BOLD}${branch}${NC} — ${RED}↑ $ahead to push${NC}"
    elif [ "$behind" -gt 0 ]; then
      echo -e "  ${YELLOW}${BOLD}${repo} ${NC}on ${BOLD}${branch}${NC} — ${BLUE}↓ $behind to pull${NC}"
    elif [ "$upstream_ok" -eq 0 ]; then
      echo -e "  ${YELLOW}${BOLD}${repo} ${NC}on ${BOLD}${branch}${NC} — ${RED}branch has no upstream${NC}"
    else
      echo -e "  ${YELLOW}${BOLD}${repo} ${NC}on ${BOLD}${branch}${NC} — ${GREEN}uncommitted changes${NC}"
    fi

    if [ -n "$uncommitted" ]; then
      while IFS= read -r line; do
        echo -e "    ${NC}${line}${NC}"
      done <<< "$uncommitted"
    fi
    echo ""
  else
    echo -e "  ${GREEN}${BOLD}${repo} ${NC}✓"
  fi
done

echo -e "\n${BOLD}Summary: ${count} repos scanned, ${needs_attention} need attention.${NC}"
