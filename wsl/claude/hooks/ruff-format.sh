#!/usr/bin/env bash
# Claude Code PostToolUse hook: formats every .py file Claude edits with ruff.
# Reads JSON from stdin with tool_input.file_path. Never blocks (exit 0).
file=$(jq -r '.tool_input.file_path // empty')
[[ "$file" == *.py && -f "$file" ]] || exit 0
command -v ruff >/dev/null || exit 0
ruff format --quiet "$file" 2>/dev/null
ruff check --fix --quiet "$file" 2>/dev/null
exit 0
