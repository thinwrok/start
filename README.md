<div align="center">
 
### **Thinwork** — Tecnologia • DevOps • Consultoria • Desenvolvimento
 
[![Site](https://img.shields.io/badge/🌐_Site-www.thinwork.com.br-0078D4?style=flat-square)](https://www.thinwork.com.br)
[![Email](https://img.shields.io/badge/📧_Contato-ti@thinwork.com.br-D44638?style=flat-square)](mailto:ti@thinwork.com.br)
[![Cloud](https://img.shields.io/badge/Cloud-Azure_|_AWS_|_OpenShift-FF9900?style=flat-square&logo=amazonaws&logoColor=white)](#)

### 🐧 Ubuntu 24 Server LTS — Terminal Toolkit

[![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04_LTS-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![License](https://img.shields.io/badge/License-Open_Source-3DA639?style=for-the-badge&logo=opensourceinitiative&logoColor=white)](https://opensource.org/)
[![DevOps](https://img.shields.io/badge/DevOps-Ready-2496ED?style=for-the-badge&logo=docker&logoColor=white)](#)
 
</div>

 
 ## ⚠️ Aviso Importante

 | 🔒 **Uso interno** | 🚫 **Sem hardening web** | 🤝 **Suporte disponível** |
 |:---:|:---:|:---:|
 | Destinado a **Servidor / VPS interno** | **Não aplica** regras de segurança para máquinas expostas à internet pública | Precisa de ajuda para montar seu ambiente? **[Entre em contato](mailto:ti@thinwork.com.br)** |

 Para ambientes **expostos à web**, é necessário aplicar hardening adicional: firewall (UFW/iptables), `fail2ban`, SSH com chaves, atualizações automáticas, monitoramento e auditoria. Consulte a Thinwork para projetos em **Azure**, **Red Hat OpenShift** e **AWS**.
 
 
## 📦 Pacotes 
 
### 🖥️ Ferramentas de sistema e administração
 
| Pacote | Ícone | Categoria | Descrição |
|---|:---:|---|---|
| `sudo` | 🔐 | Privilégios | Executa comandos como super‑usuário (`root`) com auditoria. |
| `nano` | ✏️ | Editor | Editor de texto simples, amigável para iniciantes. |
| `nano` | ✏️ | Editor | Editor de texto |
| `nano` | ✏️ | Editor | Editor de texto |
| `htop` | 📊 | Monitoramento | Visão interativa de processos, CPU, memória e swap. |
| `neofetch` | 🎯 | Info | Exibe informações do sistema com arte ASCII estilizada. |
| `mc` | 📂 | Arquivos | Midnight Commander — gerenciador de arquivos em modo texto (estilo Norton). |
| `mc` | 📂 | Arquivos |  |
| `tmux` | 🪟 | Sessões | Multiplexador de terminal: múltiplas sessões, janelas e splits persistentes. |
| `tar` | 🗜️ | Compactação | Empacota e compacta arquivos `.tar`, `.tar.gz`, `.tar.bz2`. |
| `zip` / `unzip` | 📦 | Compactação | Cria e extrai arquivos `.zip` (compatível com Windows). |
| `rpm` | 🎁 | Pacotes | Manipula pacotes `.rpm` (útil em ambientes híbridos RHEL/CentOS). |
| `git` | 🔀 | Versionamento | Controle de versão distribuído — base do GitHub/GitLab. |
| `jq` | 🧩 | JSON | Processador de JSON na linha de comando — essencial para APIs. |
| `dialog` | 🧱 | UI | Cria menus e interfaces TUI em scripts shell. |
| `cpu-checker` | ⚙️ | Hardware | Verifica suporte a virtualização (KVM/VT‑x/AMD‑V). |
 
### 🌐 Rede e conectividade
 
| Pacote | Ícone | Descrição |
|---|:---:|---|
| `curl` | 🔗 | Cliente HTTP/HTTPS/FTP — testa APIs, baixa arquivos e debug de requisições. |
| `wget` | ⬇️ | Download recursivo de arquivos e sites via HTTP/HTTPS/FTP. |
| `rsync` | 🔄 | Sincronização incremental e eficiente de arquivos local ↔ remoto. |
| `iputils-ping` | 🏓 | Comando `ping` — diagnóstico básico de conectividade ICMP. |
| `openssl` | 🔒 | Criptografia, geração de certificados SSL/TLS, hashes e chaves. |
 
### 🛡️ Segurança e utilitários do sistema
 
| Pacote | Ícone | Descrição |
|---|:---:|---|
| `apt-utils` | 🧰 | Utilitários extras do APT (`apt-extracttemplates`, `apt-sortpkgs`). |
| `apache2-utils` | 🌐 | Ferramentas HTTP: `ab` (benchmark), `htpasswd` (auth básica), `htdigest`. |
 
---
 
## 💻 Instalação
 
### Pré‑requisitos
 
```bash
# Atualize a lista de pacotes e o sistema antes de instalar
sudo apt update && sudo apt upgrade -y
```
 
### Método 1 — Instalação manual *(recomendado para aprender)*
 
```bash
# 🔧 Pacotes principais (sistema, rede, dev, automação)
sudo apt install -y \
  sudo curl wget nano htop mc tar rpm zip unzip git jq dialog \
  openssl tmux rsync iputils-ping cpu-checker neofetch
 
# 🛡️ Utilitários extras de segurança e sistema
sudo apt install -y apt-utils apache2-utils
```
 
> 💡 **Dica:** o pacote `sudo` já costuma vir instalado por padrão no Ubuntu Server — o comando acima apenas garante sua presença.
 
### Método 2 — Script automatizado Thinwork *(rápido)*
 
```bash
curl -fsSL https://thinwork.com.br/dev/ubuntu.sh | sudo bash
```
 
> ⚠️ **Boa prática de segurança:** antes de executar `curl | bash`, **inspecione o conteúdo do script**:
> ```bash
> curl -fsSL https://thinwork.com.br/dev/ubuntu.sh -o ubuntu.sh
> less ubuntu.sh        # revisar
> sudo bash ubuntu.sh   # executar após validar
> ```
 
---
 
## ✅ Verificação pós‑instalação
 
Após a instalação, valide o ambiente com os comandos abaixo:
 
```bash
# Versões das principais ferramentas
git --version && curl --version | head -1 && jq --version
 
# Estilo: mostra info do sistema
neofetch
 
# Monitoramento em tempo real
htop
 
# Verifica suporte a virtualização (útil para Docker/KVM)
sudo kvm-ok
```
 
**Saída esperada (exemplo):**
 
```text
git version 2.43.0
curl 8.5.0 (x86_64-pc-linux-gnu) ...
jq-1.7
INFO: /dev/kvm exists
KVM acceleration can be used
```

---
 

## 📞 Suporte
 
| Canal | Contato |
|---|---|
| 🌐 **Site** | [www.thinwork.com.br](https://www.thinwork.com.br) |
| 📧 **E‑mail** | [ti@thinwork.com.br](mailto:ti@thinwork.com.br) |
| 🛠️ **Serviços** | DevOps • Consultoria • Desenvolvimento • Cloud |
| ☁️ **Plataformas** | Azure • AWS • Red Hat OpenShift |
 
---
 
<div align="center">
*Made with ❤️ by **Thinwork** — Tecnologia que conecta.*
 
</div>
 
