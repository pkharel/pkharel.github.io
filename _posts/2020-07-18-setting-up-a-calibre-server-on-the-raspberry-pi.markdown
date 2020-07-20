---
layout: post 
title:  "Setting up a Calibre server on the Raspberry Pi"
tags: calibre raspberrypi
---

Documenting the steps I took to get a publically accessible calibre server up and running alongside an existing Nginx setup and HTTPS.

# Setting up calibre

Install [calibre]. The newest version of calibre doesn't seem to be available in the repos. TODO should try building newer version from source

```
sudo apt install calibre
```

Create a [calibre library].
```
mkdir /mnt/elements/media/ebooks/
cd /mnt/elements/media/ebooks/
wget http://www.gutenberg.org/ebooks/1342.kindle.noimages -O pride.mobi
calibredb add /mnt/elements/media/ebooks/* --library-path /mnt/elements/media/ebooks/
```
Make sure everything works
```
calibre-server /mnt/elements/media/ebooks/
```
Try loading up <http://127.0.0.1:8080>

*(Optional)* Create a [systemd service unit file] to manage the server. Create file at `/etc/systemd/system/calibre-server.service` with the following
```
[Unit]
Description=calibre content server
After=network.target

[Service]
Type=simple
User=pi
Group=pi
ExecStart=/usr/bin/calibre-server "/mnt/elements/media/ebooks/"

[Install]
WantedBy=multi-user.target
```
Try starting up the server
```
systemctl enable calibre-server
systemctl start calibre-server
```

# Nginx configuration
We want to be able to access the Calibre server via something like `http://ebooks.myserver.com`. Assuming DNS is already set up properly. TODO maybe a separate post on Google Domains + Nginx + LetsEncrypt

Add a new site to Nginx by creating a new file at `/etc/nginx/sites-available/ebooks.myserver.com`
```
upstream calibre_backend {
  server    127.0.0.1:8080;
  keepalive 32;
}

server {
  listen 80;
  server_name         ebooks.myserver.com;
  location / {
    proxy_pass http://calibre_backend;
  }
}
```
Enable site
```
cd /etc/nginx/sites-enabled/
ln -s ../sites-available/ebooks.myserver.com
systemctl restart nginx
```

# Enable HTTPS
Get certs from LetsEncrypt. The app should ask you if you want to change the configuration to force HTTPS. That'll update the Nginx config and enable HTTPS.
```
sudo certbot --nginx -d ebooks.myserver.com
```

[calibre]: https://calibre-ebook.com/
[calibre library]: https://www.digitalocean.com/community/tutorials/how-to-create-a-calibre-ebook-server-on-ubuntu-14-04
[systemd service unit file]: https://manual.calibre-ebook.com/server.html#id13

