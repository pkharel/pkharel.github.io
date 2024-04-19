---
layout: post
title:  "Monitoring docker services"
tags:
  - docker compose
  - monitoring
  - prometheus
  - grafana
  - node-exporter
  - cadvisor
  - alertmanager
  - discord
---

## Prometheus, Alertmanager and Grafana
[Prometheus](https://prometheus.io/) allows applications to export metrics and
stores them in a central database.
[Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/) can be
used to setup alerts for the metrics collected via Prometheus.
[Grafana](https://grafana.com/) is used to visualize Prometheus metrics.

## Node exporter and cAdvisor
[Node exporter](https://github.com/prometheus/node_exporter) and
[cAdvisor](https://github.com/google/cadvisor) export various metrics to
Prometheus. Node exporter exports system and hardware stats for  CPU, RAM, I/O
and network among other things. cAdvisor does the same thing for containers.

## Prometheus config
Place the config file in `prometheus/prometheus.yml`
```
global:
  scrape_interval: 30s
  scrape_timeout: 10s

rule_files:
  - alerts.yml

alerting:
  alertmanagers:
    - scheme: http
      static_configs:
        - targets: [ 'alertmanager:9093' ]

scrape_configs:
  - job_name: prometheus
    scrape_interval: 10s
    static_configs:
      - targets:
        - host.docker.internal:9090
        - cadvisor:8080
        - node-exporter:9100
```

I filled the `alerts.yml` file with various alerts for Node exporter and
cAdvisor from
[here](https://samber.github.io/awesome-prometheus-alerts/rules.html) and
[here](https://gist.github.com/krisek/62a98e2645af5dce169a7b506e999cd8).

## Alertmanager config
I configured Alertmanager to send alerts to discord.

```
route:
  group_by: ['alertname', 'job']

  group_wait: 30s
  group_interval: 5m
  repeat_interval: 3h

  receiver: discord

receivers:
- name: discord
  discord_configs:
  - webhook_url: <DISCORD_WEBHOOK_URL>
```

## Grafana config
[Cadvisor
exporter](https://grafana.com/grafana/dashboards/14282-cadvisor-exporter/) and
[Node Exporter
Full](https://grafana.com/grafana/dashboards/1860-node-exporter-full/) are two
nice dashboards to expose the data collected by Prometheus. I had to manually
update some of the graphs for Cadvisor exporter to get it to show the memory
usage correctly.

## Docker compose
```
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - 9090:9090
    volumes:
      - ./prometheus:/etc/prometheus
      - prometheus_data:/prometheus
    command: --web.enable-lifecycle  --config.file=/etc/prometheus/prometheus.yml --web.enable-admin-api
    extra_hosts:
      - "host.docker.internal:host-gateway"
  alertmanager:
    image: prom/alertmanager
    restart: always
    ports:
      - 9093:9093
    volumes:
      - ./alertmanager:/config
      - alertmanager_data:/data
    command: --config.file=/config/alertmanager.yml --log.level=debug
  grafana:
    container_name: grafana
    image: grafana/grafana
    volumes:
      - grafana_data:/var/lib/grafana
    ports:
      - 3000:3000
```
