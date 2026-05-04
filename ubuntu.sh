# =================================================================================================
# Thinwork - ti@thinwork.com.br - Devops - Tecnologia - Consultoria - Desenvolvimento
#
# Ubuntu 24.XX - Desenvolvimento - DevTools - Docker - easypanel - util - ( Junior / Davi / Carlos )
#
# curl -fsSL https://raw.githubusercontent.com/thinwrok/start/main/ubuntu.sh | sudo bash
# wget -qO-  https://raw.githubusercontent.com/thinwrok/start/main/ubuntu.sh | sudo bash
# curl -fsSL https://thinwork.com.br/dev/ubuntu.sh | sudo bash
#
#       +---------------------------------------------------------------+
#       | Procedimento Apos Install ISO padrao - Ubuntu 24 Server LTS   |
#       +---------------------------------------------------------------+
#
#                    ** Uso em ( Servidor / VPS ) Interno **
#              Sem regras de segurança para máquinas expostas à web 
# ==================================================================================================

# Recursos
sudo apt update && sudo apt upgrade -y
sudo apt install -y sudo curl wget nano htop mc tar rpm zip unzip git jq dialog openssl tmux fish rsync iputils-ping cpu-checker neofetch tilde lfm glances tcpdump wireshark 
sudo apt install -y apt-utils
sudo apt install -y apache2-utils
# sudo apt install -y python3
# sudo apt install -y golang-go
# sudo apt install -y nodejs


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


# FireWall - Basico ( Padrao ) 
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 3000/tcp
sudo ufw allow 8080/tcp

# FireWall - Conforme painel ou necessidade 
# sudo ufw allow 21/tcp
# sudo ufw allow 5000/tcp
# sudo ufw allow 8000/tcp
# sudo ufw allow 9000/tcp
# sudo ufw allow 9090/tcp


# Complementos
#
# ** easypanel
# Install -- [ curl -sSL https://get.easypanel.io | sudo sh ]
# Remove  -- [ sudo docker service rm easypanel traefik && sudo docker swarm leave --force && sudo docker system prune -a -f --volumes && sudo rm -rf /etc/easypanel ]
#
# ** ajenti
# curl https://raw.githubusercontent.com/ajenti/ajenti/master/scripts/install.sh | sudo bash -s -
# 
# ** 1panel
# bash -c "$(curl -sSL https://resource.1panel.pro/v2/quick_start.sh)"
#

# curl -fsSL https://cdn.coollabs.io/coolify/install.sh | sudo bash
# curl -sSL https://dokploy.com/install.sh | sudo sh
# curl -fsSL https://get.casaos.io/update | sudo bash
# curl -sSL setup.oriondesign.art.br | sudo sh
# URL=https://www.aapanel.com/script/install_panel_en.sh && if [ -f /usr/bin/curl ];then curl -ksSO $URL ;else wget --no-check-certificate -O install_panel_en.sh $URL;fi;bash install_panel_en.sh ipssl
# curl https://crontab.guru/install | sh   --- https://crontab.guru/dashboard.html

# Uninstall shelhost Feitos em docker 
# sudo docker stop $(sudo docker ps -aq) && sudo docker rm -f $( sudo docker ps -aq)  && sudo docker container prune --force && sudo docker image prune --all --force && sudo docker volume prune --all --force && sudo docker system prune --all --volumes --force



