#!/usr/bin/env bash

input=$(cat)

SEP="\e[1m|\e[0m"

# Color a percentage based on thresholds
pct_color() {
  local val=$1
  local int
  int=$(printf '%.0f' "$val")
  if [ "$int" -ge 90 ]; then
    printf "\e[31m%s%%\e[0m" "$int"
  elif [ "$int" -ge 70 ]; then
    printf "\e[33m%s%%\e[0m" "$int"
  else
    printf "\e[96m%s%%\e[0m" "$int"
  fi
}

# Repo folder name (always show git root, not cwd basename)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
git_root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
folder=$(basename "${git_root:-$cwd}")

# Subpath: full relative path below git root with neutral slashes
subproject=""
if [ -n "$git_root" ] && [ "$cwd" != "$git_root" ]; then
  rel="${cwd#$git_root/}"
  IFS='/' read -ra parts <<< "$rel"
  for part in "${parts[@]}"; do
    subproject="${subproject}\e[0m/\e[33m${part}"
  done
fi

# Git branch with dirty (*) and untracked (?) indicators
git_part=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  dirty=""
  untracked=""
  dirty_count=$(git -C "$cwd" diff --name-only 2>/dev/null | wc -l)
  staged_count=$(git -C "$cwd" diff --cached --name-only 2>/dev/null | wc -l)
  total_dirty=$((dirty_count + staged_count))
  if [ "$total_dirty" -gt 0 ]; then
    dirty="\e[33m*${total_dirty}\e[0m"
  fi
  if [ -n "$(git -C "$cwd" ls-files --others --exclude-standard 2>/dev/null)" ]; then
    untracked="\e[2m?\e[0m"
  fi
  ahead=$(git -C "$cwd" rev-list --count @{u}..HEAD 2>/dev/null)
  behind=$(git -C "$cwd" rev-list --count HEAD..@{u} 2>/dev/null)
  tracking=""
  [ "${ahead:-0}" -gt 0 ] 2>/dev/null && tracking="${tracking}\e[32m↑${ahead}\e[0m"
  [ "${behind:-0}" -gt 0 ] 2>/dev/null && tracking="${tracking}\e[31m↓${behind}\e[0m"
  [ -n "$tracking" ] && tracking="${tracking} "
  git_part="\e[97m[\e[0m${tracking}\e[36m${branch}\e[0m${dirty}${untracked}\e[97m]\e[0m "
fi

# Model: show name + version (e.g. "sonnet 4.6")
model_id=$(echo "$input" | jq -r '(.model.id // .model) // empty')
model_display=$(echo "$input" | jq -r '.model.display_name // empty')
model_name=$(echo "$model_id" | sed 's/claude-//' | sed 's/-[0-9].*//')
model_ver=$(echo "$model_display" | grep -oE '[0-9]+\.[0-9]+' | head -1)
# fallback: try extracting version from id
[ -z "$model_ver" ] && model_ver=$(echo "$model_id" | grep -oE '[0-9]+\.[0-9]+' | head -1)
model_part=""
if [ -n "$model_name" ]; then
  model_str="${model_name}${model_ver:+ ${model_ver}}"
  model_part="\e[2m${model_str}\e[0m"
fi

# Usage: ctx · 5h · 1w (labels dim, numbers colored by threshold)
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

usage_part=""
if [ -n "$used" ] || [ -n "$five" ] || [ -n "$week" ]; then
  usage_part=" ${SEP} "
  if [ -n "$used" ]; then
    usage_part="${usage_part}\e[2mctx\e[0m $(pct_color "$used")"
    { [ -n "$five" ] || [ -n "$week" ]; } && usage_part="${usage_part} · "
  fi
  if [ -n "$five" ]; then
    usage_part="${usage_part}\e[2m5h\e[0m $(pct_color "$five")"
    [ -n "$week" ] && usage_part="${usage_part} · "
  fi
  [ -n "$week" ] && usage_part="${usage_part}\e[2m1w\e[0m $(pct_color "$week")"
fi

# Order: [branch] folder | model | usage
folder_part="\e[33m${folder}${subproject}\e[0m"
if [ -n "$model_part" ]; then
  printf "%b%b %b%b%b" "$git_part" "$folder_part" "${SEP} " "$model_part" "$usage_part"
else
  printf "%b%b%b" "$git_part" "$folder_part" "$usage_part"
fi
