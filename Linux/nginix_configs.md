## Redirect

`sudo nano /etc/nginx/sites-available/<domain>`

```
# Enable permanent redirection
server {
    listen 80;
    server_name <domain>;

    # 301 Permanent Redirect
    return 301 <new_link>;
}
```

## telemt

<https://github.com/telemt/telemt/issues/617#issuecomment-4286171352>

`sudo nano /etc/nginx/sites-available/<domain>`

```
# latest nginx

server {
    listen 127.0.0.1:8443 ssl;
    http2 on;
    server_name <domain>;

    # Issuing within certbot
    ssl_certificate     /etc/letsencrypt/live/<domain>/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/<domain>/privkey.pem;

    ssl_protocols TLSv1.3;

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

## x-ui

```
server {
    listen 80;
    server_name <domain>;

    root /var/www/<domain>;
    index index.html;
}

server {
    # for nginx lower than 1.25
    listen 127.0.0.1:8443 ssl http2;
    server_name <domain>;

    # Issuing within x-ui
    ssl_certificate     /root/cert/<domain>/fullchain.pem;
    ssl_certificate_key /root/cert/<domain>/privkey.pem;
    ssl_protocols       TLSv1.3;

    root  /var/www/<domain>;
    index index.html;

    access_log /var/log/nginx/<domain>.access.log;
    error_log  /var/log/nginx/<domain>.error.log;

    location / { try_files $uri $uri/ =404; }
}
```
