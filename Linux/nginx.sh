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

# Enable permanent redirection
# sudo nano /etc/nginx/sites-available/<domain>

```
server {
    listen 80;
    server_name <subdomain.domain.com>;

    # 301 Permanent Redirect
    return 301 <new_link>;
}
```

# sudo nano  /etc/nginx/sites-available/<domain>.conf

```
server {
    listen 127.0.0.1:8443 ssl http2;
    server_name <domain>;

    ssl_certificate     /etc/letsencrypt/live/<domain>/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/<domain>/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    root /var/www/<domain>;
    index index.html;

    access_log /var/log/nginx/<domain>.access.log;
    error_log  /var/log/nginx/<domain>.error.log;

    location / {
        try_files $uri $uri/ =404;
    }
}

server {
    listen 127.0.0.1:8080;
    server_name <domain>;

    # local HTTP → HTTPS redirect if needed for tools
    return 301 https://<domain>$request_uri;
}
```

# Enable nginix config
sudo ln -s /etc/nginx/sites-available/<domain> /etc/nginx/sites-enabled/<domain>
