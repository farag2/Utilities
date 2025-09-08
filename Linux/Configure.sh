apt update -y && apt full-upgrade -y && apt autoremove -y && apt autoclean -y
apt --fix-broken install
apt --fix-missing install

# Upgrade
do-release-upgrade

# Install curl
apt install curl -y

# Change pasword
passwd

# /var/backups
# /var/logs

# Disable ICMP ping response
# /etc/sysctl.conf
net.ipv4.icmp_echo_ignore_all = 1

# Enable BBR
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr

# Change SSH port
# Check if port number is not used in other cases
# Port=port_number
sudo nano /etc/ssh/sshd_config

# Disable port on firewall
ufw enable && ufw allow <portn_number>/tcp

# Disable root account. Needed another user with sudo access level
# Create a new account
sudo adduser <username>
# Add the user to the sudo group 
sudo usermod -aG sudo <username>
# Switch to new account
su <username>
sudo whoami
# Lock the root password
sudo passwd -l root

# Disable Root SSH Login
sudo nano /etc/ssh/sshd_config
PermitRootLogin=no
# Restart
sudo systemctl restart ssh

# Check Internet speed connection
wget -qO- bench.sh | bash

# https://github.com/XTLS/Xray-core
# https://github.com/MHSanaei/3x-ui
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)

# cron
# List cron jobs
sudo crontab -u root -l

# Edit crons
crontab -e
# Reboots every Sunday at 00 am
# Run the echo "Failed" command only if script fails
0 0 * * 7 NEEDRESTART_SUSPEND=1 apt update -y && apt full-upgrade -y && apt autoremove -y && apt autoclean -y && reboot && echo "$(date): Success" >> /home/cron.log || echo "$(date): Failed" >> /home/cron_fail.log

# System jobs
/var/spool/cron/crontabs

# Connect via SSH from PowerShell
& "$env:SystemRoot\System32\OpenSSH\ssh.exe" user@ip_address -p <port> -v
Remove-Item -Path "$env:USERPROFILE\.ssh" -Recurse -Force

# Download file from remote server
# -P <port> must be the first
& "$env:SystemRoot\System32\OpenSSH\sftp.exe" -P <port> user@ip_address:/home/file.txt D:\folder

# Upload file to remote server
& "$env:SystemRoot\System32\OpenSSH\scp.exe" P <port> "D:\folder\1.txt" user@ip_address:/home/<username>
#
& "$env:SystemRoot\System32\OpenSSH\sftp.exe" P <port> user@ip_address
put "D:\folder\1.txt" /home/<username>

# Authorize via SSH key

# sudo apt install openssh-server -y
# apt list --installed | grep openssh
# Create /home/<user>/.ssh folder
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Generate an SSH keys and save them to "$env:USERPROFILE\.ssh"
& "$env:SystemRoot\System32\OpenSSH\ssh-keygen.exe" -t ed25519
# Copy id_ed25519 to /home/<user>/.ssh folder
& "$env:SystemRoot\System32\OpenSSH\scp.exe" -P 6601 "$env:USERPROFILE\.ssh\id_ed25519.pub" user@ip_address:~/.ssh/authorized_keys

sudo nano /etc/ssh/sshd_config
PubkeyAuthentication yes
# Where SSH key to expect
AuthorizedKeysFile .ssh/authorized_keys
systemctl restart sshd
# Authorize on server
# id_ed25519 won't be accepted if it is placed in a public folder
& "$env:SystemRoot\System32\OpenSSH\ssh.exe" user@ip_address -p <port> -i "$env:USERPROFILE\.ssh\id_ed25519" -v

# Disable authorization via password
sudo nano /etc/ssh/sshd_config
PasswordAuthentication no
