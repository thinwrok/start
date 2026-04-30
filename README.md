# 🐧 Ubuntu 24 Server LTS – Terminal Toolkit

Ambiente de servidor Ubuntu 24.04 LTS (Noble Numbat) preparado para uso avançado em modo terminal, com pacotes úteis para administração de sistemas, rede, automação e segurança.

---

## 🏷️ Informações do ambiente

- **Sistema operacional**: Ubuntu 24.04 LTS Server (sem desktop)  
- **Gerenciador de pacotes**: `apt`  
- **Foco**: uso em modo terminal, servidor, homelab ou DevOps simples  
- **Licença**: Free and open source (pacotes padrão Ubuntu)

---

## 📦 Pacotes instalados

Abaixo estão os pacotes instalados com o comando `sudo apt install` no terminal.

### 🖥️ Ferramentas de sistema e administração

| Pacote                | Ícone    | Descrição breve |
|-----------------------|----------|-----------------|
| `sudo`                | 🔐       | Executa comandos como super‑usuário (`root`). |
| `curl`                | 🔗       | Faz requisições HTTP/HTTPS via terminal. |
| `wget`                | ⬇️       | Baixa arquivos da web por linha de comando. |
| `nano`                | ✏️       | Editor de texto simples e amigável. |
| `htop`                | 📊       | Visão interativa dos processos e uso de CPU/memória. |
| `mc`                  | 📂       | Midnight Commander – gerenciador de arquivos em modo texto. |
| `tar`                 | 🗜️       | Compacta/descompacta arquivos TAR usados em backups e pacotes. |
| `rpm`                 | 📦       | Trabalha com pacotes RPM (ambientes híbridos Linux). |
| `zip` / `unzip`       | 🗜️       | Cria e extrai arquivos ZIP. |
| `git`                 | 🔁       | Controle de versão distribuído. |
| `jq`                  | 🧩       | Processa JSON na linha de comando. |
| `dialog`              | 🧱       | Cria menus e interfaces simples em modo texto. |
| `openssl`             | 🔒       | Ferramentas de criptografia e certificados SSL/TLS. |
| `tmux`                | 🖥️       | Multiplexador de terminal (sessões, janelas, splits). |
| `bc`                  | 🧮       | Calculadora em precisão arbitrária. |
| `rsync`               | 🔄       | Sincroniza arquivos e pastas de forma eficiente. |
| `iputils-ping`        | 🌐       | Comando `ping` para testar conectividade de rede. |
| `cpu-checker`         | ⚙️       | Verifica suporte a virtualização (KVM, etc.). |
| `neofetch`            | 🎯       | Mostra informações do sistema com estilo. |

### 🛡️ Segurança e utilitários do sistema

| Pacote              | Ícone    | Descrição breve |
|---------------------|----------|-----------------|
| `apparmor-utils`    | 🛡️       | Ferramentas para gerenciar perfis AppArmor. |
| `apt-utils`         | 🧩       | Utilitários extra para melhorar o uso do `apt`. |
| `apache2-utils`     | 🌐       | Ferramentas úteis para testar servidores HTTP (ex.: `ab`, `htpasswd`). |

---

## 💻 Comandos de instalação

Para replicar esse ambiente em outro Ubuntu 24 Server LTS, execute:

```bash
sudo apt update

# Pacotes principais
sudo apt install -y \
  sudo curl wget nano htop mc tar rpm zip unzip git jq dialog \
  openssl tmux fish bc rsync iputils-ping cpu-checker \
  neofetch screenfetch

# Utilitários de segurança e sistema
sudo apt install -y apparmor-utils
sudo apt install -y apt-utils
sudo apt install -y apache2-utils
```

---

