# dotfiles

My development setup on Windows + WSL2 (Ubuntu): WezTerm, zsh, Starship, Neovim and Claude Code, with GlazeWM and PowerToys on the Windows side. Kanagawa Dragon theme.

```
windows/install.ps1          Windows apps (winget, scoop, VS Code extensions)
windows/.wezterm.lua         WezTerm config (copied to C:\Users\<user>\)
wsl/install.sh               Linux packages + config symlinks
wsl/sync-wezterm.sh          re-copies .wezterm.lua to Windows
wsl/.zshrc, wsl/starship.toml
wsl/claude/                  global Claude Code config (~/.claude)
nvim/0001-wsl-support.patch  patch for my Neovim config repo
config.yaml                  GlazeWM config
```

## Requirements

- Windows 10/11 with WSL2 and Ubuntu installed (`wsl --install -d Ubuntu`).
- About 20-30 minutes.

## Installation

### 1. Clone the repo inside WSL

Clone it into the Linux filesystem, not `/mnt/c` (everything is much slower there).

```bash
sudo apt update && sudo apt install -y git
git clone https://github.com/pabloChantada/dotfiles.git ~/dotfiles
```

Before continuing, check:

- `windows/.wezterm.lua`: if your distro isn't called `Ubuntu` (`echo $WSL_DISTRO_NAME`), change it.
- `wsl/claude/CLAUDE.md`: global instructions for Claude Code, adjust as needed.

### 2. Install the Windows apps

From a PowerShell **without admin rights** (Scoop refuses to install as admin):

```powershell
powershell -ExecutionPolicy Bypass -File \\wsl.localhost\Ubuntu\home\<linux_user>\dotfiles\windows\install.ps1
```

Installs WezTerm, GlazeWM, PowerToys, VS Code (with extensions), PowerShell 7, Scoop and JetBrainsMono Nerd Font.

If it warns that `code` is not in the PATH, open a new PowerShell and run it again.

### 3. Install the WSL environment

```bash
cd ~/dotfiles
./wsl/install.sh
```

It asks for your sudo password and, at the end, for `chsh` to switch to zsh. It's safe to run multiple times: it skips what's already installed and backs up (`*.bak.<date>`) any existing config before replacing it.

Installs zsh and plugins, starship, eza, fzf, zoxide, ripgrep, fd, bat, lazygit, gh, Neovim (in `/opt`), uv, ruff, Node LTS (fnm) and Claude Code. It also clones my Neovim config into `~/.config/nvim` and symlinks the configs from this repo, so editing a file in the repo applies the change directly.

Close and reopen WezTerm.

### 4. Verify

```bash
echo $SHELL        # /usr/bin/zsh
ll                 # listing with icons
nvim --version     # 0.11+
claude --version
```

If icons show up as boxes, the Nerd Font is missing (see [Troubleshooting](#troubleshooting)).

### 5. Set up git and GitHub

```bash
git config --global user.name "Your Name"
git config --global user.email "you@email.com"
gh auth login
```

### 6. Neovim

Apply the WSL patch to the Neovim config (first time only):

```bash
cd ~/.config/nvim
git apply ~/dotfiles/nvim/0001-wsl-support.patch
git diff
git commit -am "fix: WSL support" && git push
```

The patch:

- uses `clip.exe` for the clipboard (WSL sets `WAYLAND_DISPLAY`, so the config tried to use `wl-copy`);
- pins `nvim-treesitter` to the `master` branch, since the config uses `nvim-treesitter.configs`;
- formats Python with `ruff` instead of `black`;
- changes split movement from `Alt+hjkl` to `<Space>w` + `hjkl`, because GlazeWM captures `Alt+hjkl`;
- creates `~/.vim/undodir` if it doesn't exist.

Open `nvim` and let Lazy and Mason install everything. If something breaks: `:Lazy sync` and `:checkhealth`. For Copilot: `:Copilot auth`.

### 7. Claude Code

```bash
claude    # log in the first time
```

Optional, up-to-date library docs with Context7:

```bash
claude mcp add --transport http context7 https://mcp.context7.com/mcp
```

### 8. GlazeWM

Start it once from the Start menu so it creates `C:\Users\<user>\.glzr\glazewm\config.yaml`. Then replace it with the one from the repo:

```bash
cp ~/dotfiles/config.yaml /mnt/c/Users/<windows_user>/.glzr/glazewm/config.yaml
```

Reload with `Alt+Shift+r`. To start it with Windows, create a shortcut in `shell:startup` (Win+R).

If you change the config from Windows, copy it back to the repo to keep it versioned.

### 9. PowerToys

In PowerToys → Settings:

- Keyboard Manager: remap `Caps Lock` → `Esc`.
- Command Palette (`Win+Alt+Space`), Text Extractor (`Win+Shift+T`) and Peek (`Ctrl+Space`).
- FancyZones disabled (conflicts with GlazeWM).

### 10. VS Code (optional)

Open a project from WSL with `code .`. The bottom-left corner should show `WSL: Ubuntu`. Install the Python, Jupyter and Ruff extensions in WSL too (*Install in WSL: Ubuntu* button).

`settings.json`:

```json
{
  "editor.fontFamily": "'JetBrainsMono Nerd Font', monospace",
  "terminal.integrated.fontFamily": "'JetBrainsMono Nerd Font'",
  "[python]": {
    "editor.defaultFormatter": "charliermarsh.ruff",
    "editor.formatOnSave": true
  }
}
```

## Usage

### WezTerm

Leader: `Ctrl+a` (press, release, then the key).

| Shortcut | Action |
|---|---|
| `Ctrl+a v` / `s` | Split vertical / horizontal |
| `Ctrl+a h/j/k/l` | Move between panes |
| `Ctrl+a z` | Zoom pane |
| `Ctrl+a r`, then `h/j/k/l` | Resize (Esc or Enter to exit) |
| `Ctrl+a x` | Close pane |
| `Ctrl+a c` | New tab |
| `Ctrl+a n` / `p` / `1-9` | Switch tab |
| `Ctrl+a t` | Tab navigator |
| `Ctrl+a d` | Claude Code in a pane on the right |
| `Ctrl+a Space` | Command palette |
| `Ctrl+a Ctrl+a` | Send `Ctrl+a` |

To change the config, edit `windows/.wezterm.lua` and run `./wsl/sync-wezterm.sh`. It's copied instead of symlinked because Windows can't read WSL symlinks properly.

### zsh

| Shortcut / command | Action |
|---|---|
| `Ctrl+R` | Search history (fzf) |
| `Ctrl+T` | Insert a file into the command |
| `Alt+C` | cd into a folder |
| `→` | Accept suggestion |
| `z <dir>` | Jump to a visited folder |
| `ll`, `lt` | Detailed listing / tree |
| `lg` | lazygit |
| `open .` | Open in Explorer |
| `... \| copy` | Copy to the Windows clipboard |
| `venv` | Create and activate `.venv` with uv |

Private aliases or tokens go in `~/.zshrc.local`, which is loaded automatically and isn't in the repo.

### GlazeWM

| Shortcut | Action |
|---|---|
| `Alt+h/j/k/l` | Move focus |
| `Alt+Shift+h/j/k/l` | Move window |
| `Alt+1-9` / `Alt+Shift+1-9` | Go to / send to workspace N |
| `Alt+v` | Toggle split direction |
| `Alt+r` | Resize mode |
| `Alt+Shift+Space` | Toggle floating / tiling |
| `Alt+f` | Fullscreen |
| `Alt+Shift+p` | Pause |
| `Alt+Shift+r` | Reload config |

Apps that should stay out of tiling (games, launchers) go in `window_rules` with `ignore`.

### Claude Code

What's in `wsl/claude/` (symlinked to `~/.claude/`):

- `CLAUDE.md`: global instructions.
- `settings.json`: permissions (allow, ask, deny), hook and statusline.
- `hooks/ruff-format.sh`: formats every `.py` file Claude edits with ruff.
- `statusline.sh`: model, folder and branch.
- `skills/commit`: `/commit`.
- `agents/code-reviewer.md`: review subagent.

In each new project, `/init` generates its `CLAUDE.md`. Repo-specific permissions go in `.claude/settings.json` (or `.claude/settings.local.json` if they shouldn't be committed).

To add a new skill: create `wsl/claude/skills/<name>/SKILL.md` and add its `link` line in `wsl/install.sh`.

## Troubleshooting

| Problem | Fix |
|---|---|
| WezTerm opens in `/mnt/c/...` | Check `default_cwd` and the distro name in `.wezterm.lua` |
| `wsl` opens docker-desktop | `wsl.exe --set-default Ubuntu` |
| Icons show as boxes | `scoop install nerd-fonts/JetBrainsMono-NF` and restart WezTerm |
| git/node very slow | The project is in `/mnt/c`; move it to `~/` |
| Prompt doesn't change | `exec zsh`; if `chsh` failed: `chsh -s $(which zsh)` |
| Hook can't find `ruff` | `uv tool install ruff` and check `~/.local/bin` is in the PATH |
| WSL uses too much RAM | `C:\Users\<user>\.wslconfig` with `[wsl2]` and `memory=8GB`, then `wsl.exe --shutdown` |
