#!/usr/bin/env bash
currentUser=fil
workspace=/home/$currentUser/workspace

cd $workspace
wget -c https://github.com/prometheus/node_exporter/releases/download/v1.4.0/node_exporter-1.4.0.linux-amd64.tar.gz
tar xfvz node_exporter-1.4.0.linux-amd64.tar.gz

sudo mv node_exporter-1.4.0.linux-amd64/node_exporter /usr/local/bin/
sudo chmod a+x /usr/local/bin/node_exporter
rm -rf $workspace/node_exporter-1.4.0.linux-amd64*

mkdir -p /home/$currentUser/prometheus/run

sudo systemctl enable node-exporter
sudo systemctl start node-exporter
