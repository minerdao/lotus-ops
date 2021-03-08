# Filecoin存储管理，存储i/o性能分析，网络分析
## 1. 存储路径操作
### 1.1  更改默认存储路径
`export LOTUS_MINER_PATH="/path/to/.lotusminer"`
- Miner 默认存储路径是 `~/.lotusminer`，可通过指定 `LOTUS_MINER_PATH` 环境变量来更改；
- `$LOTUS_MINER_PATH` 目录下的 `storage.json` 文件，用来定义Miner挂载的所有存储路径，例如：
  ```json
  {
    "StoragePaths": [
      {
        "Path": "/home/ubuntu/disk_md0/lotusminer"
      },
      {
        "Path": "/home/ubuntu/sectors/storage0"
      },
      {
        "Path": "/home/ubuntu/sectors/storage1"
      }
    ]
  }
  ```
  - 其中`/home/ubuntu/disk_md0/lotusminer`为Miner本地Worker的存储路径；
  - `/home/ubuntu/sectors/storage0`和`/home/ubuntu/sectors/storage1`都是新增的用来存储密封结果的路径。
- 每个存储路径下都会有 `sectorstore.json` 配置文件，用来配置该存储路径的用途。
  ```json
  {
    "ID": "83b4fc88-283a-4496-a2f9-cf10781c4ec3", # 唯一标识ID
    "Weight": 10, # 该存储路径权重
    "CanSeal": true, # 是否可以用来存储密封过程中生成的临时文件
    "CanStore": true  # 是否可以用来存储密封好的数据
  }
  ```
  其中需要注意的3个参数是：
  - `Weight`: 该存储路径的权重，**权重越大的路径会优先存数据**；
  - `CanSeal`: 是否可以用来存储密封过程中生成的临时文件;
  - `CanStore`: 是否可以用来存储密封好的数据，Miner本地Worker的`CanStore`要设置为`false`，Seal Worker的`CanStore`默认就是`false`;

### 1.2 增加存储路径
```sh
# 设置数据存储路径，该路径用来存储最终密封好的数据
# 执行该命令可能需要一点时间等待
lotus-miner storage attach --store --init /path/to/persistent_storage

# 设置密封扇区的存储路径，密封完成之后该路径下的数据会被自动清空，相当于临时目录
# 执行该命令可能需要一点时间等待
lotus-miner storage attach --seal --init /path/to/fast_cache
```
以上两个命令都是在启动了 Miner 之后才可以执行，是一种动态添加存储路径的方式，非常灵活。 当然还可以在命令中添加权重 `--weight=10`，默认权重是 10。 执行该命令后，可通过以下命令查看存储列表:
`lotus-miner storage list`

### 1.3 多个存储路径管理
当Miner挂载多个存储路径时，需要对多个存储路径进行管理时，可以手动对每个存储路径下的 `sectorstore.json` 配置文件进行修改权重的配比和存储路径的用途管理。当多个存储路径配置不同的权重时，Miner会根据各个存储路径的权重配比进行存储。若某一存储路径快满时，可以设置该路径下的 `sectorstore.json` 中`"CanSeal": false`、 `"CanStore": false`，重启miner后生效，这样Miner就不会往该路径下存储任何数据了。

## 2. 存储i/o性能分析
Filecoin挖矿的过程中存储性能至关重要，当存储性能无法满足要求时，会出现封装期间不断掉算力的窘境。
### 2.1 存储性能测试
对存储性能进行测试可直接对Miner机器上的存储挂载路径使用fio进行测试。
- 安装fio
`sudo apt-get install fio`
- fio测试场景
```
   #100%随机，100%读， 4K
　　fio -filename=/dev/emcpowerb -direct=1 -iodepth 1 -thread -rw=randread -ioengine=psync -bs=4k -size=1000G -numjobs=50 -runtime=180 -group_reporting -name=rand_100read_4k

　　#100%随机，100%写， 4K
　　fio -filename=/dev/emcpowerb -direct=1 -iodepth 1 -thread -rw=randwrite -ioengine=psync -bs=4k -size=1000G -numjobs=50 -runtime=180 -group_reporting -name=rand_100write_4k

　　#100%顺序，100%读 ，4K
　　fio -filename=/dev/emcpowerb -direct=1 -iodepth 1 -thread -rw=read -ioengine=psync -bs=4k -size=1000G -numjobs=50 -runtime=180 -group_reporting -name=sqe_100read_4k

　　#100%顺序，100%写 ，4K
　　fio -filename=/dev/emcpowerb -direct=1 -iodepth 1 -thread -rw=write -ioengine=psync -bs=4k -size=1000G -numjobs=50 -runtime=180 -group_reporting -name=sqe_100write_4k

　　#100%随机，70%读，30%写 4K
　　fio -filename=/dev/emcpowerb -direct=1 -iodepth 1 -thread -rw=randrw -rwmixread=70 -ioengine=psync -bs=4k -size=1000G -numjobs=50 -runtime=180 -group_reporting -name=randrw_70read_4k
```
## 3. 网络性能分析
Filecoin挖矿过程中网络架构的设计，会对整个集群的封装效率和WindowPoSt产生影响，服务器间的网络性能可以通过iperf3进行测试。
- 在需要进行测试的服务器上安装iperf3
`sudo apt-get install iperf3`
- 在一台Server服务器上运行（可选择Miner机作为Server机器，方便测试各个存储机与Miner机之间的网络性能）
`iperf3 -s`
- 在客户端服务器上运行（可以选择存储机作为客户端）
`iperf3 -c 192.168.1.2 -t 10  #该ip为Server服务器内网ip`
可以根据网络测试结果来对封装期间写入存储的数据量进行调整，防止出现因为封装数据写入存储机过大占满Miner和存储机之间的网络传输带宽，此时若进行WindPost则可能会导致Miner机与存储之间无足够的带宽进行数据读取验证，读取超时丢失算力。
