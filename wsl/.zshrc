# ~/.zshrc  (enlace simbólico a dotfiles/wsl/.zshrc)

# --- PATH y editor ------------------------------------------------------------
export PATH="$HOME/.local/bin:$HOME/.fzf/bin:$PATH"
export EDITOR=nvim
export VISUAL=nvim

# --- Historial ----------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE INC_APPEND_HISTORY
setopt AUTO_CD INTERACTIVE_COMMENTS

# --- Autocompletado -----------------------------------------------------------
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'   # sin distinguir mayúsculas
zstyle ':completion:*' menu select

# Atajos estilo emacs (Ctrl+a, Ctrl+e...) + Ctrl+flechas para saltar palabras
bindkey -e
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[3~' delete-char

# --- Node (fnm) ---------------------------------------------------------------
if [ -d "$HOME/.local/share/fnm" ]; then
  export PATH="$HOME/.local/share/fnm:$PATH"
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

# --- Herramientas -------------------------------------------------------------
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border
  --color=bg+:#282727,fg:#c5c9c5,fg+:#c8c093,hl:#c4746e,hl+:#e46876
  --color=info:#8ba4b1,prompt:#c4b28a,pointer:#c4746e,marker:#8a9a7b,spinner:#a292a3,header:#8ea4a2,border:#393836'

command -v fzf     >/dev/null && source <(fzf --zsh)       # Ctrl+R historial, Ctrl+T archivos, Alt+C carpetas
command -v zoxide  >/dev/null && eval "$(zoxide init zsh)" # z <parte del nombre>
command -v starship >/dev/null && eval "$(starship init zsh)"

# WezTerm: informa del directorio actual para que los paneles nuevos se abran ahí
_wezterm_osc7() { printf '\e]7;file://%s%s\e\\' "$HOST" "$PWD" }
precmd_functions+=(_wezterm_osc7)

# --- Alias --------------------------------------------------------------------
alias ls='eza --icons --group-directories-first'
alias ll='eza -lah --icons --group-directories-first --git'
alias lt='eza --tree --level=2 --icons --git-ignore'
alias cat='bat --paging=never'
alias lg='lazygit'
alias v='nvim'
alias gs='git status'
alias gd='git diff'
alias ..='cd ..'
alias ...='cd ../..'
alias open='explorer.exe'          # open . -> abre la carpeta en el Explorador
alias copy='clip.exe'              # echo hola | copy -> al portapapeles de Windows
alias dots='cd ~/dotfiles'

# Crear y activar venv con uv en el proyecto actual
venv() { [ -d .venv ] || uv venv; source .venv/bin/activate }

# --- Plugins (siempre al final) -----------------------------------------------
[ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
  source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
  source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Config local que no quieres subir a GitHub (tokens, alias privados...)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
