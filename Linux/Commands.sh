# ISPmanager
Name: domain
Type: A
Value: <VPS IP>
TTL: 3600

apt update -y && apt full-upgrade -y && apt autoremove -y && apt autoclean -y
apt --fix-broken install
apt --fix-missing install

# Upgrade
apt-get dist-upgrade
do-release-upgrade

# Change pasword
passwd

# /var/backups
# /var/logs

# Configure sysctl.conf
sudo nano /etc/sysctl.conf
# Disable ICMP ping response
net.ipv4.icmp_echo_ignore_all = 1
# Enable BBR
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr

# Change SSH port
# Check if port number is not used in other cases
# systemctl status ssh.socket
# ss -tlnp | grep :22
# Port=port_number
sudo nano /etc/ssh/sshd_config
# Disable Root SSH Login
PermitRootLogin=no
# Disable authorization via password
# Set only if you configured authentication via ssh key
# ls /etc/ssh/sshd_config.d
sudo nano /etc/ssh/sshd_config.d/*.conf
sudo nano /etc/ssh/sshd_config
PasswordAuthentication no
PubkeyAuthentication yes
# Where SSH key to expect
AuthorizedKeysFile .ssh/authorized_keys
#
sudo systemctl daemon-reload
sudo systemctl restart ssh.socket
sudo systemctl restart sshd

# DNS-over-TLS
sudo nano /etc/systemd/resolved.conf
# resolvectl status
# resolvectl dns
DNS=1.1.1.1 8.8.8.8
FallbackDNS=9.9.9.9
DNSOverTLS=yes
sudo systemctl restart systemd-resolved

# Disable port on firewall
# ss -ntpl
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

# cron
# List cron jobs
# sudo crontab -u <user> -l
sudo crontab -l

# Edit crons
# sudo nano crontab -u <user> -e
sudo nano crontab -e
# Reboots every Sunday at 00 am
# Run the echo "Failed" command only if script fails
0 0 * * 7 NEEDRESTART_SUSPEND=1 apt update -y && apt full-upgrade -y && apt autoremove -y && apt autoclean -y && reboot && echo "$(date): Success" >> /home/cron.log || echo "$(date): Failed" >> /home/cron_fail.log

# System jobs
/var/spool/cron/crontabs

# Connect via SSH from PowerShell
& "$env:SystemRoot\System32\OpenSSH\ssh.exe" user@ip_address -p <port> -v

# Download file from remote server
# -P <port> must be the first
# get /home/cron.log D:\Downloads\cron.log
& "$env:SystemRoot\System32\OpenSSH\sftp.exe" -P <port> user@ip_address:/home/file.txt D:\folder

# Upload file to remote server
& "$env:SystemRoot\System32\OpenSSH\scp.exe" -P <port> "D:\folder\1.txt" user@ip_address:/home/<username>
#
& "$env:SystemRoot\System32\OpenSSH\sftp.exe" -P <port> user@ip_address
put "D:\folder\1.txt" /home/<username>

# Authorize via SSH key
# sudo apt install openssh-server -y
# apt list --installed | grep openssh
# Create /home/<user>/.ssh folder
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Generate an SSH keys and save them to "$env:USERPROFILE\.ssh"
& "$env:SystemRoot\System32\OpenSSH\ssh-keygen.exe" -t ed25519 -f "friendly-name"
# Copy id_ed25519 to /home/<user>/.ssh folder
& "$env:SystemRoot\System32\OpenSSH\scp.exe" -P 6601 "$env:USERPROFILE\.ssh\<friendlyname>.pub" user@ip_address:~/.ssh/authorized_keys
# List folders on server
ls .ssh

# Configure ssh-agent service
Set-Service -Name ssh-agent -StartupType Automatic
Start-Service -Name ssh-agent
& "$env:SystemRoot\System32\OpenSSH\ssh-add.exe" $env:USERPROFILE\.ssh\<ssh-file-without-pub-ext>

# id_ed25519 won't be accepted if it is placed in a public folder
& "$env:SystemRoot\System32\OpenSSH\ssh.exe" user@ip_address -p <port> -i "$env:USERPROFILE\.ssh\<ssh-file-without-pub-ext>" -v
