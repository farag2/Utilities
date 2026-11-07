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
sudo nano /etc/sysctl.d/99-custom.conf
# Disable ICMP ping response
net.ipv4.icmp_echo_ignore_all = 1
net.ipv6.icmp.echo_ignore_all = 1
# Enable BBR
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
# Apply all settings the same way as at boot
sudo sysctl --system
# Show which files and values are applied at boot
systemd-analyze cat-config sysctl.d
# Check current values
sysctl net.ipv4.tcp_congestion_control net.ipv4.icmp_echo_ignore_all net.ipv6.icmp.echo_ignore_all

# Change SSH port
# Check if port number is not used in other cases
# systemctl status ssh.socket
# ss -tlnp | grep :22
# Port <port_number>
sudo nano /etc/ssh/sshd_config

# Disable Root SSH Login
# A file like 50-cloud-init.conf with "PasswordAuthentication yes" overrides sshd_config
# ls /etc/ssh/sshd_config.d
sudo nano /etc/ssh/sshd_config.d/00-hardening.conf
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
# Where SSH key to expect
AuthorizedKeysFile .ssh/authorized_keys
# Check syntax and effective values before restart
sudo sshd -t && sudo systemctl reload ssh
# Port or ListenAddress changed (socket activation: ssh.socket listens on the port)
sudo sshd -t && sudo systemctl daemon-reload && sudo systemctl restart ssh.socket
# Check if socket activation is used. If inactive, use: sudo systemctl restart ssh
systemctl is-active ssh.socket

# Lock the root password
# Needed another user with sudo access level
sudo passwd -l root

# DNS-over-TLS
sudo nano /etc/systemd/resolved.conf
# The name after # is used to verify the server certificate
DNS=1.1.1.1#cloudflare-dns.com 8.8.8.8#dns.google
FallbackDNS=9.9.9.9#dns.quad9.net
DNSOverTLS=yes
sudo systemctl restart systemd-resolved
# Must show +DNSOverTLS
resolvectl status
# resolvectl dns

# Open ports on firewall
# Allow the SSH port BEFORE enabling ufw, or you will lose access
# ss -ntpl
sudo ufw allow <ssh_port>/tcp
sudo ufw allow 443/tcp
sudo ufw enable
sudo ufw status verbose

# Edit crons
sudo crontab -u <user> -e
sudo crontab -e
# Updates and reboots every Sunday at 00:00 server time (usually UTC)
# --force-confdef --force-confold: keep own config files, do not wait for dpkg questions
0 0 * * 7 export DEBIAN_FRONTEND=noninteractive NEEDRESTART_SUSPEND=1; { apt-get update && apt-get -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold full-upgrade -y && apt-get autoremove -y && apt-get autoclean -y && echo "$(date): Success" >> /home/cron.log && /sbin/reboot; } || echo "$(date): Failed $?" >> /home/cron_fail.log

# List cron jobs
sudo crontab -u <user> -l
sudo crontab -l

# System jobs
/var/spool/cron/crontabs

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
