#!/usr/bin/env bash
#
# box-setup.sh — generic Debian/Ubuntu box bootstrap (run as root ON the box).
#
# Updates the system, installs docker (boot-enabled), lazydocker, zsh, git;
# sets the default shell + timezone. Idempotent — safe to re-run anytime.
#
# Usage (from any machine with ssh access):
#   ssh -t <host> "sudo bash -s" < scripts/box-setup.sh
# Override defaults:
#   ssh -t <host> "sudo TARGET_USER=<user> TIMEZONE=<tz> bash -s" < scripts/box-setup.sh
#
# Defaults: TARGET_USER = the invoking user (via SUDO_USER), TIMEZONE = UTC
#
set -euo pipefail

if [[ $(id -u) -ne 0 ]]; then
  echo "ERROR: must run as root. Try: ssh -t <host> 'sudo bash -s' < $0" >&2
  exit 1
fi
if ! command -v apt-get >/dev/null 2>&1; then
  echo "ERROR: this script targets Debian/Ubuntu (apt). Adapt for other distros." >&2
  exit 1
fi
export DEBIAN_FRONTEND=noninteractive

TARGET_USER="${TARGET_USER:-${SUDO_USER:-}}"
TIMEZONE="${TIMEZONE:-UTC}"

log() { printf '\033[1;32m[setup]\033[0m %s\n' "$*"; }

log "apt update + full upgrade (may take a few minutes)"
apt-get update -qq
apt-get upgrade -y -qq

log "base packages (zsh, git, build prereqs)"
apt-get install -y -qq ca-certificates curl gnupg zsh git

log "docker"
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sh
fi
systemctl enable --now docker

log "lazydocker"
if ! command -v lazydocker >/dev/null 2>&1; then
  if [[ "$(dpkg --print-architecture)" != amd64 ]]; then
    log "skipping lazydocker: unsupported arch $(dpkg --print-architecture)"
  else
    URL="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazydocker/releases/latest \
      | grep -oE '"browser_download_url": *"[^"]+"' \
      | grep -oE 'https[^"]*_Linux_x86_64\.tar\.gz' | head -n1 || true)"
    if [[ -n "${URL:-}" ]]; then
      curl -fsSL "$URL" -o /tmp/lazydocker.tar.gz
      tar -xzf /tmp/lazydocker.tar.gz -C /usr/local/bin lazydocker
      rm -f /tmp/lazydocker.tar.gz
    else
      log "WARN: could not resolve latest lazydocker release URL"
    fi
  fi
fi

if [[ -n "${TARGET_USER:-}" ]] && id "$TARGET_USER" >/dev/null 2>&1; then
  log "default shell -> zsh for $TARGET_USER"
  chsh -s "$(command -v zsh)" "$TARGET_USER"
else
  log "WARN: TARGET_USER not resolved — skipped shell change (set TARGET_USER=<user>)"
fi

log "timezone -> $TIMEZONE"
timedatectl set-timezone "$TIMEZONE"

log "summary"
echo "  docker:      $(docker --version 2>&1)"
echo "  lazydocker:  $(command -v lazydocker >/dev/null && lazydocker --version 2>/dev/null | head -n1 || echo 'not installed')"
echo "  zsh:         $(zsh --version)"
if [[ -n "${TARGET_USER:-}" ]] && id "$TARGET_USER" >/dev/null 2>&1; then
  echo "  shell:       $(getent passwd "$TARGET_USER" | cut -d: -f7)"
fi
echo "  tz:          $(timedatectl show -p Timezone --value)"
echo "=== box-setup complete"
