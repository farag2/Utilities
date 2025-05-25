# https://github.com/complexorganizations/wireguard-manager
apt update -y && apt upgrade -y
apt autoremove -y
apt --fix-broken install
apt --fix-missing install

# Upgrade
do-release-upgrade

# Install curl
apt install curl -y

# Change pasword
passwd

# /etc/wireguard/clients
# /var/backups
# /var/logs

# Disable ICMP ping response
# /etc/sysctl.conf
net.ipv4.icmp_echo_ignore_all = 1

# Enable BBR
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr

# Change SSH port
# /etc/ssh/sshd_config
# Should not be used in other cases
Port=port_number

# disable root account. Needed another user with sudo access level
PermitRootLogin=no
systemctl restart ssh

# Check Internet speed connection
wget -qO- bench.sh | bash

# https://github.com/XTLS/Xray-core
# https://github.com/MHSanaei/3x-ui
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)

# cron
# System jobs
/var/spool/cron/crontabs

# List cron jobs
sudo crontab -u root -l

# Reboots every Sunday at 00 am
# /etc/cron.d
0 0 * * 7 /sbin/reboot >> /home/user/cron.log
