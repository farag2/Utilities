<https://github.com/telemt/telemt/issues/617#issuecomment-4286171352>

`sudo nano /etc/nginx/sites-available/<domain>`

```
# Enable permanent redirection
server {
    listen 80;
    server_name <subdomain.domain.com>;

    # 301 Permanent Redirect
    return 301 <new_link>;
}
```

`sudo nano  /etc/nginx/sites-available/<domain>.conf`

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
