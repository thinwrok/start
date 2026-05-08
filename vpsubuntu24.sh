#!/usr/bin/env bash
# =================================================================================================
# Thinwork - ti@thinwork.com.br - Devops - Tecnologia - Consultoria - Desenvolvimento
#
# Ubuntu 24.XX - Provisionamento inicial de servidor Ubuntu 24 - ( Junior / Lucas  )
# Compatível:   Ubuntu 24.04 LTS (Noble Numbat)
# 
# curl -fsSL https://raw.githubusercontent.com/thinwrok/start/main/vpsubuntu24.sh | sudo bash
# wget -qO-  https://raw.githubusercontent.com/thinwrok/start/main/vpsubuntu24.sh| sudo bash
# curl -fsSL https://thinwork.com.br/dev/vpsubuntu24.sh | sudo bash
#
#       +---------------------------------------------------------------+
#       | Procedimento Apos Install ISO padrao - Ubuntu 24 Server LTS   |
#       +---------------------------------------------------------------+
#
#                    ** Uso em ( Servidor / VPS ) Interno **
#              Sem regras de segurança para máquinas expostas à web 
# ==================================================================================================
set -Eeuo pipefail
IFS=$'\n\t'

#-------------------------------------------------------------------------------
# Variáveis globais
#-------------------------------------------------------------------------------
readonly SCRIPT_NAME="$(basename "$0")"
readonly LOG_FILE="/var/log/${SCRIPT_NAME%.sh}.log"
readonly TZ_REGION="America/Sao_Paulo"
readonly LOCALE_BR="pt_BR.UTF-8"

export ACCEPT_EULA=Y
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
export LC_ALL=C.UTF-8

#-------------------------------------------------------------------------------
# Funções utilitárias
#-------------------------------------------------------------------------------
log()   { printf '\e[1;34m[INFO]\e[0m  %s\n' "$*" | tee -a "$LOG_FILE"; }
warn()  { printf '\e[1;33m[WARN]\e[0m  %s\n' "$*" | tee -a "$LOG_FILE" >&2; }
error() { printf '\e[1;31m[ERRO]\e[0m  %s\n' "$*" | tee -a "$LOG_FILE" >&2; }

trap 'error "Falha na linha $LINENO (exit $?)"; exit 1' ERR

require_root() {
    if [[ $EUID -ne 0 ]]; then
        error "Este script precisa ser executado como root (use sudo)."
        exit 1
    fi
}

check_ubuntu() {
    if ! grep -qi 'ubuntu' /etc/os-release; then
        error "Distribuição não suportada. Requer Ubuntu 24.04."
        exit 1
    fi
}

#-------------------------------------------------------------------------------
# Etapas de configuração
#-------------------------------------------------------------------------------
update_system() {
    log "Atualizando índices e pacotes do sistema..."
    apt-get update -qq
    apt-get -y -o Dpkg::Options::="--force-confdef" \
                -o Dpkg::Options::="--force-confold" upgrade
    apt-get -y autoremove --purge
    apt-get -y autoclean
}

install_packages() {
    log "Instalando pacotes essenciais..."

    # Utilitários básicos de sistema e rede
    local -a base_pkgs=(
        ca-certificates curl wget gnupg lsb-release apt-transport-https
        sudo nano git tar zip unzip rsync rclone dos2unix jq openssl
        iputils-ping tcpdump
    )

    # Shells e produtividade
    local -a shell_pkgs=(
        bash-completion fish zsh tmux
    )

    # Monitoramento e diagnóstico
    local -a monitor_pkgs=(
        htop btop glances ncdu mc neofetch screenfetch
        cpu-checker bc apache2-utils swaks
    )

    # Bibliotecas de desenvolvimento (para compilação de módulos C/C++)
    local -a dev_pkgs=(
        bison flex swig python3-dev
        libevent-dev libexpat1-dev libhiredis-dev libnghttp2-dev
        libprotobuf-c-dev libssl-dev libsystemd-dev protobuf-c-compiler
    )

    # Ferramentas de virtualização/imagem
    local -a virt_pkgs=(
        libguestfs-tools
    )

    apt-get install -y --no-install-recommends \
        "${base_pkgs[@]}" \
        "${shell_pkgs[@]}" \
        "${monitor_pkgs[@]}" \
        "${dev_pkgs[@]}" \
        "${virt_pkgs[@]}"
}

configure_locale() {
    log "Configurando locale para ${LOCALE_BR}..."
    if ! locale -a | grep -qi "^${LOCALE_BR//-/}$\|^pt_BR.utf8$"; then
        locale-gen "$LOCALE_BR"
    fi
    update-locale LANG="$LOCALE_BR" LC_ALL="$LOCALE_BR" LANGUAGE="pt_BR:pt:en"
}

configure_timezone() {
    log "Configurando timezone para ${TZ_REGION}..."
    timedatectl set-timezone "$TZ_REGION"

    # Garante variáveis de ambiente persistentes para PHP e shells
    local env_file="/etc/environment"
    grep -q "^TZ=" "$env_file"     || echo "TZ=${TZ_REGION}"     >> "$env_file"
    grep -q "^PHP_TZ=" "$env_file" || echo "PHP_TZ=${TZ_REGION}" >> "$env_file"
}

disable_selinux() {
    # No Ubuntu o SELinux normalmente nem está instalado; criamos o arquivo
    # apenas se o diretório existir, evitando ruído.
    if [[ -d /etc/selinux ]]; then
        log "Desabilitando SELinux (se aplicável)..."
        echo "SELINUX=disabled" > /etc/selinux/config
    fi
}

check_hostname_fqdn() {
    local hn fqdn
    hn=$(hostname)
    fqdn=$(hostname -f 2>/dev/null || echo "$hn")
    log "Hostname: $hn / FQDN: $fqdn"
    if [[ "$fqdn" != *.*.* ]] && [[ "$fqdn" != *.* ]]; then
        warn "Hostname não parece um FQDN (ex: mail.seudominio.com.br)."
        warn "Configure /etc/hostname e /etc/hosts antes de adicionar domínio no Mail Server."
    fi
}

configure_bash_prompt() {
    local target_user="${SUDO_USER:-root}"
    local user_home
    user_home="$(getent passwd "$target_user" | cut -d: -f6)"
    local bashrc="${user_home}/.bashrc"

    log "Personalizando prompt e aliases para ${target_user}..."

    # Bloco delimitado por marcadores → idempotente, fácil remover/atualizar
    local marker_begin="# >>> setup-ubuntu BEGIN >>>"
    local marker_end="# <<< setup-ubuntu END <<<"

    if ! grep -qF "$marker_begin" "$bashrc" 2>/dev/null; then
        cat >> "$bashrc" <<EOF

${marker_begin}
# Prompt customizado (host @ user cwd \$)
export PS1='\[\e[1;32m\]\h \[\e[1;31m\]@ \u \[\e[1;34m\]\w \[\e[1;31m\]\$ \[\e[0;37m\]'

# Aliases úteis
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias grep='grep --color=auto'
${marker_end}
EOF
        chown "${target_user}:${target_user}" "$bashrc"
    else
        log "Bloco de personalização já presente em ${bashrc}; pulando."
    fi
}

show_summary() {
    log "----------------------------------------------------------------"
    log "Provisionamento concluído com sucesso."
    log "Locale  : $(locale | grep '^LANG=' | cut -d= -f2)"
    log "Timezone: $(timedatectl show -p Timezone --value)"
    log "Kernel  : $(uname -r)"
    log "Log     : ${LOG_FILE}"
    log "----------------------------------------------------------------"
}

#-------------------------------------------------------------------------------
# Execução
#-------------------------------------------------------------------------------
main() {
    require_root
    check_ubuntu

    : > "$LOG_FILE"
    log "Iniciando provisionamento em $(date '+%F %T')"

    update_system
    install_packages
    configure_locale
    configure_timezone
    disable_selinux
    check_hostname_fqdn
    configure_bash_prompt

    show_summary
}

main "$@"
