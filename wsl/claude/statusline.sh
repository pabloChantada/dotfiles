#!/usr/bin/env bash
# Claude Code status line: model | folder (git branch)
input=$(cat)
model=$(jq -r '.model.display_name // "?"' <<<"$input")
dir=$(jq -r '.workspace.current_dir // .cwd // empty' <<<"$input")
branch=$(git -C "${dir:-.}" branch --show-current 2>/dev/null)
printf '\033[35m%s\033[0m | \033[34m%s\033[0m%s' \
  "$model" "${dir##*/}" "${branch:+ \033[33m($branch)\033[0m}"
