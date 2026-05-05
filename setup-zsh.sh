#!/usr/bin/env bash
#====================================================================================
# Thinwork - ti@thinwork.com.br - Devops - Tecnologia - Consultoria - Desenvolvimento
#
# Provisiona Zsh + Oh My Zsh + Powerlevel10k + plugins no Ubuntu 24.04 LTS.
# Idempotente: pode ser executado múltiplas vezes sem efeitos colaterais.
#
# Uso:   ./setup-zsh.sh
#====================================================================================
set -euo pipefail

#--- Helpers -------------------------------------------------------------------
log()  { printf '\e[1;34m[+]\e[0m %s\n' "$*"; }
warn() { printf '\e[1;33m[!]\e[0m %s\n' "$*"; }
die()  { printf '\e[1;31m[x]\e[0m %s\n' "$*" >&2; exit 1; }

[[ $EUID -eq 0 ]] && die "Não execute como root. Use seu usuário com sudo."
command -v sudo >/dev/null || die "sudo é necessário."

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

clone_or_update() {
  local repo=$1 dest=$2
  if [[ -d $dest ]]; then
    git -C "$dest" pull --quiet --ff-only || warn "Falha ao atualizar $dest"
  else
    git clone --depth=1 --quiet "$repo" "$dest"
  fi
}

#--- 1. Pacotes base -----------------------------------------------------------
log "Atualizando índice APT e instalando pacotes base..."
sudo apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
  zsh powerline fonts-powerline git curl wget ca-certificates

#--- 2. Shell padrão -----------------------------------------------------------
ZSH_BIN=$(command -v zsh)
if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$ZSH_BIN" ]]; then
  log "Definindo Zsh como shell padrão..."
  sudo chsh -s "$ZSH_BIN" "$USER"
else
  log "Zsh já é o shell padrão."
fi

#--- 3. Oh My Zsh --------------------------------------------------------------
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  log "Instalando Oh My Zsh..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=no \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  log "Oh My Zsh já instalado."
fi

#--- 4. Tema Powerlevel10k -----------------------------------------------------
log "Instalando/atualizando tema Powerlevel10k..."
clone_or_update https://github.com/romkatv/powerlevel10k.git \
  "$ZSH_CUSTOM/themes/powerlevel10k"

#--- 5. Plugins ----------------------------------------------------------------
log "Instalando/atualizando plugins..."
clone_or_update https://github.com/zsh-users/zsh-autosuggestions      "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_or_update https://github.com/zsh-users/zsh-syntax-highlighting  "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
clone_or_update https://github.com/zsh-users/zsh-completions          "$ZSH_CUSTOM/plugins/zsh-completions"

#--- 6. Configuração do ~/.zshrc -----------------------------------------------
log "Aplicando configuração do ~/.zshrc..."
ZSHRC="$HOME/.zshrc"
[[ -f $ZSHRC ]] && cp "$ZSHRC" "$ZSHRC.bak.$(date +%Y%m%d-%H%M%S)"

sed -i 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$ZSHRC"
sed -i 's|^plugins=.*|plugins=(git docker docker-compose sudo command-not-found history zsh-autosuggestions zsh-syntax-highlighting zsh-completions)|' "$ZSHRC"

# Bloco de customizações idempotente (delimitado para futuras reexecuções)
BEGIN_TAG="# >>> custom-config >>>"
END_TAG="# <<< custom-config <<<"
sed -i "/$BEGIN_TAG/,/$END_TAG/d" "$ZSHRC"

cat >> "$ZSHRC" << EOF
$BEGIN_TAG
# History
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_FIND_NO_DUPS HIST_SAVE_NO_DUPS SHARE_HISTORY

# Aliases
alias ll='ls -lah --color=auto'
alias la='ls -A'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'

# Docker
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dcup='docker compose up -d'
alias dcdown='docker compose down'
alias dclogs='docker compose logs -f'

export EDITOR=nano
$END_TAG
EOF

#--- 7. Resumo -----------------------------------------------------------------
log "Concluído com sucesso."
cat <<EOF

  Shell padrão : $ZSH_BIN
  Tema         : powerlevel10k/powerlevel10k
  Plugins      : git, docker, docker-compose, sudo, command-not-found,
                 history, zsh-autosuggestions, zsh-syntax-highlighting,
                 zsh-completions
  Backup       : $ZSHRC.bak.*

  Dica: no terminal CLIENTE, instale uma Nerd Font (ex: MesloLGS NF) para os ícones.

EOF

#--- 8. Inicia o Zsh automaticamente -------------------------------------------
# Detecta se o script foi "sourced" (. ./setup-zsh.sh) ou executado (./setup-zsh.sh).
# Se sourced -> exec substitui o shell atual (transição transparente).
# Se executado -> usa exec zsh -l no processo do terminal pai via técnica padrão.
if (return 0 2>/dev/null); then
  log "Iniciando Zsh agora (substituindo shell atual)..."
  exec "$ZSH_BIN" -l
else
  log "Para ativar o novo shell agora, o script vai abrir o Zsh."
  warn "Ao sair do Zsh (Ctrl+D), você voltará ao shell antigo nesta sessão."
  warn "Em novos logins, o Zsh já será o padrão automaticamente."
  exec "$ZSH_BIN" -l
fi
