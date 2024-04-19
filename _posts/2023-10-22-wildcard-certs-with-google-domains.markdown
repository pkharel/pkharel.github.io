---
layout: post
title:  "Wildcard certificates with Google Domains"
tags:
  - wildcard
  - certificates
  - certbot
  - google domains
---

## Wildcard certificates
If you have multiple services running on your server and need to generate certs,
it might be easier to generate a single certificate for `*.domain.com` instead
of individual certificates for `servicea.domain.com` and `serviceb.domain.com`.
It'll be easier to manage a single key too.

## Google Domains
We assume already have a `*.domain.com` Type A entry in Google Domains. I'm
using Dynamic DNS with [ddclient](https://ddclient.net/)

## Certbot
We'll use certbot and it's google domain plugin. It's better to install certbot
via pip so we get the latest version
```
sudo python3 -m venv /opt/certbot/
source /opt/certbot/bin/enable
pip install --upgrade pip
pip install certbot
```
We'll use [this plugin](https://github.com/aaomidi/certbot-dns-google-domains)
which you can install via
```
pip install certbot certbot-dns-google-domains
```
Create a file `/etc/letsencrypt/dns_google_domains_credentials.ini` and fill it
with
```
dns_google_domains_access_token = <token>
```
You can get the token from `Google Domains -> Security -> ACME DNS API -> Create
token`

Run `certbot` with
```
certbot certonly --authenticator 'dns-google-domains' \
                 --dns-google-domains-credentials '/etc/letsencrypt/dns_google_domains_credentials.ini' \
                 --server 'https://acme-v02.api.letsencrypt.org/directory'
                --dns-google-domains-zone 'domain.com' -d '*.domain.com'
```
Make sure you update your NGINX configurations to use the new certificate.
