# Install nginx
sudo apt install nginx libnginx-mod-stream -y

# Hide nginx version
sudo nano /etc/nginx/nginx.conf
server_tokens off;
sudo nginx -t
sudo systemctl restart nginx

# Issue cert
sudo apt install certbot python3-certbot-nginx -y
certbot certonly --standalone --agree-tos -d <domain> -m <mail>
# Fix if 3x-ui panel issued a cert first
/root/.acme.sh/acme.sh --issue -d <domain> -w /var/www/<domain> -k ec-256 --force
/root/.acme.sh/acme.sh --install-cert -d <domain> --ecc --key-file /root/cert/<domain>/privkey.pem --fullchain-file /root/cert/<domain>/fullchain.pem --reloadcmd "x-ui restart"
# Update cert forcibly
/root/.acme.sh/acme.sh --renew -d <domain> --force --ecc

# Get web hook name
sudo systemctl list-units --type=service | grep -iE '<service_name>'

# Update cert forcibly via certbot
sudo nano /etc/letsencrypt/renewal/tg.sophia.team.conf
[renewalparams]
renew_hook = systemctl restart <service_name>

mkdir -p /var/www/<domain>/.well-known/acme-challenge
echo test > /var/www/<domain>/.well-known/acme-challenge/probe
curl -i http://<domain>/.well-known/acme-challenge/probe

# Uninstall acme
acme.sh --uninstall
rm -r  ~/.acme.sh

# Create a temp page
sudo mkdir -p /var/www/<domain>
echo "<domain>" | sudo tee /var/www/<domain>/index.html

# Check nginx status
sudo nginx -t
sudo systemctl restart nginx

sudo systemctl start nginx
sudo systemctl restart nginx
sudo systemctl enable nginx
sudo systemctl status nginx

# check nginix enabled sites
ls -l /etc/nginx/sites-enabled

# Enable nginix config
sudo ln -fs /etc/nginx/sites-available/<domain> /etc/nginx/sites-enabled/
rm -rf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# For nginx version greater than 1.25
sudo ln -fs /etc/nginx/conf.d/<domain>

# Uninstall nginx
sudo systemctl stop nginx
sudo service nginx stop
sudo apt-get purge nginx nginx-common nginx-full nginx-core -y
sudo apt-get autoremove
sudo rm -rf /etc/nginx /var/log/nginx /var/lib/nginx
