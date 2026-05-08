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

#!/usr/bin/env bash
#===============================================================================
# Nome:         setup-ubuntu-aapanel.sh
# Descrição:    Provisionamento de VPS Ubuntu 24.04 LTS para receber:
#                 - aaPanel (painel de hospedagem)
#                 - Mail Server (Postfix + Dovecot + rspamd) via aaPanel
#               Faz hardening básico, locale pt_BR, timezone São Paulo,
#               instala utilitários, libera portas no UFW e remove
#               conflitos conhecidos (Apache/Nginx/PHP/MySQL/Postfix nativos).
# Compatível:   Ubuntu 24.04 LTS (Noble Numbat)
# Uso:          sudo ./setup-ubuntu-aapanel.sh [--install-aapanel]
#===============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

#-------------------------------------------------------------------------------
# Variáveis globais
#-------------------------------------------------------------------------------
readonly SCRIPT_NAME="$(basename "$0")"
readonly LOG_FILE="/var/log/${SCRIPT_NAME%.sh}.log"
readonly TZ_REGION="America/Sao_Paulo"
readonly LOCALE_BR="pt_BR.UTF-8"
readonly AAPANEL_INSTALL_URL="https://www.aapanel.com/script/install_panel_en.sh"

INSTALL_AAPANEL=false
[[ "${1:-}" == "--install-aapanel" ]] && INSTALL_AAPANEL=true

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
        error "Execute como root (sudo $SCRIPT_NAME)."
        exit 1
    fi
}

check_ubuntu() {
    if ! grep -qi 'ubuntu' /etc/os-release; then
        error "Distribuição não suportada. Requer Ubuntu 24.04."
        exit 1
    fi
    local version
    version="$(lsb_release -rs 2>/dev/null || echo '')"
    if [[ "$version" != "24.04" ]]; then
        warn "Recomendado Ubuntu 24.04. Detectado: ${version:-desconhecido}."
    fi
}

check_resources() {
    local mem_mb disk_gb
    mem_mb=$(awk '/MemTotal/ {printf "%d", $2/1024}' /proc/meminfo)
    disk_gb=$(df -BG --output=avail / | tail -1 | tr -dc '0-9')

    log "Recursos: ${mem_mb} MB RAM, ${disk_gb} GB livres em /"
    [[ $mem_mb -lt 1024 ]] && warn "RAM < 1GB. Mail Server (rspamd) pode ficar pesado."
    [[ $disk_gb -lt 10 ]]  && warn "Disco < 10GB. aaPanel + mail exige espaço."
}

#-------------------------------------------------------------------------------
# Etapa 1 — Sistema base
#-------------------------------------------------------------------------------
update_system() {
    log "Atualizando índices e pacotes..."
    apt-get update -qq
    apt-get -y -o Dpkg::Options::="--force-confdef" \
                -o Dpkg::Options::="--force-confold" upgrade
    apt-get -y autoremove --purge
    apt-get -y autoclean
}

remove_conflicts() {
    # aaPanel exige sistema limpo; remove web/db/mail pré-instalados que
    # venham na imagem da VPS e podem travar a instalação do painel.
    log "Removendo serviços conflitantes (Apache/Nginx/PHP/MySQL/Postfix nativos)..."
    local -a conflicts=(
        apache2 apache2-bin apache2-data
        nginx nginx-core nginx-common
        mysql-server mariadb-server
        php php-cli php-fpm
        postfix exim4 exim4-base sendmail
        dovecot-core dovecot-imapd dovecot-pop3d
    )
    for pkg in "${conflicts[@]}"; do
        if dpkg -l | awk '{print $2}' | grep -qx "$pkg"; then
            log "  → removendo $pkg"
            systemctl stop "$pkg" 2>/dev/null || true
            systemctl disable "$pkg" 2>/dev/null || true
            apt-get -y purge "$pkg" || true
        fi
    done
    apt-get -y autoremove --purge
}

install_packages() {
    log "Instalando pacotes essenciais..."

    local -a base_pkgs=(
        ca-certificates curl wget gnupg lsb-release apt-transport-https
        sudo nano git tar zip unzip rsync rclone dos2unix jq openssl
        iputils-ping tcpdump dnsutils net-tools telnet
    )
    local -a shell_pkgs=(
        bash-completion fish zsh tmux
    )
    local -a monitor_pkgs=(
        htop btop glances ncdu mc neofetch screenfetch
        cpu-checker bc apache2-utils swaks
    )
    local -a dev_pkgs=(
        bison flex swig python3-dev
        libevent-dev libexpat1-dev libhiredis-dev libnghttp2-dev
        libprotobuf-c-dev libssl-dev libsystemd-dev protobuf-c-compiler
    )
    local -a virt_pkgs=(
        libguestfs-tools
    )
    # Específico para aaPanel + Mail Server: pré-requisitos confortáveis
    local -a aapanel_pkgs=(
        ufw fail2ban unattended-upgrades
        cron logrotate
    )

    apt-get install -y --no-install-recommends \
        "${base_pkgs[@]}" \
        "${shell_pkgs[@]}" \
        "${monitor_pkgs[@]}" \
        "${dev_pkgs[@]}" \
        "${virt_pkgs[@]}" \
        "${aapanel_pkgs[@]}"
}

#-------------------------------------------------------------------------------
# Etapa 2 — Locale, timezone, kernel
#-------------------------------------------------------------------------------
configure_locale() {
    log "Configurando locale ${LOCALE_BR}..."
    if ! locale -a 2>/dev/null | grep -qi 'pt_BR.utf8'; then
        locale-gen "$LOCALE_BR"
    fi
    update-locale LANG="$LOCALE_BR" LC_ALL="$LOCALE_BR" LANGUAGE="pt_BR:pt:en"
}

configure_timezone() {
    log "Configurando timezone ${TZ_REGION}..."
    timedatectl set-timezone "$TZ_REGION"
    local env_file="/etc/environment"
    grep -q "^TZ=" "$env_file"     || echo "TZ=${TZ_REGION}"     >> "$env_file"
    grep -q "^PHP_TZ=" "$env_file" || echo "PHP_TZ=${TZ_REGION}" >> "$env_file"
}

configure_kernel() {
    # Ajustes recomendados para servidor web + mail
    log "Aplicando tuning de kernel para servidor web/mail..."
    local sysctl_file="/etc/sysctl.d/99-aapanel-tuning.conf"
    cat > "$sysctl_file" <<'EOF'
# === Rede ===
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 16384
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65535

# === Segurança ===
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1

# === Memória / arquivos abertos ===
fs.file-max = 2097152
vm.swappiness = 10
EOF
    sysctl --system >/dev/null
}

configure_limits() {
    log "Aumentando limites de descritores de arquivo..."
    local limits_file="/etc/security/limits.d/99-aapanel.conf"
    cat > "$limits_file" <<'EOF'
*       soft    nofile  65535
*       hard    nofile  65535
root    soft    nofile  65535
root    hard    nofile  65535
EOF
}

disable_selinux() {
    if [[ -d /etc/selinux ]]; then
        log "Desabilitando SELinux (se aplicável)..."
        echo "SELINUX=disabled" > /etc/selinux/config
    fi
}

#-------------------------------------------------------------------------------
# Etapa 3 — Firewall (UFW) com portas aaPanel + Mail Server
#-------------------------------------------------------------------------------
configure_firewall() {
    log "Configurando UFW para aaPanel + Mail Server..."

    # Política padrão
    ufw --force reset >/dev/null
    ufw default deny incoming
    ufw default allow outgoing

    # SSH (essencial — evita lock-out)
    ufw allow 22/tcp comment 'SSH'

    # Web (aaPanel publica sites)
    ufw allow 80/tcp  comment 'HTTP'
    ufw allow 443/tcp comment 'HTTPS'

    # Painel aaPanel (porta padrão; pode ser alterada na instalação)
    ufw allow 8888/tcp comment 'aaPanel'
    ufw allow 39000:40000/tcp comment 'FTP passivo'
    ufw allow 21/tcp  comment 'FTP'

    # Mail Server — Postfix
    ufw allow 25/tcp  comment 'SMTP'
    ufw allow 465/tcp comment 'SMTPS'
    ufw allow 587/tcp comment 'Submission'

    # Mail Server — Dovecot (IMAP/POP3 + TLS)
    ufw allow 110/tcp comment 'POP3'
    ufw allow 995/tcp comment 'POP3S'
    ufw allow 143/tcp comment 'IMAP'
    ufw allow 993/tcp comment 'IMAPS'

    ufw logging low
    ufw --force enable

    log "UFW ativo. Regras:"
    ufw status numbered | tee -a "$LOG_FILE"
}

#-------------------------------------------------------------------------------
# Etapa 4 — Verificações pré-Mail Server
#-------------------------------------------------------------------------------
check_port_25_outbound() {
    # Muitos provedores (GCP, AWS, Oracle, Azure) bloqueiam saída na 25.
    # Sem isso, o Mail Server NÃO envia para o mundo externo.
    log "Testando saída na porta 25 (necessária para envio de e-mails)..."
    if timeout 5 bash -c 'cat < /dev/tcp/smtp.gmail.com/25' &>/dev/null; then
        log "  ✓ Porta 25 outbound LIBERADA."
    else
        warn "  ✗ Porta 25 outbound BLOQUEADA pelo provedor."
        warn "    Solicite o desbloqueio no painel da VPS antes de configurar e-mail."
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

#-------------------------------------------------------------------------------
# Etapa 5 — Personalização de shell
#-------------------------------------------------------------------------------
configure_bash_prompt() {
    local target_user="${SUDO_USER:-root}"
    local user_home
    user_home="$(getent passwd "$target_user" | cut -d: -f6)"
    local bashrc="${user_home}/.bashrc"
    local marker_begin="# >>> setup-ubuntu BEGIN >>>"
    local marker_end="# <<< setup-ubuntu END <<<"

    log "Personalizando .bashrc de ${target_user}..."

    if ! grep -qF "$marker_begin" "$bashrc" 2>/dev/null; then
        cat >> "$bashrc" <<EOF

${marker_begin}
export PS1='\[\e[1;32m\]\h \[\e[1;31m\]@ \u \[\e[1;34m\]\w \[\e[1;31m\]\$ \[\e[0;37m\]'
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias grep='grep --color=auto'
alias bt='bt'   # comando do aaPanel (disponível após instalação)
${marker_end}
EOF
        chown "${target_user}:${target_user}" "$bashrc"
    else
        log "Bloco já presente em ${bashrc}; pulando."
    fi
}

#-------------------------------------------------------------------------------
# Etapa 6 — Instalação opcional do aaPanel
#-------------------------------------------------------------------------------
install_aapanel() {
    log "Iniciando instalação do aaPanel..."
    log "Será baixado o instalador oficial: ${AAPANEL_INSTALL_URL}"
    cd /tmp
    curl -fsSLO "$AAPANEL_INSTALL_URL"
    bash install_panel_en.sh aapanel
}

#-------------------------------------------------------------------------------
# Sumário
#-------------------------------------------------------------------------------
show_summary() {
    log "================================================================"
    log " Provisionamento concluído"
    log "================================================================"
    log " Locale  : $(locale | grep '^LANG=' | cut -d= -f2)"
    log " Timezone: $(timedatectl show -p Timezone --value)"
    log " Kernel  : $(uname -r)"
    log " RAM     : $(free -h | awk '/Mem:/ {print $2}')"
    log " IP      : $(hostname -I | awk '{print $1}')"
    log " Log     : ${LOG_FILE}"
    log "----------------------------------------------------------------"
    log " PRÓXIMOS PASSOS:"
    if ! $INSTALL_AAPANEL; then
        log "  1. Instale o aaPanel:"
        log "     curl -ksSO ${AAPANEL_INSTALL_URL} && bash install_panel_en.sh aapanel"
    fi
    log "  2. Acesse o painel pela URL/usuário/senha exibidos no fim da instalação."
    log "  3. Em App Store: instale Linux Tools, Redis, Mail Server."
    log "  4. Configure DNS (A, MX, SPF, DKIM, DMARC, PTR) do domínio de e-mail."
    log "  5. Confirme com seu provedor que a porta 25 (saída) está liberada."
    log "================================================================"
}

#-------------------------------------------------------------------------------
# Execução
#-------------------------------------------------------------------------------
main() {
    require_root
    check_ubuntu
    check_resources

    : > "$LOG_FILE"
    log "Iniciando provisionamento em $(date '+%F %T')"

    update_system
    remove_conflicts
    install_packages
    configure_locale
    configure_timezone
    configure_kernel
    configure_limits
    disable_selinux
    check_hostname_fqdn
    configure_bash_prompt

    if $INSTALL_AAPANEL; then
        install_aapanel
    fi

    show_summary
}

main "$@"
