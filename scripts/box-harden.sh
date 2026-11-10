#!/usr/bin/env bash
#
# box-harden.sh — SSH-key-only hardening for any ssh-config host.
#
# Runs LOCALLY (uses the host's existing ssh config entry + agent key) and
# drives the box over that already-trusted connection:
#   1. Resolves the relative ssh key ssh would use for <host>
#   2. BLOCKS the entire script unless that key is present in the box's
#      ~/.ssh/authorized_keys (never locks you out of an unprovisioned box)
#   3. Adds the same key to root (emergency hatch)
#   4. Disables password/kbd-interactive SSH logins (keys only)
#
# The account password itself is kept solely for interactive sudo/polkit
# prompts — it is never used for SSH.
#
# Usage:  ./scripts/box-harden.sh <ssh-host>
#
set -euo pipefail

HOST="${1:-}"
SSHD_CONF_NAME="00-keys-only.conf"

usage() { echo "usage: $0 <ssh-host>   (host alias from ~/.ssh/config)" >&2; exit 2; }
[[ -n "$HOST" ]] || usage

log() { printf '\033[1;36m[harden]\033[0m %s\n' "$*"; }
die() { printf '\033[1;31m[harden] BLOCK:\033[0m %s\n' "$*" >&2; exit 1; }

REMOTE_USER="$(ssh -o BatchMode=yes "$HOST" 'whoami')" \
  || die "cannot connect to '$HOST' via key auth — check ssh config."
log "target: $HOST (user: $REMOTE_USER)"

# ---------------------------------------------------------------- resolve key
log "resolving ssh key material from ssh config entry '$HOST'"
GA="$(ssh -G "$HOST" 2>/dev/null)" || die "ssh -G $HOST failed — is '$HOST' in ~/.ssh/config?"
AGENT_SOCK="$(awk '$1 == "identityagent" {print $2}' <<<"$GA")"

cands=()
if [[ -n "${AGENT_SOCK:-}" && -S "$AGENT_SOCK" ]]; then
  while IFS= read -r k; do
    [[ -n "$k" ]] && cands+=("$k")
  done < <(SSH_AUTH_SOCK="$AGENT_SOCK" ssh-add -L 2>/dev/null || true)
fi
while IFS= read -r f; do
  [[ -n "$f" && -f "$f" ]] || continue
  if k="$(ssh-keygen -y -f "$f" 2>/dev/null)" && [[ -n "$k" ]]; then
    cands+=("$k")
  fi
done < <(awk '$1 == "identityfile" {print $2}' <<<"$GA")

# dedupe by key blob (field 2)
mapfile -t cands < <(printf '%s\n' "${cands[@]:-}" | awk 'NF && !seen[$2]++')
[[ ${#cands[@]} -gt 0 ]] \
  || die "no ssh key available for '$HOST' via ssh config/agent (unlock your agent, then retry). Nothing was changed."

log "candidate key(s): ${#cands[@]} ($(awk '{print $1}' <<<"${cands[0]}"), …)"

# ------------------------------------------------- GATE: key must be trusted
REMOTE_KEYS="$(ssh -o BatchMode=yes "$HOST" 'cat ~/.ssh/authorized_keys 2>/dev/null || true')" \
  || die "cannot read authorized_keys over the existing key-authenticated session"
present=()
for k in "${cands[@]}"; do
  blob="$(awk '{print $2}' <<<"$k")"
  if grep -Fq -- "$blob" <<<"$REMOTE_KEYS"; then
    present+=("$k")
  fi
done
[[ ${#present[@]} -gt 0 ]] \
  || die "relative ssh key is NOT present in $HOST:~/.ssh/authorized_keys — blocking before any change. Run: ssh-copy-id $HOST (then retry)."
log "gate passed: relative key is trusted on the box ✔"

# verify the live session is really key-authenticated (no password involved)
ssh -o BatchMode=yes -o PreferredAuthentications=publickey "$HOST" true \
  || die "key-only authentication to $HOST failed — aborting."
log "key-only login verified ✔"

# ------------------------------------------------------------- root hardening
log "applying root-side changes (sudo may prompt once)"
PAYLOAD="$(mktemp)"
trap 'rm -f "$PAYLOAD"' EXIT
cat >"$PAYLOAD" <<'EOS'
set -euo pipefail
: "${U:?remote user not set}"

# video group, if present (webcam/media device access)
getent group video >/dev/null && usermod -aG video "$U" 2>/dev/null || true

# root emergency hatch: trust the user's keys, deduped
install -d -m 700 /root/.ssh
touch /root/.ssh/authorized_keys
cat /home/"$U"/.ssh/authorized_keys /root/.ssh/authorized_keys 2>/dev/null \
  | sort -u > /root/.ssh/authorized_keys.new
mv /root/.ssh/authorized_keys.new /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

# sshd: keys only (00- prefix so it wins over cloud-init drop-ins)
cat > /etc/ssh/sshd_config.d/00-keys-only.conf <<'CONF'
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
CONF

sshd -t
systemctl restart ssh
echo "ROOT-PAYLOAD-OK"
EOS
ssh -t "$HOST" "sudo U=$REMOTE_USER bash -s" <"$PAYLOAD" | grep -q ROOT-PAYLOAD-OK \
  || die "root payload did not complete — sshd unchanged (safe). Check the output above."

# ------------------------------------------------------------- verify
sleep 2
ssh -o BatchMode=yes -o PreferredAuthentications=publickey "$HOST" true \
  || die "POST-CHECK FAILED: key login broken after sshd restart — investigate via console!"
ssh -o BatchMode=yes -o PreferredAuthentications=publickey "root@$HOST" true \
  || log "WARN: root key login not working yet (hatch not usable) — user login verified OK"

log "hardened: sshd is key-only (PasswordAuthentication=no)"
log "password on the account remains ONLY for interactive sudo prompts"
log "to also kill sudo passwords: run as root 'visudo -f /etc/sudoers.d/90-nopasswd' (at your own risk)"
log "=== box-harden complete"
