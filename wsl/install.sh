#!/usr/bin/env bash
# Instalador del entorno WSL (Ubuntu).
# Uso:  cd ~/dotfiles && ./wsl/install.sh
# Es seguro ejecutarlo varias veces: salta lo que ya está instalado y hace
# backup (*.bak.<fecha>) de cualquier config tuya antes de reemplazarla.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN="$HOME/.local/bin"
mkdir -p "$BIN" "$HOME/.config" "$HOME/.claude"
export PATH="$BIN:$PATH"

log()  { printf '\n\033[1;35m==> %s\033[0m\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

link() { # link <origen> <destino>
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "$dst.bak.$(date +%Y%m%d%H%M%S)"
    echo "  backup de $dst"
  fi
  ln -sfn "$src" "$dst"
  echo "  $dst -> $src"
}

clone_or_pull() { # clone_or_pull <repo> <carpeta>
  if [ -d "$2/.git" ]; then git -C "$2" pull --quiet; else git clone --depth 1 "$1" "$2"; fi
}

# -----------------------------------------------------------------------------
log "Paquetes base (apt)"
sudo apt update
sudo apt upgrade -y
sudo apt install -y zsh git curl wget unzip build-essential gpg ca-certificates \
  ripgrep fd-find bat jq btop python3 python3-venv

# En Ubuntu bat y fd se llaman batcat y fdfind
ln -sf "$(command -v batcat)" "$BIN/bat"
ln -sf "$(command -v fdfind)" "$BIN/fd"

# -----------------------------------------------------------------------------
log "eza (ls moderno)"
if ! have eza; then
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
    | sudo gpg --dearmor --yes -o /etc/apt/keyrings/gierens.gpg
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
    | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
  sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
  sudo apt update && sudo apt install -y eza
fi

# -----------------------------------------------------------------------------
log "GitHub CLI (gh)"
if ! have gh; then
  sudo mkdir -p -m 755 /etc/apt/keyrings
  wget -nv -O- https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  sudo apt update && sudo apt install -y gh
fi

# -----------------------------------------------------------------------------
log "fzf (versión reciente, la de apt es antigua)"
clone_or_pull https://github.com/junegunn/fzf.git "$HOME/.fzf"
"$HOME/.fzf/install" --bin
ln -sf "$HOME/.fzf/bin/fzf" "$BIN/fzf"

log "starship (prompt)"
have starship || curl -sS https://starship.rs/install.sh | sh -s -- -y

log "zoxide (cd inteligente)"
have zoxide || curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# -----------------------------------------------------------------------------
log "Neovim (última estable, en /opt)"
tmp=$(mktemp -d)
curl -fsSL -o "$tmp/nvim.tar.gz" \
  https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf "$tmp/nvim.tar.gz"
ln -sf /opt/nvim-linux-x86_64/bin/nvim "$BIN/nvim"

log "Config de Neovim (github.com/pabloChantada/nvim)"
if [ ! -d "$HOME/.config/nvim/.git" ]; then
  [ -e "$HOME/.config/nvim" ] && mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak.$(date +%Y%m%d%H%M%S)"
  git clone https://github.com/pabloChantada/nvim "$HOME/.config/nvim"
else
  echo "  ~/.config/nvim ya existe, no se toca"
fi

log "lazygit"
if ! have lazygit; then
  LG_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
    | grep -Po '"tag_name": *"v\K[^"]*')
  curl -fsSL -o "$tmp/lazygit.tar.gz" \
    "https://github.com/jesseduffield/lazygit/releases/download/v${LG_VERSION}/lazygit_${LG_VERSION}_Linux_x86_64.tar.gz"
  tar -xzf "$tmp/lazygit.tar.gz" -C "$tmp" lazygit
  install "$tmp/lazygit" "$BIN/lazygit"
fi
rm -rf "$tmp"

# -----------------------------------------------------------------------------
log "uv (Python) + ruff"
have uv || curl -LsSf https://astral.sh/uv/install.sh | sh
uv tool install ruff 2>/dev/null || uv tool upgrade ruff

log "Node LTS con fnm (lo necesitan muchos LSP de Neovim)"
if [ ! -d "$HOME/.local/share/fnm" ]; then
  curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
fi
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env --shell bash)"
fnm install --lts
fnm default lts-latest || true

log "Claude Code"
have claude || curl -fsSL https://claude.ai/install.sh | bash

# -----------------------------------------------------------------------------
log "Plugins de zsh"
mkdir -p "$HOME/.zsh"
clone_or_pull https://github.com/zsh-users/zsh-autosuggestions "$HOME/.zsh/zsh-autosuggestions"
clone_or_pull https://github.com/zsh-users/zsh-syntax-highlighting "$HOME/.zsh/zsh-syntax-highlighting"

# -----------------------------------------------------------------------------
log "Enlazando configs"
chmod +x "$DOTFILES"/wsl/*.sh "$DOTFILES"/wsl/claude/*.sh "$DOTFILES"/wsl/claude/hooks/*.sh
link "$DOTFILES/wsl/.zshrc"                         "$HOME/.zshrc"
link "$DOTFILES/wsl/starship.toml"                  "$HOME/.config/starship.toml"
link "$DOTFILES/wsl/claude/CLAUDE.md"               "$HOME/.claude/CLAUDE.md"
link "$DOTFILES/wsl/claude/settings.json"           "$HOME/.claude/settings.json"
link "$DOTFILES/wsl/claude/statusline.sh"           "$HOME/.claude/statusline.sh"
link "$DOTFILES/wsl/claude/hooks"                   "$HOME/.claude/hooks"
link "$DOTFILES/wsl/claude/skills/commit"           "$HOME/.claude/skills/commit"
link "$DOTFILES/wsl/claude/agents/code-reviewer.md" "$HOME/.claude/agents/code-reviewer.md"

log "Git: valores por defecto"
git config --global init.defaultBranch main
git config --global core.editor nvim
git config --global pull.rebase false
git config --global core.autocrlf input
if [ -z "$(git config --global user.name || true)" ]; then
  echo "  Falta tu nombre/email de git. Ejecuta:"
  echo "    git config --global user.name \"Tu Nombre\""
  echo "    git config --global user.email \"tu@email.com\""
fi

log "WezTerm: copiando config a Windows"
"$DOTFILES/wsl/sync-wezterm.sh" || echo "  (no se pudo copiar; hazlo a mano, ver README)"

# -----------------------------------------------------------------------------
log "zsh como shell por defecto"
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]; then
  chsh -s "$(command -v zsh)"
fi

log "¡Hecho! Cierra WezTerm y vuelve a abrirlo."
