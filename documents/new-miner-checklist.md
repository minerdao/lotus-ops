# 新矿工节点上线CheckList

## 机器CheckList
- [ ] 所有Miner和计算Worker用户名必须一致
- [ ] hostname按照 `192-168-100-40` 的格式
- [ ] 禁用所有机器(Miner和Worker)的swap
- [ ] Ubuntu系统禁用自动更新
- [ ] 显卡驱动禁用自动更新

## 部署CheckList
- [ ] 设置Miner和Worker机器SSH免密码登录
- [ ] Ubuntu apt源更新为国内镜像(无国际线路的情况)
- [ ] 安装基本依赖库、时钟校验
  ```sh
  sudo apt update
  sudo apt install -y pkg-config mesa-opencl-icd ocl-icd-opencl-dev libclang-dev libhwloc-dev hwloc gcc git bzr jq tree python

  # time adjust
  ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
  ntpdate ntp.aliyun.com
  ```
- [ ] NVMe SSD批量组Raid0，挂载，设置挂载目录的权限
- [ ] 给Deamon、Miner和C2-worker上拷贝证明参数

## Deamon CheckList
**Deamon 启动说明**
用一台独立的机器启动一个带公网IP的Deamon备用节点，然后在Winning-PoSt-miner和Window-PoSt-miner上再分别启动一个节点，PoSt-miner通过内网连接各自机器上的Deamon。
- [ ] 检查独立Deamon机器的公网和端口是否能通(远程telnet)
- [ ] 配置独立Deamon的环境变量，初始化并启动Deamon
- [ ] 配置独立Deamon的`ListenAddress`为公网IP和端口，同步到最新高度
- [ ] 启动Winning-PoSt-miner和Window-PoSt-miner上的Deamon并同步到最新高度

## Miner CheckList
- [ ] 配置Miner的环境变量，初始化Miner(默认为Seal-miner)
- [ ] 修改Miner的配置文件，更改[API]、[Storage]、[Fees]中的相关配置
- [ ] 更改Miner进程的ulimit，设置`open files`为`65535`
- [ ] 复制`LOTUS_MINER`目录到Winning-PoSt-miner和Window-PoSt-miner上
- [ ] Seal-miner、Winning-PoSt-miner、Window-PoSt-miner分别挂载存储
- [ ] 启动Seal-miner，配置扇区ID分配的Server
- [ ] 启动Winning-PoSt-miner、Window-PoSt-miner
- [ ] Seal-miner、Winning-PoSt-miner、Window-PoSt-miner attach存储
- [ ] 为Window-PoSt、PreCommitSector和ProveCommitSector设置独立的钱包

## Worker CheckList
- [ ] 复制Miner的api和token到每台Worker机器上的`LOTUS_MINER`目录下
- [ ] 配置Worker的环境变量，更改调度配置文件
- [ ] 批量启动P1 + P2 Worker
- [ ] 批量启动C2 Worker
