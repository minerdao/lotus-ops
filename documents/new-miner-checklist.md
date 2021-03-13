# 新矿工节点上线CheckList

## 1. 机器CheckList
- [ ] 所有Miner和计算Worker用户名必须一致
- [ ] hostname按照以下格式命名:
  - Miner-192-168-1-3
  - Daemon-192-168-1-4
  - WorkerP-192-168-1-5 (PreCommit Worker)
  - WorkerC-192-168-1-6 (Commit Worker)
- [ ] 禁用所有机器(Miner和Worker)的swap
- [ ] Ubuntu系统禁用自动更新
- [ ] 显卡驱动禁用自动更新

## 2. 部署CheckList
- [ ] 设置Miner和Worker机器SSH免密码登录
- [ ] Ubuntu apt源更新为国内镜像(无国际线路的情况)
- [ ] 安装基础依赖库
  ```sh
  sudo apt update
  sudo apt install -y make pkg-config mesa-opencl-icd ocl-icd-opencl-dev libclang-dev libhwloc-dev hwloc gcc git bzr jq tree openssh-server python3 cpufrequtils
  ```
- [ ] 安装显卡驱动
  ```
  sudo ./NVIDIA-Linux-x86_64-xxx.xx.xx.run
  ```
- [ ] 时钟校验
  ```sh
  ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
  ntpdate ntp.aliyun.com
  ```
- [ ] Seal-miner的NVME SSD组Raid5，挂载，设置目录挂载权限
- [ ] NVME SSD批量组Raid0，挂载，设置挂载目录的权限
  - 更新挂载路径
  - 更新起始盘符
  - 更新`--raid-devices`数量
  - 更新分区数量
  - 更新用户名和组
- [ ] 给Deamon、Miner和C2-worker上拷贝证明参数

## 3. Deamon CheckList
**Deamon 启动说明**
用一台独立的机器启动一个带公网IP的Deamon备用节点，然后在Winning-PoSt-miner和Window-PoSt-miner上再分别启动一个节点，PoSt-miner通过内网连接各自机器上的Deamon。
- [ ] 检查独立Deamon机器的公网和端口是否能通(远程telnet)
- [ ] 配置独立Deamon的环境变量，初始化并启动Deamon
- [ ] 配置独立Deamon的`ListenAddress`为公网IP和端口，同步到最新高度
- [ ] 启动Winning-PoSt-miner和Window-PoSt-miner上的Deamon并同步到最新高度

## 4. Miner CheckList
- [ ] 配置Miner的环境变量，初始化Miner(默认为Seal-miner)
  ```sh
  lotus-miner init --owner f3xxxxxxxx
  ```
- [ ] 修改Miner的配置文件，更改[API]、[Storage]、[Fees]中的相关配置
  ```toml
  MaxPreCommitGasFee = "0.15 FIL"
  MaxCommitGasFee = "0.3 FIL"
  ```
- [ ] 复制`LOTUS_MINER`目录到Winning-PoSt-miner和Window-PoSt-miner上
- [ ] Seal-miner、Winning-PoSt-miner、Window-PoSt-miner分别挂载存储
- [ ] 启动Seal-miner，配置扇区ID分配的Server
- [ ] 启动Winning-PoSt-miner、Window-PoSt-miner
- [ ] 设置Miner sectorstore.json 中的`CanStore`为`false`
- [ ] Seal-miner、Winning-PoSt-miner、Window-PoSt-miner attach存储
  ```sh
  lotus-miner storage attach --store --init /home/ubuntu/sectorsdir/storage
  ```
- [ ] 为Window-PoSt、PreCommitSector和ProveCommitSector设置独立的钱包
- [ ] inotify+rsync实时备份Seal-miner、Winning-PoSt-miner、Window-PoSt-miner

## 5. Worker CheckList
- [ ] 配置Worker的环境变量，更改调度配置文件
- [ ] 检查显卡驱动是否正常
- [ ] 检查缓存盘是否正确挂载
- [ ] PreCommit Worker设置性能模式`sudo cpufreq-set -g performance`
- [ ] 批量启动P1 + P2 Worker
- [ ] 批量启动C2 Worker
