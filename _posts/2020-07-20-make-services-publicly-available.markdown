---
layout: post
title:  "Make web services publicly available"
tags:
  - raspberrypi
  - nginx
  - letsencrypt
  - https
  - raspberry pi
---

Documenting the steps I took to make internal services (e.g plex, calibre, pihole) publicly
available on the Raspberry Pi.

# Requirements
Follow [{% post_url 2020-06-06-set-up-rapsberry-pi-as-a-public-server-with-a-domain %})]

# General Overview
We want to set up multiple services on a Raspberry Pi and have subdomains point to the various
services. For example, Let's assume `ServiceA` is currently running on the Raspberry Pi on port `8080`
and `ServiceB` is running on port `8081`. We can use NGINX to make both of those services accessible
publicly by going to `http://servicea.mydomain.com` and `http://serviceb.mydomain.com` respectively.

# NGINX configuration

Add a new site to Nginx by creating a new file at `/etc/nginx/sites-available/servicea.myserver.com`
```
upstream servicea_backend {
  server    127.0.0.1:8080;
  keepalive 32;
}

server {
  listen 80;
  server_name         servicea.mydomain.com;
  location / {
    proxy_pass http://servicea_backend;
  }
}
```

Create a similar file for `ServiceB`. Then we need to enable the sites and restart NGINX.
```
cd /etc/nginx/sites-enabled/
ln -s ../sites-available/ebooks.myserver.com
systemctl restart nginx
```

# Enable HTTPS
Get certs from LetsEncrypt. The app should ask you if you want to change the configuration to force
HTTPS. That'll update the Nginx config and enable HTTPS.
```
sudo certbot --nginx -d ebooks.myserver.com
```
This will update the NGINX configuration files for the sites.
