#!/usr/bin/env bash
# Copia dotfiles/windows/.wezterm.lua a tu carpeta de usuario de Windows.
# (Windows no sigue bien los enlaces simbólicos de WSL, por eso se copia.)
set -euo pipefail
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

win_profile=$(cd /mnt/c && cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')
WIN_HOME=$(wslpath "$win_profile")

dst="$WIN_HOME/.wezterm.lua"
if [ -f "$dst" ] && ! cmp -s "$dst" "$DOTFILES/windows/.wezterm.lua"; then
  cp "$dst" "$dst.bak"
  echo "  backup: $dst.bak"
fi
cp "$DOTFILES/windows/.wezterm.lua" "$dst"
echo "  WezTerm config copiada a $dst"
