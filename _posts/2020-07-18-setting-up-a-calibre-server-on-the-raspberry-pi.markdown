---
layout: post 
title:  "Setting up a Calibre server"
tags: calibre raspberrypi
---

Documenting the steps I took to get a Calibre server up and running on a Raspberry Pi.

# Requirements
A Raspberry Pi that's accessible from devices in the network and that's optionally [set up with a
static IP and a custom domain]({% post_url 2020-06-06-set-up-rapsberry-pi-as-a-public-server-with-a-domain %}).

# Setting up calibre
Install [calibre]. The latest version of calibre doesn't seem to be available in the repos.

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

*(Optional)* Create a [systemd service unit file] to manage the server. Create file at
`/etc/systemd/system/calibre-server.service` with the following
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

# Next Steps 
You can [make the server publicly accessible over HTTPS]({% post_url 2020-07-20-make-services-publicly-available %}).

[calibre]: https://calibre-ebook.com/
[calibre library]: https://www.digitalocean.com/community/tutorials/how-to-create-a-calibre-ebook-server-on-ubuntu-14-04
[systemd service unit file]: https://manual.calibre-ebook.com/server.html#id13

