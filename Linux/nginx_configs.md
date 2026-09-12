## Redirect

`sudo nano /etc/nginx/sites-available/<domain>`

```
map $host $redirect_target {
    sub.domain.com     <URL>
    sub.domain.com     <URL>
}

server {
    listen 80;
    server_name sub.domain.com sub.domain.com;

    return 301 $redirect_target;
}
```

## telemt

<https://github.com/telemt/telemt/issues/617#issuecomment-4286171352>

`sudo nano /etc/nginx/sites-available/<domain>`

```
# latest nginx

server {
    listen      80;
    server_name <domain>;

    location /.well-known/acme-challenge/ { root /var/www/<domain>; }
    location / { return 301 https://$host$request_uri; }
}

server {
    listen      127.0.0.1:8443 ssl;
    http2       on;
    server_name <domain>;

    ssl_certificate     /etc/letsencrypt/live/<domain>/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/<domain>/privkey.pem;

    ssl_protocols              TLSv1.3;

    root /var/www/<domain>;
    index index.html;

    access_log /var/log/nginx/<domain>.access.log;
    error_log  /var/log/nginx/<domain>.error.log;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

## x-ui

```
map $host $redirect_target {
    <domain> URL;
    <domain> URL;
}

server {
    listen 80;
    server_name <domain> <domain>;

    return 301 $redirect_target;
}

server {
    listen 80;
    server_name <domain>;

    root /var/www/<domain>;
    index index.html;

    location /.well-known/acme-challenge/ {
        root /var/www/<domain>;
    }
}

server {
    # for nginx lower than 1.25
    listen 127.0.0.1:8443 ssl;
    http2 on;
    server_name <domain>;

    # Issuing within x-ui
    ssl_certificate     /root/cert/<domain>/fullchain.pem;
    ssl_certificate_key /root/cert/<domain>/privkey.pem;
    ssl_protocols       TLSv1.3;

    root  /var/www/<domain>;
    index index.html;
    location / { try_files $uri $uri/ =404; }
}
```
