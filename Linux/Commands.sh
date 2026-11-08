# ISPmanager
Name: domain
Type: A
Value: <VPS IP>
TTL: 3600

# Regular update
sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y
# Fix broken dependencies or interrupted installs
sudo apt --fix-broken install
# Upgrade but skip packages that cannot be downloaded
sudo apt-get upgrade --fix-missing

# Upgrade
apt-get dist-upgrade
do-release-upgrade

# Change password
passwd

# /var/backups
# /var/log

# Create a sudo user
sudo adduser <username>
# Add the user to the sudo group
sudo usermod -aG sudo <username>
# Switch to new account
su <username>
sudo whoami

# Configure sysctl
# sysctl reads the last file, so we create file with 99 in its name
sudo nano /etc/sysctl.d/99-custom.conf
# Disable ICMP ping response
net.ipv4.icmp_echo_ignore_all = 1
net.ipv6.icmp.echo_ignore_all = 1
# Enable BBR
# 3X-UI already configures BBR. No need to create configuration
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
# Apply all settings the same way as at boot
sudo sysctl --system
# Show which files and values are applied at boot
systemd-analyze cat-config sysctl.d
# Check current values
sysctl net.ipv4.tcp_congestion_control net.ipv4.icmp_echo_ignore_all net.ipv6.icmp.echo_ignore_all

# Find other configs in /etc/ssh/sshd_config.d to remove records from there
# Check if port number is not used in other cases
# ssh reads the first file, so we create file with 10 in its name
sudo nano /etc/ssh/sshd_config.d/10-custom.conf
# Change SSH port
Port <port_number>
# Disable Root SSH Login
PermitRootLogin no
# Disable password authentication
PasswordAuthentication no
# Enabled SSH key authentication
PubkeyAuthentication yes
# Check syntax and effective values before restart
sudo sshd -t && sudo systemctl reload ssh
# Port or ListenAddress changed (socket activation: ssh.socket listens on the port)
sudo sshd -t && sudo systemctl daemon-reload && sudo systemctl restart ssh.socket && sudo systemctl status ssh.socket
# Check if socket activation is used. If inactive, use: sudo systemctl restart ssh
systemctl is-active ssh.socket

# Lock the root password
# Needed another user with sudo access level
sudo passwd -l root

# DNS
# resolved reads the last file, so we create file with 99 in its name
sudo mkdir -p /etc/systemd/resolved.conf.d
sudo nano /etc/systemd/resolved.conf.d/99-custom.conf
###
[Resolve]
# DNS= clears DNS records
DNS=
DNS=1.1.1.1#cloudflare-dns.com 8.8.8.8#dns.google 9.9.9.9#dns.quad9.net
DNSOverTLS=yes
###
sudo systemctl restart systemd-resolved
resolvectl status
resolvectl query google.com
sudo ss -tnp | grep ':853'

# Open ports on firewall
# Allow the SSH port BEFORE enabling ufw, or you will lose access
# See https://github.com/farag2/Utilities/blob/master/Linux/nginx_configs.md
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow <ssh_port>/tcp comment 'SSH'
sudo ufw allow 443/tcp comment 'Xray VLESS REALITY'
sudo ufw allow 80/tcp comment 'nginx HTTP, acme.sh'
sudo ufw --force enable
sudo ufw status verbose
ss -ntpl

# Edit crons
# See https://github.com/farag2/Utilities/blob/master/Linux/weekly-upgrade.sh
# sudo crontab -e
# Weekly update
0 0 * * 7 /usr/local/sbin/weekly-upgrade.sh
sudo crontab -u $USER -e
# List cron jobs
sudo crontab -u <user> -l
sudo crontab -l

# System jobs
/var/spool/cron/crontabs

# Set time
sudo timedatectl set-timezone Europe/Berlin
sudo systemctl restart cron
timedatectl

# Add new IP address for inbound
# Check IP addresses on server
ip -4 addr show ens3
sudo nano /etc/netplan/60-extra-ip.yaml
#
network:
  version: 2
  ethernets:
    ens3:
      addresses:
        - <new IP address>/<subnet>
#
sudo chmod 600 /etc/netplan/60-extra-ip.yaml
sudo netplan try
# Check IP address
curl --interface <new IP address> https://ifconfig.me
# Check from you country of origin
Test-NetConnection <new IP address> -Port 443
Test-NetConnection <new IP address> -Port <SSH port>
# Open outbound records and edit "direct"
#
{
  "protocol": "freedom",
  "sendThrough": "<old IP address>",
  "settings": {
    "finalRules": [
      { "action": "block", "ip": ["geoip:private"] },
      { "action": "allow" }
    ]
  },
  "tag": "direct"
}
#
# Edit Inbounds listen server
Add <new IP address>

# Connect via SSH from PowerShell
& "$env:SystemRoot\System32\OpenSSH\ssh.exe" user@ip_address -p <port> -v

# Download file from remote server
& "$env:SystemRoot\System32\OpenSSH\scp.exe" -P <port> user@ip_address:/home/file.txt D:\folder\
# Or interactively
# get /home/cron.log D:\Downloads\cron.log
& "$env:SystemRoot\System32\OpenSSH\sftp.exe" -P <port> user@ip_address

# Upload file to remote server
& "$env:SystemRoot\System32\OpenSSH\scp.exe" -P <port> "D:\folder\1.txt" user@ip_address:/home/<username>
# Or interactively
& "$env:SystemRoot\System32\OpenSSH\sftp.exe" -P <port> user@ip_address
put "D:\folder\1.txt" /home/<username>

# Authorize via SSH key
# sudo apt install openssh-server -y
# apt list --installed | grep openssh

# Generate SSH keys and save them to "$env:USERPROFILE\.ssh"
& "$env:SystemRoot\System32\OpenSSH\ssh-keygen.exe" -t ed25519 -f "$env:USERPROFILE\.ssh\<name>" -C "<name>"
# Copy ONLY the public key (.pub) to the server
& "$env:SystemRoot\System32\OpenSSH\scp.exe" -P 6601 "$env:USERPROFILE\.ssh\<friendlyname>.pub" user@ip_address:~/.ssh/authorized_keys
# List folders on server
ls -la ~/.ssh

# Configure ssh-agent service
Set-Service -Name ssh-agent -StartupType Automatic
Start-Service -Name ssh-agent
& "$env:SystemRoot\System32\OpenSSH\ssh-add.exe" $env:USERPROFILE\.ssh\<ssh-file-without-pub-ext>

# id_ed25519 won't be accepted if it is placed in a public folder
& "$env:SystemRoot\System32\OpenSSH\ssh.exe" user@ip_address -p <port> -i "$env:USERPROFILE\.ssh\<ssh-file-without-pub-ext>" -v

# List directories via FTP
# FTP sends the password in plain text. Use FTPS ($Request.EnableSsl = $true) if the server supports it
# FtpWebRequest is marked as obsolete in PowerShell 7
$Resource = ""
$Port = ""
$Login = ""
$Password = ""
$Request = [System.Net.FtpWebRequest]::Create("ftp://${Resource}:${Port}")
$Request.Credentials = New-Object -TypeName System.Net.NetworkCredential -ArgumentList $Login, $Password
$Request.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectory
# Use $true for FTPS
$Request.EnableSsl = $false
$Response = $Request.GetResponse()
$ResponseStream = $Response.GetResponseStream()
$Reader = New-Object -TypeName System.IO.StreamReader -ArgumentList $ResponseStream
# List directories and files
$Files = while (-not $Reader.EndOfStream)
{
	$Reader.ReadLine()
}
$Reader.Close()
$Response.Close()
$Files

#
& "$env:SystemRoot\System32\ftp.exe" IP_address
