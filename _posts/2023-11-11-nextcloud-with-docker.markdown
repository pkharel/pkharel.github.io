---
layout: post
title:  "Nextcloud with Docker"
tags: nextcloud docker https nginx
---

## Overview 
I'm using [Nextcloud](https://nextcloud.com/) as an on premise backup and
storage solution for a local server. I'm using docker to run a bunch of other
services so this is to document running Nextcloud on docker.

Nextcloud needs access to a database which we will also need to run via docker.
Note the `NEXTCLOUD_TRUSTED_DOMAINS` and `OVERWRITEPROTOCOL` variables being
set. I'm using an external (not running on docker) nGINX as a reverse proxy so I
need to add the domain as a trusted domain which is done by setting the value of
that variable.

I was having issues logging in where the main page would get stuck after logging
in and then start working again after a refresh. This was only hapenning over
`https` and setting the `OVERWRITEPROTOCOL` to `https` seems to fix the issue.

Most of the docker compose should be from the Nextcloud docs. After running
`docker compose up`, the service should be available at `localhost:8081`.

## Docker compose
```
  # Database for nextcloud
  nextcloud_db:
    image: mariadb:10.6
    container_name: nextcloud_db
    restart: always
    command: --transaction-isolation=READ-COMMITTED --log-bin=binlog --binlog-format=ROW
    volumes:
      - ./services/nextcloud_db:/var/lib/mysql
    environment:
      - MYSQL_PASSWORD=${MYSQL_PASSWORD}
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
      - MYSQL_DATABASE=nextcloud
      - MYSQL_USER=nextcloud
  nextcloud:
    image: nextcloud
    container_name: nextcloud
    restart: always
    ports:
      - 8081:80
    links:
      - nextcloud_db
    volumes:
      - ./services/nextcloud:/var/www/html
      - ./services/nextcloud/apps:/var/ww/html/custom_apps
      - ./services/nextcloud/config:/var/ww/html/config
      - /path/to/data/storage:/var/www/html/data
    environment:
      - NEXTCLOUD_TRUSTED_DOMAINS=nextcloud.example.dev
      - OVERWRITEPROTOCOL=https
      - MYSQL_PASSWORD=${MYSQL_PASSWORD}
      - MYSQL_DATABASE=nextcloud
      - MYSQL_USER=nextcloud
      - MYSQL_HOST=nextcloud_db
```

## nGINX configuration
This is the nGINX config I have for the site

```
upstream nextcloud_backend {
  server    127.0.0.1:8081;
  keepalive 32;
}

server {
  server_name         nextcloud.example.dev;
  location / {
    proxy_pass http://nextcloud_backend;
    #proxy_set_header Host nextcloud.example.dev;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_buffering off;
    proxy_request_buffering off;
    proxy_set_header X-Real-IP $remote_addr;
    client_max_body_size 10G;
  }
  location /.well-known/carddav {
    return 301 $scheme://$host/remote.php/dav;
  }

  location /.well-known/caldav {
    return 301 $scheme://$host/remote.php/dav;
  }

  listen 443 ssl; # managed by Certbot
  ssl_certificate /etc/letsencrypt/live/example.dev/fullchain.pem; # managed by Certbot
  ssl_certificate_key /etc/letsencrypt/live/example.dev/privkey.pem; # managed by Certbot
  include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
  ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}

server {
  if ($host = nextcloud.example.dev) {
      return 301 https://$host$request_uri;
  }
  server_name         nextcloud.example.dev;
  listen 80;
    return 404;
}
```
