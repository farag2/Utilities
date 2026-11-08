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

map $http_user_agent $sub_client_ok {
    default        0;
    ~Throne        1;
    ~v2rayNG       1;
    ~TeapodStream  1;
    ~Exclave       1;
}

server {
    listen 80;
    server_name <domain> <domain>;

    return 301 $redirect_target;
}

server {
    listen 80 default_server;
    server_name <domain>;

    root /var/www/<domain>;
    index index.html;

    location /.well-known/acme-challenge/ {
        root /var/www/<domain>;
    }
}

server {
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

    location /<secret link name to 3X-Ui panel>/ {
        proxy_pass https://127.0.0.1:<panel port>;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    location /<secret link name subscriptions>/ {
        if ($sub_client_ok = 0) {
            return 404;
        }
        proxy_pass https://127.0.0.1:<sub port>;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
    }
}
```

## 3X-UI panel listen IP
## 3X-UI subscriptions listen IP
127.0.0.1

## 3X-UI Reverse Proxy URI
<domain/<secret panel URL>/

## Subscription Service
## JSON subscription
On

## 3X-UI subscriptions listen IP
127.0.0.1

## Listen Port
<sub port>

## JSON URI Path
/<panel port>-json/

## Xray JSON User-Agent regex
# Filter adding sub in VPN clients by user agents
`(?i)^(v2rayNG|TeapodStream|Exclave)/`

## JSON subscription routing profile

```json
{
  "Name": "Sanctuary",
  "GlobalProxy": "true",
  "RemoteDNSType": "DoH",
  "RemoteDNSDomain": "https://cloudflare-dns.com/dns-query",
  "RemoteDNSIP": "1.1.1.1",
  "DomesticDNSType": "DoU",
  "DomesticDNSDomain": "",
  "DomesticDNSIP": "8.8.8.8",
  "DnsHosts": {
    "cloudflare-dns.com": "1.1.1.1"
  },
  "DirectSites": ["geosite:category-ru", "domain:ru", "domain:su", "domain:xn--p1ai"],
  "DirectIp": ["geoip:private", "geoip:ru"],
  "ProxySites": [],
  "ProxyIp": [],
  "BlockSites": [],
  "BlockIp": [],
  "DomainStrategy": "IPOnDemand",
  "FakeDNS": "false"
}
```

## Check connected clients' user-agent 
sudo grep '/<secret link name subscriptions>/' /var/log/nginx/access.log | awk -F'"' '{print $6}' | sort | uniq -c | sort -rn

