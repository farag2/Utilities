apt update && apt upgrade -y
# Install curl
apt install curl -y

# reboot

# Change pasword
passwd

# https://github.com/complexorganizations/wireguard-manager
# 9 to update script
# https://pc-01.tech/wireguard-vpn/
curl https://raw.githubusercontent.com/complexorganizations/wireguard-manager/main/wireguard-manager.sh --create-dirs -o /usr/local/bin/wireguard-manager.sh
chmod +x /usr/local/bin/wireguard-manager.sh
bash /usr/local/bin/wireguard-manager.sh

# /etc/wireguard/clients
