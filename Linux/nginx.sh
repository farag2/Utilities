# Install nginx
sudo apt install nginx libnginx-mod-stream -y
# check status
sudo systemctl status nginx
# start if not running
sudo systemctl start nginx
# start on boot
sudo systemctl enable nginx
# Install certbot and its dependencies
sudo apt install certbot python3-certbot-nginx -y

# Issue cert
sudo certbot certonly -d <domain>

# Create a temp page
sudo mkdir -p /var/www/<domain>/html
echo "<domain>" | sudo tee /var/www/<domain>/html/index.html

# Telemt service
sudo systemctl start telemt
sudo systemctl restart telemt
sudo systemctl enable telemt
sudo systemctl status telemt

# Check telemt status
sudo telemt /etc/telemt/telemt.toml

sudo nginx -t
sudo systemctl restart nginx

sudo journalctl -u telemt -f

# In ISPmanager
Name: subdomain_name
Type: A
Value: <VPS IP>
TTL: 3600

# Test configuration
curl -I <domain>

# Enable nginix config
sudo ln -s /etc/nginx/sites-available/<domain> /etc/nginx/sites-enabled/<domain>
