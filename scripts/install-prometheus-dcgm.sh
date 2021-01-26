#!/usr/bin/env bash
workspace=$HOME/workspace

cd $workspace
wget -c https://cs-cn-filecoin.oss-cn-beijing.aliyuncs.com/dcgm/datacenter-gpu-manager_1.7.2_amd64.deb

sudo apt install ./datacenter-gpu-manager_1.7.2_amd64.deb
sudo cp -R -v ../service/prometheus-dcgm.service /etc/systemd/system/prometheus-dcgm.service

sudo systemctl enable prometheus-dcgm
sudo systemctl start prometheus-dcgm

