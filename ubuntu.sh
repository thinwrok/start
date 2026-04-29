# ======================================================================================
# Ubuntu 24.XX - Desenvolvimento - DevTools - Docker - easypanel - ( Junior / Davi )
# curl -fsSL https://raw.githubusercontent.com/thinwrok/start/main/ubuntu.sh | sudo bash
# wget -qO-  https://raw.githubusercontent.com/thinwrok/start/main/ubuntu.sh | sudo bash
# ======================================================================================

# Recursos
sudo apt update && sudo apt upgrade -y
sudo apt install -y sudo curl wget nano htop mc tar rpm zip unzip git jq dialog openssl tmux fish bc rsync rclone iputils-ping cpu-checker neofetch screenfetch 
sudo apt install -y apparmor-utils
sudo apt install -y apt-utils 
sudo apt install -y apache2-utils     

# Ambiente Lang
ACCEPT_EULA=Y
DEBIAN_FRONTEND=noninteractive
LC_ALL=C.UTF-8
TZ=America/Sao_Paulo
PHP_TZ=America/Sao_Paulo
sudo locale-gen pt_BR.UTF-8
sudo localectl set-locale LANG=pt_BR.UTF-8
sudo update-locale LANG=pt_BR.UTF-8 LC_ALL=pt_BR.UTF-8 LANGUAGE="pt_BR:pt:en"
sudo timedatectl set-timezone "America/Sao_Paulo"
sudo ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
echo "SELINUX=disabled" > /etc/selinux/config
echo "PS1='\[\e[1;32m\]\h \[\e[1;31m\]@ \u \[\e[1;34m\]\w \[\e[1;31m\]\$ \[\e[0;37m\]'" >> ~/.bashrc
echo "alias ls='ls --color=auto'" >> ~/.bashrc

# Habiliar o root fazer login  
sudo passwd root
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo systemctl restart ssh