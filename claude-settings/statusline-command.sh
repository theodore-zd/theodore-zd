#!/bin/bash
# Source: https://github.com/theodore-zd/ClaudeCodeStatusLine
# FORK OF: https://github.com/daniel3303/ClaudeCodeStatusLine

set -f  # disable globbing
VERSION="1.2.1"

input=$(cat)

if [ -z "$input" ]; then
    printf "Claude"
    exit 0
fi

# # ─── COLORS + CONSTANTS ─────────────────────────────────────────────────────
# Muted palette — 4 hues + dim, lower contrast
blue='\033[38;2;122;162;199m'
orange='\033[38;2;209;163;113m'
green='\033[38;2;152;181;130m'
red='\033[38;2;204;120;115m'
cyan="$blue"
yellow="$orange"
white='\033[38;2;170;170;170m'
dim='\033[2m'
reset='\033[0m'
sep=" ${dim}|${reset} "

# # ─── UTILITIES ──────────────────────────────────────────────────────────────

# Format token counts (e.g., 50k / 200k)
format_tokens() {
    local num=$1
    if [ "$num" -ge 1000000 ]; then
        awk "BEGIN {v=sprintf(\"%.1f\",$num/1000000)+0; if(v==int(v)) printf \"%dm\",v; else printf \"%.1fm\",v}"
    elif [ "$num" -ge 1000 ]; then
        awk "BEGIN {printf \"%.0fk\", $num / 1000}"
    else
        printf "%d" "$num"
    fi
}

# Format number with commas (e.g., 134,938)
format_commas() {
    printf "%'d" "$1"
}

# Return color escape based on usage percentage
# Usage: usage_color <pct>
usage_color() {
    local pct=$1
    if [ "$pct" -ge 85 ]; then echo "$red"
    elif [ "$pct" -ge 60 ]; then echo "$orange"
    else echo "$green"
    fi
}

# Build progress bar (compact, filled ▓ + empty ░)
make_bar() {
    local pct=$1
    local width=${2:-10}
    [ "$pct" -gt 100 ] && pct=100
    [ "$pct" -lt 0 ] && pct=0
    local filled=$(( pct * width / 100 ))
    local empty=$(( width - filled ))
    local bar_color
    bar_color=$(usage_color "$pct")
    local b=""
    local i
    for (( i=0; i<filled; i++ )); do b+="▓"; done
    local e=""
    for (( i=0; i<empty; i++ )); do e+="░"; done
    printf "%b%s%b%b%s%b" "$bar_color" "$b" "$reset" "$dim" "$e" "$reset"
}

# Return 0 (true) if $1 > $2 using semantic versioning
version_gt() {
    local a="${1#v}" b="${2#v}"
    local IFS='.'
    read -r a1 a2 a3 <<< "$a"
    read -r b1 b2 b3 <<< "$b"
    a1=${a1:-0}; a2=${a2:-0}; a3=${a3:-0}
    b1=${b1:-0}; b2=${b2:-0}; b3=${b3:-0}
    [ "$a1" -gt "$b1" ] 2>/dev/null && return 0
    [ "$a1" -lt "$b1" ] 2>/dev/null && return 1
    [ "$a2" -gt "$b2" ] 2>/dev/null && return 0
    [ "$a2" -lt "$b2" ] 2>/dev/null && return 1
    [ "$a3" -gt "$b3" ] 2>/dev/null && return 0
    return 1
}

# Cross-platform ISO to epoch conversion
iso_to_epoch() {
    local iso_str="$1"
    local epoch
    epoch=$(date -d "${iso_str}" +%s 2>/dev/null)
    if [ -n "$epoch" ]; then
        echo "$epoch"
        return 0
    fi
    local stripped="${iso_str%%.*}"
    stripped="${stripped%%Z}"
    stripped="${stripped%%+*}"
    stripped="${stripped%%-[0-9][0-9]:[0-9][0-9]}"
    if [[ "$iso_str" == *"Z"* ]] || [[ "$iso_str" == *"+00:00"* ]] || [[ "$iso_str" == *"-00:00"* ]]; then
        epoch=$(env TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%S" "$stripped" +%s 2>/dev/null)
    else
        epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S" "$stripped" +%s 2>/dev/null)
    fi
    if [ -n "$epoch" ]; then
        echo "$epoch"
        return 0
    fi
    return 1
}

# Format ISO reset time to compact local time
format_reset_time() {
    local iso_str="$1"
    local style="$2"
    { [ -z "$iso_str" ] || [ "$iso_str" = "null" ]; } && return
    local epoch
    epoch=$(iso_to_epoch "$iso_str")
    [ -z "$epoch" ] && return
    local formatted=""
    case "$style" in
        hour)
            formatted=$(date -d "@$epoch" +"%H" 2>/dev/null) || \
            formatted=$(date -j -r "$epoch" +"%H" 2>/dev/null)
            ;;
        hour12)
            formatted=$(date -d "@$epoch" +"%I%p" 2>/dev/null) || \
            formatted=$(date -j -r "$epoch" +"%I%p" 2>/dev/null)
            formatted="${formatted#0}"
            ;;
        datetimehour)
            formatted=$(date -d "@$epoch" +"%b %-d, %H" 2>/dev/null) || \
            formatted=$(date -j -r "$epoch" +"%b %-d, %H" 2>/dev/null)
            ;;
        datetime12)
            formatted=$(date -d "@$epoch" +"%-d %I%p" 2>/dev/null) || \
            formatted=$(date -j -r "$epoch" +"%-d %I%p" 2>/dev/null)
            formatted="${formatted#0}"
            ;;
        *)
            formatted=$(date -d "@$epoch" +"%b %-d" 2>/dev/null) || \
            formatted=$(date -j -r "$epoch" +"%b %-d" 2>/dev/null)
            ;;
    esac
    [ -n "$formatted" ] && echo "$formatted"
}

# # ─── CONFIG ─────────────────────────────────────────────────────────────────

# Resolve config directory: CLAUDE_CONFIG_DIR (set by alias) or default ~/.claude
claude_config_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

# Cross-platform OAuth token resolution
# Tries credential sources in order: env var → macOS Keychain → Linux creds file → GNOME Keyring
get_oauth_token() {
    local token=""

    # 1. Explicit env var override
    if [ -n "$CLAUDE_CODE_OAUTH_TOKEN" ]; then
        echo "$CLAUDE_CODE_OAUTH_TOKEN"
        return 0
    fi

    # 2. macOS Keychain (Claude Code appends a SHA256 hash of CLAUDE_CONFIG_DIR to the service name)
    if command -v security >/dev/null 2>&1; then
        local keychain_svc="Claude Code-credentials"
        if [ -n "$CLAUDE_CONFIG_DIR" ]; then
            local dir_hash
            dir_hash=$(echo -n "$CLAUDE_CONFIG_DIR" | shasum -a 256 | cut -c1-8)
            keychain_svc="Claude Code-credentials-${dir_hash}"
        fi
        local blob
        blob=$(security find-generic-password -s "$keychain_svc" -w 2>/dev/null)
        if [ -n "$blob" ]; then
            token=$(echo "$blob" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
            if [ -n "$token" ] && [ "$token" != "null" ]; then
                echo "$token"
                return 0
            fi
        fi
    fi

    # 3. Linux credentials file
    local creds_file="${claude_config_dir}/.credentials.json"
    if [ -f "$creds_file" ]; then
        token=$(jq -r '.claudeAiOauth.accessToken // empty' "$creds_file" 2>/dev/null)
        if [ -n "$token" ] && [ "$token" != "null" ]; then
            echo "$token"
            return 0
        fi
    fi

    # 4. GNOME Keyring via secret-tool
    if command -v secret-tool >/dev/null 2>&1; then
        local blob
        blob=$(timeout 2 secret-tool lookup service "Claude Code-credentials" 2>/dev/null)
        if [ -n "$blob" ]; then
            token=$(echo "$blob" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
            if [ -n "$token" ] && [ "$token" != "null" ]; then
                echo "$token"
                return 0
            fi
        fi
    fi

    echo ""
}

# # ─── INPUT EXTRACTION ───────────────────────────────────────────────────────

# Extract data from JSON
model_name=$(echo "$input" | jq -r '.model.display_name // "Claude"')
model_name=$(echo "$model_name" | sed 's/ *(\([0-9.]*[kKmM]*\) context)/ \1/')  # "(1M context)" → "1M"

# Context window
size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
[ "$size" -eq 0 ] 2>/dev/null && size=200000

# Token usage
input_tokens=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
cache_create=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
current=$(( input_tokens + cache_create + cache_read ))

used_tokens=$(format_tokens $current)
total_tokens=$(format_tokens $size)

if [ "$size" -gt 0 ]; then
    pct_used=$(( current * 100 / size ))
else
    pct_used=0
fi
pct_remain=$(( 100 - pct_used ))

used_comma=$(format_commas $current)
remain_comma=$(format_commas $(( size - current )))

# Check reasoning effort
settings_path="$claude_config_dir/settings.json"
effort_level="medium"
if [ -n "$CLAUDE_CODE_EFFORT_LEVEL" ]; then
    effort_level="$CLAUDE_CODE_EFFORT_LEVEL"
elif [ -f "$settings_path" ]; then
    effort_val=$(jq -r '.effortLevel // empty' "$settings_path" 2>/dev/null)
    [ -n "$effort_val" ] && effort_level="$effort_val"
fi

# Extract session metrics for line 3
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
api_ms=$(echo "$input" | jq -r '.cost.total_api_duration_ms // 0')

# Build git info line (line 3)
git_line=""
cwd=$(echo "$input" | jq -r '.cwd // empty')
if [ -n "$cwd" ]; then
    display_dir="${cwd##*/}"
    git_branch=$(git -C "${cwd}" rev-parse --abbrev-ref HEAD 2>/dev/null)
    git_line="${cyan}${display_dir}${reset}"
    if [ -n "$git_branch" ]; then
        git_line+="${dim}@${reset}${green}${git_branch}${reset}"
        git_stat=$(git -C "${cwd}" diff HEAD --numstat 2>/dev/null | awk '{a+=$1; d+=$2} END {if (a+d>0) printf "+%d -%d", a, d}')
        [ -n "$git_stat" ] && git_line+=" ${dim}(${reset}${green}${git_stat%% *}${reset} ${red}${git_stat##* }${reset}${dim})${reset}"
    fi

    # Add session metrics (lines changed + API time)
    git_line+=" ${white}Sesh:${reset}"
    if [ "$lines_added" != "0" ] || [ "$lines_removed" != "0" ]; then
        git_line+=" ${green}+${lines_added}${reset} ${red}-${lines_removed}${reset}"
    fi
fi

# # ─── LINE 1: USAGE LIMITS ───────────────────────────────────────────────────

# Try to use rate_limits data from Claude Code JSON first (most reliable, no OAuth needed)
builtin_five_hour_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
builtin_five_hour_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
builtin_seven_day_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
builtin_seven_day_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

use_builtin=false
if [ -n "$builtin_five_hour_pct" ] || [ -n "$builtin_seven_day_pct" ]; then
    use_builtin=true
fi

# Cache setup — shared across all Claude Code instances to avoid rate limits
claude_config_dir_hash=$(echo -n "$claude_config_dir" | shasum -a 256 2>/dev/null || echo -n "$claude_config_dir" | sha256sum 2>/dev/null)
claude_config_dir_hash=$(echo "$claude_config_dir_hash" | cut -c1-8)
cache_file="/tmp/claude/statusline-usage-cache-${claude_config_dir_hash}.json"
cache_max_age=60  # seconds between API calls
mkdir -p /tmp/claude

needs_refresh=true
usage_data=""

# Always load cache — used as primary source for API path, and as fallback when builtin reports zero
if [ -f "$cache_file" ] && [ -s "$cache_file" ]; then
    cache_mtime=$(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null)
    now=$(date +%s)
    cache_age=$(( now - cache_mtime ))
    if [ "$cache_age" -lt "$cache_max_age" ]; then
        needs_refresh=false
    fi
    usage_data=$(cat "$cache_file" 2>/dev/null)
fi

# When builtin values are all zero AND reset timestamps are missing, it likely indicates
# an API failure on Claude's side — fall through to cached data instead of displaying
# misleading 0%. Genuine zero responses (after a billing reset) still include valid
# resets_at timestamps, so we trust those.
effective_builtin=false
if $use_builtin; then
    # Trust builtin if any percentage is non-zero
    if { [ -n "$builtin_five_hour_pct" ] && [ "$(printf '%.0f' "$builtin_five_hour_pct" 2>/dev/null)" != "0" ]; } || \
       { [ -n "$builtin_seven_day_pct" ] && [ "$(printf '%.0f' "$builtin_seven_day_pct" 2>/dev/null)" != "0" ]; }; then
        effective_builtin=true
    fi
    # Also trust if reset timestamps are present — genuine zero responses include valid reset times
    if ! $effective_builtin; then
        if { [ -n "$builtin_five_hour_reset" ] && [ "$builtin_five_hour_reset" != "null" ] && [ "$builtin_five_hour_reset" != "0" ]; } || \
           { [ -n "$builtin_seven_day_reset" ] && [ "$builtin_seven_day_reset" != "null" ] && [ "$builtin_seven_day_reset" != "0" ]; }; then
            effective_builtin=true
        fi
    fi
fi

# Fetch fresh data if cache is stale (shared across all Claude Code instances to avoid rate limits)
if ! $effective_builtin; then
    if $needs_refresh; then
        touch "$cache_file"  # stampede lock: prevent parallel panes from fetching simultaneously
        token=$(get_oauth_token)
        if [ -n "$token" ] && [ "$token" != "null" ]; then
            response=$(curl -s --max-time 10 \
                -H "Accept: application/json" \
                -H "Content-Type: application/json" \
                -H "Authorization: Bearer $token" \
                -H "anthropic-beta: oauth-2025-04-20" \
                -H "User-Agent: claude-code/2.1.34" \
                "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)
            # Only cache valid usage responses (not error/rate-limit JSON)
            if [ -n "$response" ] && echo "$response" | jq -e '.five_hour' >/dev/null 2>&1; then
                usage_data="$response"
                echo "$response" > "$cache_file"
            fi
        fi
    fi
fi

# Build output (line 1)
out=""
extra_segment=""

if $effective_builtin; then
    _fh_iso=""
    _sd_iso=""
    if [ -n "$builtin_five_hour_reset" ] && [ "$builtin_five_hour_reset" != "null" ] && [ "$builtin_five_hour_reset" != "0" ]; then
        _fh_iso=$(date -u -r "$builtin_five_hour_reset" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || \
                  date -u -d "@$builtin_five_hour_reset" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null)
    fi
    if [ -n "$builtin_seven_day_reset" ] && [ "$builtin_seven_day_reset" != "null" ] && [ "$builtin_seven_day_reset" != "0" ]; then
        _sd_iso=$(date -u -r "$builtin_seven_day_reset" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || \
                  date -u -d "@$builtin_seven_day_reset" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null)
    fi

    if [ -n "$builtin_five_hour_pct" ]; then
        fh_pct_int=$(printf '%.0f' "$builtin_five_hour_pct" 2>/dev/null || echo 0)
        fh_bar=$(make_bar "$fh_pct_int" 8)
        out+="${sep}${white}5h${reset} $fh_bar"
        if [ -n "$_fh_iso" ]; then
            five_hour_reset=$(format_reset_time "$_fh_iso" "hour12")
            [ -n "$five_hour_reset" ] && out+=" ${dim}@${five_hour_reset}${reset}"
        fi
    fi

    if [ -n "$builtin_seven_day_pct" ]; then
        sd_pct_int=$(printf '%.0f' "$builtin_seven_day_pct" 2>/dev/null || echo 0)
        sd_bar=$(make_bar "$sd_pct_int" 8)
        out+="${sep}${white}week${reset} $sd_bar"
        if [ -n "$_sd_iso" ]; then
            seven_day_reset=$(format_reset_time "$_sd_iso" "datetime12")
            [ -n "$seven_day_reset" ] && out+=" ${dim}@${seven_day_reset}${reset}"
        fi
    fi

    printf '{"five_hour":{"utilization":%s,"resets_at":%s},"seven_day":{"utilization":%s,"resets_at":%s}}' \
        "${builtin_five_hour_pct:-0}" "$([ -n "$_fh_iso" ] && echo "\"$_fh_iso\"" || echo "null")" \
        "${builtin_seven_day_pct:-0}" "$([ -n "$_sd_iso" ] && echo "\"$_sd_iso\"" || echo "null")" > "$cache_file" 2>/dev/null
elif [ -n "$usage_data" ] && echo "$usage_data" | jq -e '.five_hour' >/dev/null 2>&1; then
    five_hour_pct=$(echo "$usage_data" | jq -r '.five_hour.utilization // 0' | awk '{printf "%.0f", $1}')
    five_hour_reset_iso=$(echo "$usage_data" | jq -r '.five_hour.resets_at // empty')
    five_hour_reset=$(format_reset_time "$five_hour_reset_iso" "hour12")
    fh_bar=$(make_bar "$five_hour_pct" 8)
    out+="${sep}${white}5h${reset} $fh_bar"
    [ -n "$five_hour_reset" ] && out+=" ${dim}@${five_hour_reset}${reset}"
    seven_day_pct=$(echo "$usage_data" | jq -r '.seven_day.utilization // 0' | awk '{printf "%.0f", $1}')
    seven_day_reset_iso=$(echo "$usage_data" | jq -r '.seven_day.resets_at // empty')
    seven_day_reset=$(format_reset_time "$seven_day_reset_iso" "datetime12")
    sd_bar=$(make_bar "$seven_day_pct" 8)
    out+="${sep}${white}week${reset} $sd_bar"
    [ -n "$seven_day_reset" ] && out+=" ${dim}@${seven_day_reset}${reset}"
    extra_enabled=$(echo "$usage_data" | jq -r '.extra_usage.is_enabled // false')
    if [ "$extra_enabled" = "true" ]; then
        extra_pct=$(echo "$usage_data" | jq -r '.extra_usage.utilization // 0' | awk '{printf "%.0f", $1}')
        extra_used=$(echo "$usage_data" | jq -r '.extra_usage.used_credits // 0' | LC_NUMERIC=C awk '{printf "%.2f", $1/100}')
        extra_limit=$(echo "$usage_data" | jq -r '.extra_usage.monthly_limit // 0' | LC_NUMERIC=C awk '{printf "%.2f", $1/100}')
        if [ -n "$extra_used" ] && [ -n "$extra_limit" ] && [[ "$extra_used" != *'$'* ]] && [[ "$extra_limit" != *'$'* ]]; then
            extra_color=$(usage_color "$extra_pct")
            extra_segment="${sep}${white}extra${reset} ${extra_color}\$${extra_used}/\$${extra_limit}${reset}"
        else
            extra_segment="${sep}${white}extra${reset} ${green}enabled${reset}"
        fi
    fi
else
    out+="${sep}${white}5h${reset} ${dim}-${reset}"
    out+="${sep}${white}7d${reset} ${dim}-${reset}"
fi

# # ─── LINE 1: CONTEXT + RATE LIMITS ─────────────────────────────────────────

ctx_bar=$(make_bar "$pct_used")

# Build effort display
effort_display=""
case "$effort_level" in
    low)    effort_display="${dim}${effort_level}${reset}" ;;
    medium) effort_display="${orange}med${reset}" ;;
    max)    effort_display="${red}${effort_level}${reset}" ;;
    *)      effort_display="${green}${effort_level}${reset}" ;;
esac

line1="${blue}${model_name}${reset}${dim}-${reset}${effort_display}${sep}${ctx_bar} ${dim}${used_comma}/${reset}${orange}${used_tokens}${reset}${dim}·${reset}${orange}${total_tokens}${reset}"

total_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')

line2="$out"
[ -n "$extra_segment" ] && line2+="$extra_segment"
if [ -n "$total_cost" ] && [ "$total_cost" != "null" ]; then
    cost_fmt=$(LC_NUMERIC=C awk "BEGIN {printf \"%.2f\", $total_cost}")
    line2+="${sep}${white}cost${reset} ${green}\$${cost_fmt}${reset}"
fi
# # ─── OUTPUT ─────────────────────────────────────────────────────────────────

# Output 3 lines: model + ctx | cost + rate limits | git info
printf "%b\n" "$line1"
printf "%b\n" "$line2"
printf "%b" "$git_line"

exit 0
