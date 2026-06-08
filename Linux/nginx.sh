# Install nginx
sudo apt install nginx libnginx-mod-stream -y

# Issue cert
sudo apt install certbot python3-certbot-nginx -y
certbot certonly --standalone --agree-tos -d <domain> -m <mail>

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
