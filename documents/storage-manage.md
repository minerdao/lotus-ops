# Filecoin存储管理，存储i/o性能分析，网络分析
## 1. 存储路径操作
### 1.1  更改默认存储路径
`export LOTUS_STORAGE_PATH="/path/to/.lotusminer"`
- 默认存储路径是 ~/.lotusminer，可通过指定 LOTUS_STORAGE_PATH 环境变量来更改；
- 每个存储路径下都会有 sectorstore.json 配置文件，该文件可以配置该存储路径的用途。
```
{
  "ID": "83b4fc88-283a-4496-a2f9-cf10781c4ec3", #唯一标识ID
  "Weight": 10, #该存储路径权重
  "CanSeal": true, #是否可以用来存储密封过程中生成的临时文件
  "CanStore": true  #是否可以用来存储密封好的数据
}
```
### 1.2 增加存储路径
```
# 设置数据存储路径，该路径用来存储最终密封好的数据
# 执行该命令可能需要一点时间等待
lotus-miner storage attach --store --init /path/to/persistent_storage

# 设置密封扇区的存储路径，密封完成之后该路径下的数据会被自动清空，相当于临时目录
# 执行该命令可能需要一点时间等待
lotus-miner storage attach --seal --init /path/to/fast_cache
```
以上两个命令都是在启动了 miner 之后才可以执行，是一种动态添加存储路径的方式，非常灵活。 当然还可以在命令中添加权重 --weight=10，默认权重是 10。 执行该命令后，可通过以下命令查看存储列表:
`lotus-miner storage list`
### 1.3 多个存储路径管理
当Miner挂载多个存储路径时，需要对多个存储路径进行管理时，可以手动对每个存储路径下的sectorstore.json 配置文件进行修改权重的配比和存储路径的用途管理。当多个存储路径配置不同的权重时，Miner会根据各个存储路径的权重配比进行存储。若某一存储路径快满时，可以设置该路径下的sectorstore.json中`"CanSeal": false`、 `"CanStore": false`，这样Miner就不会往该路径下存储任何数据了。
## 2. 存储i/o性能分析
Fil挖矿的过程中存储性能至关重要，当存储性能无法满足要求时，会出现封装期间不断掉算力的窘境。
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
