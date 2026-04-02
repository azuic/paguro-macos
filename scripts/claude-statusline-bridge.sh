#!/bin/bash

set -euo pipefail

input=$(cat)
bridge_dir="${PAGURO_BRIDGE_DIR:-$HOME/Library/Application Support/Paguro/bridges}"
snapshot_path="${bridge_dir}/claude-statusline-latest.json"

mkdir -p "$bridge_dir"

tmp_file="$(mktemp "${bridge_dir}/claude-statusline-XXXXXX.json")"
trap 'rm -f "$tmp_file"' EXIT

printf '%s' "$input" > "$tmp_file"
mv "$tmp_file" "$snapshot_path"
trap - EXIT

if command -v jq >/dev/null 2>&1; then
  model="$(printf '%s' "$input" | jq -r '.model.display_name // "Claude"')"
  session_name="$(printf '%s' "$input" | jq -r '.session_name // empty')"
  session_id="$(printf '%s' "$input" | jq -r '.session_id // "session"')"
  used_pct="$(printf '%s' "$input" | jq -r '(.context_window.used_percentage // 0) | floor')"

  label="${session_name:-${session_id:0:8}}"
  echo "Paguro bridge / ${model} / ${label} / ${used_pct}%"
else
  echo "Paguro bridge active"
fi
