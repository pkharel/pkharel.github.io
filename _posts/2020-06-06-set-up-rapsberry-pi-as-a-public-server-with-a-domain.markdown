---
layout: post 
title:  "Set up Rapsberry Pi as a public server with a domain"
tags: raspberrypi google domains dynamic dns nginx static ip
---

Documenting the steps I took to set up a custom domain that points to a Raspberry Pi server.

# Requirements
* You have a Raspberry Pi that's accessible via other devices on the network
* You own a domain that you can use to point to the Raspberry Pi server e.g www.mydomain.com

# Static IP
Setting up a static IP makes things a bit easier. Follow a
[guide](https://www.makeuseof.com/raspberry-pi-set-static-ip/). You basically have to add the
following lines to `/etc/dhcpcd.conf`. This is just an example
```
interface eth0
static ip_address=192.168.0.84/24
static routers=192.168.0.1
static domain_name_servers=192.168.0.1
```
where `eth0` is the network interface, `ip_address` is the static IP address we want the device to
have, `routers` is the gateway IP address and the `domain_name_servers` is the DNS server which is
usually just the router's address.

# NGINX Server
We'll use [NGINX](https://www.nginx.com/) as the web server. Install and run NGINX via
```
sudo apt install nginx
systemctl start nginx 
```
Go to `https://<static_ip_address>` and you should see the NGINX test page.

# DNS configuration
First we need a DNS configuration that will forward all `*.mydomain.com` requests to the Raspberry
Pi's current IP address.

Using Google Domains, go to `DNS`->`Synthetic records` and create a new
`Dynamic DNS` record for `*.mydomain.com`.

Download this [script](https://gist.github.com/cyrusboadway/5a7b715665f33c237996) and fill in
credentials/hostname and run the script. The script basically grabs the IP address and updates the
DNS in Google Domains so the domain points to the IP address.

```
#!/bin/bash

USERNAME=""
PASSWORD=""
HOSTNAME=""

# Resolve current public IP
IP=$( dig +short myip.opendns.com @resolver1.opendns.com )
# Update Google DNS Record
URL="https://${USERNAME}:${PASSWORD}@domains.google.com/nic/update?hostname=${HOSTNAME}&myip=${IP}"
curl -s $URL
echo
```

# Port Forward
You'll need to forward ports 80 and 443 to the Raspberry Pi device. The instructions depend on the
router you're using.

# Test Domain
You should be able to go to `https://www.mydomain.com` and see the NGINX test page.
