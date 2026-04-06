# Enable permanent redirection
sudo nano /etc/nginx/sites-available/<subdomain.domain.com>

server {
    listen 80;
    server_name <subdomain.domain.com>;

    # 301 Permanent Redirect
    return 301 <new_link>;
}

sudo ln -s /etc/nginx/sites-available/<subdomain.domain.com> /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

# In ISPmanager
Name: subdomain_name
Type: A
Value: <VPS IP>
TTL: 3600

# Test configuration
curl -I <subdomain.domain.com>
