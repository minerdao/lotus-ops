#!/usr/bin/env bash
sudo mkdir -p $HOME/disk_md0/prometheus
sudo tee $HOME/disk_md0/prometheus/prometheus.yaml <<-'EOF'
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'hl-monitor-1'
    scrape_interval: 5s
    static_configs:
      - targets: ['192.168.200.52:9100']
  
  - job_name: 'hl-miner-50'
    scrape_interval: 5s
    static_configs:
      - targets: ['192.168.200.50:9100']

  - job_name: 'hl-miner-60'
    scrape_interval: 5s
    static_configs:
      - targets: ['192.168.200.60:9100']

  - job_name: 'hl-worker-51'
    scrape_interval: 5s
    static_configs:
      - targets: ['192.168.200.51:9100']

  - job_name: 'hl-worker-61'
    scrape_interval: 5s
    static_configs:
      - targets: ['192.168.200.61:9100']

  - job_name: 'hl-worker-62'
    scrape_interval: 5s
    static_configs:
      - targets: ['192.168.200.62:9100']

  - job_name: 'hl-worker-63'
    scrape_interval: 5s
    static_configs:
      - targets: ['192.168.200.63:9100']

  - job_name: 'hl-worker-66'
    scrape_interval: 5s
    static_configs:
      - targets: ['192.168.200.66:9100']

  - job_name: 'hl-worker-67'
    scrape_interval: 5s
    static_configs:
      - targets: ['192.168.200.67:9100']

  - job_name: 'hl-worker-68'
    scrape_interval: 5s
    static_configs:
      - targets: ['192.168.200.68:9100']

  - job_name: 'hl-worker-69'
    scrape_interval: 5s
    static_configs:
      - targets: ['192.168.200.69:9100']

  - job_name: 'hl-worker-70'
    scrape_interval: 5s
    static_configs:
      - targets: ['192.168.200.70:9100']

  - job_name: 'hl-worker-71'
    scrape_interval: 5s
    static_configs:
      - targets: ['192.168.200.71:9100']

  - job_name: 'hl-worker-72'
    scrape_interval: 5s
    static_configs:
      - targets: ['192.168.200.72:9100']

  - job_name: 'hl-worker-73'
    scrape_interval: 5s
    static_configs:
      - targets: ['192.168.200.73:9100']

  - job_name: 'hl-worker-74'
    scrape_interval: 5s
    static_configs:
      - targets: ['192.168.200.74:9100']

  - job_name: 'hl-worker-75'
    scrape_interval: 5s
    static_configs:
      - targets: ['192.168.200.75:9100']

  - job_name: 'hl-worker-76'
    scrape_interval: 5s
    static_configs:
      - targets: ['192.168.200.76:9100']

  - job_name: 'hl-worker-77'
    scrape_interval: 5s
    static_configs:
      - targets: ['192.168.200.77:9100']

  - job_name: 'hl-worker-78'
    scrape_interval: 5s
    static_configs:
      - targets: ['192.168.200.78:9100']

  - job_name: 'hl-worker-80'
    scrape_interval: 5s
    static_configs:
      - targets: ['192.168.200.80:9100']

  - job_name: 'hl-worker-81'
    scrape_interval: 5s
    static_configs:
      - targets: ['192.168.200.81:9100']

  - job_name: 'hl-worker-82'
    scrape_interval: 5s
    static_configs:
      - targets: ['192.168.200.82:9100']

  - job_name: 'hl-worker-83'
    scrape_interval: 5s
    static_configs:
      - targets: ['192.168.200.83:9100']

  - job_name: 'hl-worker-84'
    scrape_interval: 5s
    static_configs:
      - targets: ['192.168.200.84:9100']
EOF

sudo docker pull prom/prometheus:latest
sudo docker run -d \
  -p 9090:9090 \
  -v ~/disk_md0/prometheus:/prometheus \
  -v ~/disk_md0/prometheus/database:/prometheus/database \
  --name prometheus \
  --network host \
  prom/prometheus:latest \
  --config.file=/prometheus/prometheus.yaml \
  --storage.tsdb.path=/prometheus/database \
  --storage.tsdb.retention.time=90d \
  --web.enable-admin-api