#!/usr/bin/env bash
currentUser=fil
sudo mkdir -p /home/$currentUser/disk_md0/prometheus
sudo tee /home/$currentUser/disk_md0/prometheus/prometheus.yaml <<-'EOF'
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'Worker'
    scrape_interval: 5s
    static_configs:
      - targets: ['10.0.1.11:9100', '10.0.1.12:9100', '10.0.1.13:9100', '10.0.1.14:9100', '10.0.1.15:9100', '10.0.2.11:9100']

  - job_name: 'Daemon'
    scrape_interval: 5s
    static_configs:
      - targets: ['10.0.99.10:9100', '10.0.99.11:9100']

  - job_name: 'Miner'
    scrape_interval: 5s
    static_configs:
      - targets: ['10.0.99.12:9100', '10.0.99.13:9100', '10.0.99.14:9100']
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