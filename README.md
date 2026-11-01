# dotfiles — Windows + WSL2

Setup de desarrollo tipo Linux sobre Windows: **WezTerm + WSL2 (Ubuntu) + zsh + Starship + Neovim + Claude Code**, con **GlazeWM** (tiling) y **PowerToys**. Tema Kanagawa Dragon en todo (terminal, prompt, fzf y Neovim).

```
dotfiles/
├── README.md                  ← esta guía
├── windows/
│   ├── install.ps1            ← apps de Windows (winget + scoop + extensiones VS Code)
│   └── .wezterm.lua           ← config de WezTerm (se copia a C:\Users\<tú>\)
└── wsl/
    ├── install.sh             ← todo lo de Linux + enlaza las configs
    ├── sync-wezterm.sh        ← vuelve a copiar .wezterm.lua a Windows tras editarlo
    ├── .zshrc
    ├── starship.toml
    └── claude/                ← config global de Claude Code (~/.claude)
nvim/
└── 0001-wsl-support.patch     ← parche para tu repo de Neovim (ver sección 6)
        ├── CLAUDE.md
        ├── settings.json
        ├── statusline.sh
        ├── hooks/ruff-format.sh
        ├── skills/commit/SKILL.md
        └── agents/code-reviewer.md
```

Tiempo total: unos 20–30 minutos, la mayoría esperando descargas.

---

## 0. Antes de empezar: personaliza tres cosas

1. **`wsl/claude/CLAUDE.md`**: léelo y ajusta lo que no encaje contigo. Son las instrucciones que Claude Code leerá en todas tus sesiones.
2. **`windows/.wezterm.lua`**: si tu distro no se llama `Ubuntu` (compruébalo con `echo $WSL_DISTRO_NAME`), cámbialo en las dos líneas de arriba.
3. Si ya tienes un `~/.zshrc` o un `~/.claude/settings.json` con cosas tuyas, no se pierden: el instalador guarda un `.bak` con fecha.

---

## 1. Meter el pack en WSL

Los archivos de trabajo deben vivir dentro de Linux, no en `C:\`. Desde la terminal de Ubuntu:

```bash
sudo apt update && sudo apt install -y unzip
cp /mnt/c/Users/<tu_usuario_windows>/Downloads/dotfiles.zip ~
cd ~ && unzip dotfiles.zip && rm dotfiles.zip
cd ~/dotfiles
```

> No sabes tu usuario de Windows? `ls /mnt/c/Users/`

---

## 2. Parte Windows

Abre **PowerShell normal** (no como administrador; Scoop se niega a instalarse como admin) y ejecuta:

```powershell
powershell -ExecutionPolicy Bypass -File \\wsl.localhost\Ubuntu\home\<tu_usuario_linux>\dotfiles\windows\install.ps1
```

Instala:

| Qué | Para qué |
|---|---|
| WezTerm | Terminal |
| GlazeWM | Tiling window manager (se queda instalado pero puedes no arrancarlo) |
| PowerToys | Launcher, remapeo de teclas, etc. |
| VS Code + extensiones | WSL, Python, Jupyter, Ruff, Claude Code, Catppuccin |
| PowerShell 7 | La versión moderna (por si la usas) |
| Scoop + JetBrainsMono Nerd Font | Fuente con iconos para terminal y VS Code |

Si winget dice que algo ya está instalado, no pasa nada. Si al final avisa de que `code` no está en el PATH, abre una PowerShell nueva y vuelve a lanzarlo.

---

## 3. Parte WSL

En la terminal de Ubuntu:

```bash
cd ~/dotfiles
chmod +x wsl/install.sh
./wsl/install.sh
```

Te pedirá tu contraseña de Linux (para `sudo` y al final para cambiar la shell a zsh). Instala:

- **Base:** zsh, git, build-essential, ripgrep, fd, bat, jq, btop
- **CLI modernas:** eza, fzf, zoxide, lazygit, gh (GitHub CLI)
- **Prompt:** starship
- **Editor:** Neovim (última estable en `/opt`, la de apt es muy vieja)
- **Python:** uv + ruff
- **Node LTS** (vía fnm), necesario para muchos LSP de Neovim
- **Claude Code**
- **Plugins zsh:** autosuggestions + syntax highlighting (sin oh-my-zsh, arranca más rápido)

Y enlaza las configs (`~/.zshrc`, `~/.config/starship.toml`, `~/.claude/...`) con enlaces simbólicos a esta carpeta. Si editas el archivo del repo, el cambio se aplica directamente.

Al terminar: **cierra WezTerm y ábrelo de nuevo.**

### Comprobación rápida

```bash
echo $SHELL            # → /usr/bin/zsh
ll                     # listado con iconos y colores
z dot                  # salta a ~/dotfiles (zoxide aprende de dónde vas)
nvim --version         # 0.11 o superior
claude --version
```

Si los iconos salen como cuadrados, la fuente no está bien: revisa que `JetBrainsMono Nerd Font` aparece en la configuración de fuentes de Windows.

### Configura git (una vez)

```bash
git config --global user.name "Pablo ..."
git config --global user.email "tu@email.com"
gh auth login          # GitHub → HTTPS → login con navegador
```

---

## 4. WezTerm: cómo usarlo

**Leader = `Ctrl+a`**: lo pulsas, sueltas y pulsas la tecla. Abajo a la derecha aparece `LEADER` mientras está activo.

| Atajo | Acción |
|---|---|
| `Ctrl+a` `v` | Dividir panel lado a lado |
| `Ctrl+a` `s` | Dividir panel arriba/abajo |
| `Ctrl+a` `h/j/k/l` | Moverse entre paneles |
| `Ctrl+a` `z` | Zoom al panel actual (otra vez para volver) |
| `Ctrl+a` `r` → `h/j/k/l` | Redimensionar (Esc para salir) |
| `Ctrl+a` `x` | Cerrar panel |
| `Ctrl+a` `c` | Nueva pestaña |
| `Ctrl+a` `n` / `p` / `1-9` | Pestaña siguiente / anterior / número |
| `Ctrl+a` `d` | **Abre Claude Code en un panel a la derecha (35%)** |
| `Ctrl+a` `Espacio` | Paleta de comandos de WezTerm |
| `Ctrl+a` `Ctrl+a` | Envía `Ctrl+a` real (inicio de línea) |
| `Ctrl+Shift+c` / `Ctrl+Shift+v` | Copiar / pegar |

**Flujo típico:** `z miproyecto` → `nvim .` → `Ctrl+a d` → tienes el editor a la izquierda y Claude a la derecha.

**Editar la config de WezTerm:** edita `~/dotfiles/windows/.wezterm.lua` y ejecuta `~/dotfiles/wsl/sync-wezterm.sh`. Se aplica al instante. Windows no puede leer bien enlaces simbólicos de WSL, por eso aquí se copia en lugar de enlazar.

---

## 5. zsh: lo que tienes ahora

| Atajo / comando | Qué hace |
|---|---|
| `Ctrl+R` | Buscar en el historial con fzf |
| `Ctrl+T` | Buscar un archivo e insertarlo en el comando |
| `Alt+C` | Buscar una carpeta y entrar |
| `→` (flecha derecha) | Aceptar la sugerencia gris (autosuggestions) |
| `z <algo>` | Ir a una carpeta que ya visitaste |
| `ll`, `lt` | Listado detallado / árbol |
| `lg` | lazygit |
| `open .` | Abrir la carpeta actual en el Explorador de Windows |
| `cmd \| copy` | Mandar la salida al portapapeles de Windows |
| `venv` | Crea (si no existe) y activa `.venv` con uv |

Lo que no quieras subir a GitHub (tokens, alias privados) ponlo en `~/.zshrc.local`, que se carga solo.

---

## 6. Neovim: trae tu config

`install.sh` clona tu config ([pabloChantada/nvim](https://github.com/pabloChantada/nvim)) en `~/.config/nvim`. Sigue siendo un repo independiente: haces commits y push desde ahí como siempre.

### Aplica el parche de WSL (una vez)

`nvim/0001-wsl-support.patch` adapta tu config a este setup:

| Cambio | Por qué |
|---|---|
| Portapapeles con `clip.exe` / PowerShell en WSL | WSL define `WAYLAND_DISPLAY`, así que tu config intentaba usar `wl-copy`, que no está instalado ni sincroniza con Windows. `"+y` no funcionaba. |
| `nvim-treesitter` fijado a `branch = "master"` | Tu `lazy-lock.json` tiene la rama `main` (la nueva por defecto), que ya no incluye `nvim-treesitter.configs`. Tu config usa esa API, así que al arrancar fallaría. |
| Python se formatea con `ruff` en lugar de `black` | Mismo formato que aplica el hook de Claude Code, para que no se peleen. Además `black` no estaba instalado. |
| Mover splits: `Alt+hjkl` → `<Espacio>w` + `hjkl` | GlazeWM captura `Alt+hjkl` a nivel de sistema y Neovim nunca los recibiría. |
| Crea `~/.vim/undodir` si no existe | Sin la carpeta, el historial de undo persistente no se guarda. |

```bash
cd ~/.config/nvim
git apply ~/dotfiles/nvim/0001-wsl-support.patch
git diff                       # revisa los cambios
git commit -am "fix: WSL support"
git push
```

Después abre `nvim`. Lazy instalará los plugins, cambiará treesitter de rama y Mason instalará los LSP. Ya tienes todo lo que necesitan: gcc, make, unzip, node, ripgrep y fd. Si algo queda raro, ejecuta `:Lazy sync` y `:checkhealth`.

### Notas

- **Harpoon `Ctrl+1..4`:** la mayoría de terminales no envía `Ctrl+número`. La config de WezTerm activa `enable_kitty_keyboard` para que funcione, igual que en Ghostty/Kitty.
- **Copilot:** la primera vez ejecuta `:Copilot auth`.
- **Colores:** WezTerm usa Kanagawa Dragon con la misma paleta y opacidad (0.9) que tenías en Ghostty, así que tu Neovim transparente se ve igual que antes.

---

## 7. VS Code con WSL

1. Desde la terminal, dentro de tu proyecto: `code .`
   La primera vez instala el "VS Code Server" en WSL (unos segundos).
2. Abajo a la izquierda debe poner **WSL: Ubuntu**. Eso indica que el código, la terminal integrada y los venvs corren en Linux.
3. Las extensiones de Python, Jupyter y Ruff hay que activarlas también "en WSL". VS Code te muestra un botón *Install in WSL: Ubuntu* en la pestaña de extensiones.
4. Ajustes recomendados (`Ctrl+,` → icono de JSON arriba a la derecha):
   ```json
   {
     "workbench.colorTheme": "Kanagawa",
     "editor.fontFamily": "'JetBrainsMono Nerd Font', monospace",
     "editor.fontLigatures": true,
     "terminal.integrated.fontFamily": "'JetBrainsMono Nerd Font'",
     "[python]": {
       "editor.defaultFormatter": "charliermarsh.ruff",
       "editor.formatOnSave": true
     }
   }
   ```
5. Para el tema, instala la extensión **Kanagawa** desde el marketplace (o quédate con Catppuccin, que ya viene instalada).
6. Opcional: extensión **Vim** (`vscodevim.vim`) si quieres los atajos de Neovim también en VS Code.

---

## 8. Claude Code

### Primer arranque

```bash
claude           # te pedirá login con tu cuenta la primera vez
```

### Qué trae configurado (en `~/.claude/`, enlazado a `wsl/claude/`)

| Archivo | Qué hace |
|---|---|
| `CLAUDE.md` | Instrucciones globales: español, código en inglés, uv, ruff, pytest, no hacer commits sin pedirlo... |
| `settings.json` → `permissions.allow` | Comandos que puede ejecutar sin preguntarte (git status/diff/log, rg, fd, pytest, ruff, uv run...) |
| `settings.json` → `permissions.ask` | Siempre pregunta antes de `git push`, `git reset`, `rm` |
| `settings.json` → `permissions.deny` | Nunca lee `.env`, `secrets/` ni `~/.ssh` |
| `hooks/ruff-format.sh` | Cada vez que Claude edita un `.py`, se formatea con ruff automáticamente |
| `statusline.sh` | Barra inferior: modelo, carpeta y rama git |
| `skills/commit` | `/commit` → revisa cambios, pasa tests y propone mensaje Conventional Commits |
| `agents/code-reviewer` | Subagente revisor. Pídele "revisa los cambios con el code-reviewer" |

### Por proyecto

En cada repo nuevo, ejecuta `/init` dentro de Claude Code. Genera un `CLAUDE.md` del proyecto (cómo se ejecuta, estructura, comandos de test). Revísalo, recórtalo a lo esencial y súbelo al repo.

Para permisos o hooks específicos de un proyecto, usa `.claude/settings.json` dentro del repo. Si son solo tuyos y no quieres compartirlos, usa `.claude/settings.local.json` (no se sube).

### Hábitos que más rendimiento le sacan

- **Plan mode (`Shift+Tab`)** antes de cualquier cambio grande: primero plan, lo corriges y luego ejecuta.
- **`/clear` entre tareas distintas**: el contexto limpio da mejores resultados que una conversación eterna.
- **Commits frecuentes**: así cualquier cosa que haga mal se deshace con git.
- **Dale forma de verificar**: tests, un comando que reproduzca el bug, un ejemplo de salida esperada. Rinde mucho más si puede comprobar su trabajo.
- **Referencia archivos con `@`**: `@src/model.py` en lugar de describirlos.
- **Cuando repitas algo 3 veces, conviértelo en skill:** crea `~/dotfiles/wsl/claude/skills/<nombre>/SKILL.md` y enlázalo en `install.sh` como `commit`.

### Opcional: MCP de documentación

Context7 da a Claude documentación actualizada de librerías (útil con PyTorch, LangChain, FastAPI... que cambian rápido):

```bash
claude mcp add --transport http context7 https://mcp.context7.com/mcp
```

---

## 9. GlazeWM (tiling)

Arráncalo desde el menú Inicio. La primera vez crea su config en `C:\Users\<tú>\.glzr\glazewm\config.yaml`. El instalador también ofrece **Zebar**, su barra de estado; acéptalo si quieres la barra.

### Atajos por defecto que necesitas ya

| Atajo | Acción |
|---|---|
| `Alt+h/j/k/l` o flechas | Mover el foco |
| `Alt+Shift+h/j/k/l` | Mover la ventana |
| `Alt+1..9` | Ir al escritorio N |
| `Alt+Shift+1..9` | Mandar la ventana al escritorio N |
| `Alt+v` | Cambiar dirección del siguiente split |
| `Alt+r` | Modo resize (h/j/k/l, Esc para salir) |
| `Alt+Shift+Espacio` | Ventana flotante ↔ en mosaico |
| `Alt+f` | Pantalla completa |
| `Alt+Shift+p` | **Pausar GlazeWM** (Windows normal) y reanudarlo |
| `Alt+Shift+r` | Recargar la config |
| `Alt+Shift+e` | Salir de GlazeWM |

Si `Alt+Shift+p` no hace nada en tu versión, busca `wm-toggle-pause` en el `config.yaml` y ponle ese atajo.

### Cambios recomendados en `config.yaml`

Edita el archivo y recarga con `Alt+Shift+r`:

1. **`Alt+Enter` abre WezTerm** en lugar de cmd. Busca `shell-exec cmd` y cámbialo por:
   ```yaml
   - commands: ['shell-exec wezterm-gui']
     bindings: ['alt+enter']
   ```
   Si no lo encuentra, usa la ruta completa: `shell-exec "C:\Program Files\WezTerm\wezterm-gui.exe"`.

2. **Bordes con colores Kanagawa.** En `window_effects`:
   ```yaml
   focused_window:
     border:
       enabled: true
       color: '#c4b28a'   # amarillo kanagawa
   other_windows:
     border:
       enabled: true
       color: '#393836'
   ```

3. **Gaps más finos**, si te sobra espacio. En `gaps`: `inner_gap: '8px'` y outer de `8px` (deja `top` mayor si usas Zebar).

4. **Conflictos de atajos.** Si usas PowerToys Run con `Alt+Espacio`, elimina o cambia el binding `wm-cycle-focus` de GlazeWM que usa `alt+space`.

5. **Que no toque ciertas apps.** En `window_rules`, bajo el bloque con `commands: ['ignore']`, puedes añadir apps que deban ir siempre flotantes (juegos, launchers):
   ```yaml
   - window_process: { equals: 'LeagueClientUx' }
   - window_process: { equals: 'League of Legends' }
   - window_process: { equals: 'steam' }
   ```

6. Para que arranque con Windows: `general.startup_commands` no lo hace. Añade un acceso directo a GlazeWM en `shell:startup` (Win+R → `shell:startup`).

Cuando lo tengas a tu gusto, copia el `config.yaml` a `~/dotfiles/windows/glazewm.yaml` para tenerlo versionado.

---

## 10. PowerToys

Abre PowerToys → Configuración y activa:

- **Keyboard Manager** → *Reasignar una tecla*: `Bloq Mayús` → `Esc`. Si usas Vim, se nota muchísimo. Alternativa: → `Ctrl`.
- **Command Palette** (`Win+Alt+Espacio`): launcher de apps, archivos, calculadora...
- **Text Extractor** (`Win+Shift+T`): OCR de cualquier zona de la pantalla.
- **Peek** (`Ctrl+Espacio` en el Explorador): previsualizar archivos.
- **Environment Variables**: editor de variables de entorno mucho mejor que el de Windows.
- **FancyZones**: déjalo desactivado si usas GlazeWM, porque chocan.

---

## 11. Subirlo a tu GitHub

```bash
cd ~/dotfiles
git init && git add . && git commit -m "feat: initial dotfiles"
gh repo create dotfiles --public --source=. --push
```

En un PC nuevo: instalas WSL, `git clone` del repo, `install.ps1` y `install.sh`, y en 20 minutos tienes todo igual.

---

## 12. Problemas comunes

| Problema | Solución |
|---|---|
| WezTerm abre en `/mnt/c/...` y no en `~` | Revisa que `default_cwd = '~'` está en `.wezterm.lua` y que el nombre de la distro es correcto |
| `wsl` abre docker-desktop | Desde WSL: `wsl.exe --set-default Ubuntu` |
| Iconos como cuadrados | Falta la Nerd Font. `scoop install nerd-fonts/JetBrainsMono-NF` y reinicia WezTerm |
| git/pip/node van lentísimos | Estás trabajando en `/mnt/c`. Mueve el proyecto a `~/` |
| El prompt no cambia tras instalar | `exec zsh`, o cierra y abre WezTerm. Comprueba que `echo $SHELL` da zsh |
| `chsh` falla | Ejecútalo a mano: `chsh -s $(which zsh)` |
| Claude Code no encuentra `ruff` en el hook | `uv tool install ruff` y comprueba que `~/.local/bin` está en el PATH |
| GlazeWM descoloca un juego o app | Añádela a `window_rules` con `ignore`, o pausa GlazeWM con `Alt+Shift+p` |
| WSL ocupa mucha RAM | Crea `C:\Users\<tú>\.wslconfig` con `[wsl2]` y `memory=8GB`, luego `wsl.exe --shutdown` |
