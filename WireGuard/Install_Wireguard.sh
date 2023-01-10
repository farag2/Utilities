# https://github.com/complexorganizations/wireguard-manager
apt update && apt upgrade -y
apt autoremove -y

# Upgrade
do-release-upgrade

# Install curl
apt install curl -y

# Change pasword
passwd

# /etc/wireguard/clients
# /var/backups

# Disable ICMP ping response
/etc/sysctl.conf: net.ipv4.icmp_echo_ignore_all = 1
sysctl -p
