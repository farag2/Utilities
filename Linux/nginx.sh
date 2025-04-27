# https://freedirector.io/dashboard
# https://forwarddomain.net

# Enable permanent redirection
sudo nano /etc/nginx/sites-available/<subdomain>

# /etc/nginx/sites-available/<subdomain> file
server {
    listen 80;
    server_name <subdomain>;

    # 301 Permanent Redirect
    return 301 <new_domain>;
}

sudo ln -s /etc/nginx/sites-available/<subdomain> /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

# In ISPmanager
Name: subdomain_name
Type: A
Value: <VPS IP>
TTL: 3600

# Test configuration
curl -I <subdomain>
