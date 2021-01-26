#!/usr/bin/env bash
sudo docker pull grafana/grafana:latest-ubuntu
sudo docker run -d -p 3000:3000 --name grafana --network host grafana/grafana:latest-ubuntu

# import node-exporter dashboard