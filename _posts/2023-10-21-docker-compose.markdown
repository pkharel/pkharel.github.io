---
layout: post 
title:  "Jellyfin server with Docker compose"
tags: jellyfin docker compose transcoding qsv quicksync intel n100 
---

## Docker Compose
Switched to using Docker compose for web services. It's a lot easier to manage
compared to using systemd config files. Using docker makes it very easy to
recreate services as well and wipe everything to start from scratch.

## Docker Compose for Jellyfin
Here's an example `compose.yml` file for [Jellyfin](https://jellyfin.org/). After
installing Docker, just use `docker compose up` to bring up the service.

```
jellyfin:
  image: jellyfin/jellyfin
  container_name: jellyfin
  network_mode: 'host'
  volumes:
    - ./services/jellyfin/config:/config
    - ./services/jellyfin/cache:/cache
    - ./services/jellyfin/media:/media
  devices:
    - /dev/dri/renderD128:/dev/dri/renderD128
    - /dev/dri/card0:/dev/dri/card0
  restart: always
```

This will store all Jellyfin related files in `./services/jellyfin/*`. Using
these bind points will ensure our config files are persistent.

## Hardware Acceleration with Intel QuickSync
The `devices` section in the docker compose is to enable the docker container to
access the Intel GPU. This is to enable hardware acceleration on Jellyfin. I had
to spend some time getting Intel QuickSync up and running for the N100 processor
on Ubuntu Jammy so briefly documenting the steps I took.

# Install the latest kernel
I didn't have to compile a newer version of the kernel. Just had to do
```
sudo apt install --install-recommends linux-generic-hwe-22.04
```
and that kernel seems to support the N100 and quicksync.

# Install jellyfin-ffmpeg
This step is optional but was very helpful to try and debug all the various
issues I was seeing

# Install intel-gpu-tools
Also optional but very useful to test if video transcoding is actually working
with the `intel_gpu_top` application.

# Follow Jellyfin HWA guide
Follow the [Jellyfin HWA
guide](https://jellyfin.org/docs/general/administration/hardware-acceleration/intel).
It's probably better to test everything and make sure it works on the host
machine before moving on to docker.

# Update docker compose
Add the `devices` section to the `jellyfin` docker compose service config. It's
important to do `docker compose down && docker compose up` instead of `docker
compose restart` to make sure the changes are picked up`

