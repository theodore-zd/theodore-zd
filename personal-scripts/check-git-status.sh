#!/bin/bash
# Check git status in all subdirectories for unpushed changes

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

count=0
needs_push=0

echo -e "${BOLD}📂 Scanning repositories...${NC}\n"

for dir in */; do
  [ -d "$dir/.git" ] || continue
  
  count=$((count + 1))
  cd "$dir"
  
  branch=$(git branch --show-current 2>/dev/null)
  
  if [ $? -ne 0 ]; then
    echo -e "  ${BLUE}${BOLD}${dir%/}${NC} — not a git repo"
    cd ..
    continue
  fi
  
  git fetch origin "$branch" >/dev/null 2>&1
  
  behind=$(git rev-list --count "$branch..origin/$branch" 2>/dev/null)
  ahead=$(git rev-list --count "origin/$branch..$branch" 2>/dev/null)
  uncommitted=$(git status --porcelain 2>/dev/null)
  
  if [ "$ahead" -gt 0 ] || [ "$behind" -gt 0 ] || [ -n "$uncommitted" ]; then
    needs_push=$((needs_push + 1))
    
    if [ "$ahead" -gt 0 ]; then
      echo -e "  ${YELLOW}${BOLD}${dir%/}${NC} on ${BOLD}${branch}${NC} — ${RED}↑ $ahead to push${NC}"
    elif [ "$behind" -gt 0 ]; then
      echo -e "  ${YELLOW}${BOLD}${dir%/}${NC} on ${BOLD}${branch}${NC} — ${BLUE}↓ $behind to pull${NC}"
    else
      echo -e "  ${YELLOW}${BOLD}${dir%/}${NC} on ${BOLD}${branch}${NC} — ${GREEN}uncommitted changes${NC}"
    fi
    
    if [ -n "$uncommitted" ]; then
      while IFS= read -r line; do
        echo -e "    ${NC}${line}${NC}"
      done <<< "$uncommitted"
    fi
    echo ""
  else
    echo -e "  ${GREEN}${BOLD}${dir%/}${NC} ✓"
  fi
  
  cd ..
done

echo -e "\n${BOLD}Summary: ${count} repos scanned, ${needs_push} need attention.${NC}"
