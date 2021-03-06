# Filecoin监控报警系统搭建

## 1. 安装Docker
本文提到的监控报警系统，基于Docker进行部署，先在监控机上，运行本项目下`scripts/install-docker.sh`脚本来安装Docker。

## 2. 部署Prometheus
修改`scripts/install-prometheus.sh`脚本中的`scrape_configs`，将每个Job中的`job_name`改为要监控的机器的主机名，`targets`改为要监控的机器的IP。

然后在监控机上运行`scripts/install-prometheus.sh`安装Prometheus。

## 3. 部署Node-exporter
通过`ansible/install-node-exporter.yaml`脚本，在每台需要监控的机器上，部署并启动`node-exporter`客户端，用于收集监控数据，发送给Prometheus。

## 4. 部署Grafana
- 在监控机上，运行`scripts/install-grafana.sh`，安装Grafana。
- 安装完成后，在跳板机或路由器上，增加外网3000端口到监控机3000端口的映射，让Grafana可以通过外网访问。
- 在Grafana的`Configuration/Data Sources`中，添加数据源，选择Prometheus，URL为`http://localhost:9090`，然后点击底部的`Save & Test`按钮，测试成功后进入下一步。
- 在Grafana的`Dashboards/Manage`，点击右上角的Import按钮，再点击`Upload JSON file`按钮，选择本项目`config/Miner-monitoring.json`文件并导入。
