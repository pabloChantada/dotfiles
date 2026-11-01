#!/usr/bin/env bash
# Hook PostToolUse de Claude Code: formatea con ruff cada .py que Claude edita.
# Recibe JSON por stdin con tool_input.file_path. Nunca bloquea (exit 0).
file=$(jq -r '.tool_input.file_path // empty')
[[ "$file" == *.py && -f "$file" ]] || exit 0
command -v ruff >/dev/null || exit 0
ruff format --quiet "$file" 2>/dev/null
ruff check --fix --quiet "$file" 2>/dev/null
exit 0
