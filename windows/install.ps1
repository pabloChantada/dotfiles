# Instalador de la parte Windows.
# Ejecutar desde PowerShell NORMAL (no como administrador):
#   powershell -ExecutionPolicy Bypass -File \\wsl.localhost\Ubuntu\home\<usuario>\dotfiles\windows\install.ps1

$ErrorActionPreference = 'Continue'

function Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Magenta }

# --- Apps con winget ----------------------------------------------------------
Step 'Instalando apps con winget'
$apps = @(
  'wez.wezterm',
  'glzr-io.glazewm',
  'Microsoft.PowerToys',
  'Microsoft.VisualStudioCode',
  'Microsoft.PowerShell'
)
foreach ($app in $apps) {
  Write-Host "  - $app"
  winget install --id $app -e --accept-package-agreements --accept-source-agreements
}

# --- Scoop (herramientas sin admin) -------------------------------------------
Step 'Instalando Scoop'
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
  Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
} else {
  Write-Host '  Scoop ya instalado'
}

# Refrescar PATH en esta sesión para que encuentre scoop y code
$env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
            [Environment]::GetEnvironmentVariable('Path', 'User')

Step 'Fuente JetBrainsMono Nerd Font'
scoop install git
scoop bucket add nerd-fonts
scoop install nerd-fonts/JetBrainsMono-NF

# --- Extensiones de VS Code ----------------------------------------------------
Step 'Extensiones de VS Code'
$extensions = @(
  'ms-vscode-remote.remote-wsl',   # trabajar dentro de WSL
  'ms-python.python',
  'ms-toolsai.jupyter',
  'charliermarsh.ruff',
  'anthropic.claude-code',
  'Catppuccin.catppuccin-vsc',
  'Catppuccin.catppuccin-vsc-icons'
)
if (Get-Command code -ErrorAction SilentlyContinue) {
  foreach ($ext in $extensions) { code --install-extension $ext --force }
} else {
  Write-Host '  VS Code no está en el PATH todavía. Abre una PowerShell nueva y vuelve a ejecutar el script.' -ForegroundColor Yellow
}

Step 'Listo'
Write-Host 'Siguiente paso: abre Ubuntu (WSL) y ejecuta ./wsl/install.sh desde la carpeta dotfiles.'
