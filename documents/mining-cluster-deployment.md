# Filecoin同构集群搭建

## 1. 同步Daemon
集群搭建首先需要同步Daemon到最新高度，按照[Filecoin节点搭建及启动](./daemon-deployment.md)搭建并同步好Daemon。

## 2. 准备钱包
初始化并将Daemon同步到最新高度后，运行以下命令创建钱包:
```sh
$ lotus wallet new bls
```
Lotus钱包相关

## 3. 配置Miner环境变量
在`~/.profile`文件中，添加以下内容，并`source ~/.profile`:
```sh
export BELLMAN_CPU_UTILIZATION=0.875
export FIL_PROOFS_MAXIMIZE_CACHING=1
export FIL_PROOFS_USE_GPU_COLUMN_BUILDER=1
export FIL_PROOFS_USE_GPU_TREE_BUILDER=1
# > 100GiB!
export FIL_PROOFS_PARAMETER_CACHE=<FAST_DISK_FOLDER1>

# > 50GiB!
export FIL_PROOFS_PARENT_CACHE=<FAST_DISK_FOLDER2>
export TMPDIR=<FAST_DISK_FOLDER3>

# 存储miner相关文件，建议放在空间大的磁盘分区
export LOTUS_MINER_PATH=<FAST_DISK_FOLDER4>
```
其中:
- `FAST_DISK_FOLDER1`为证明参数文件目录，32GB的扇区大约需要110GB的空间；
- `FAST_DISK_FOLDER2`为PreCommit1缓存文件路径，大小为56GB；
- `FAST_DISK_FOLDER3`为临时文件目录，主要用于存放GPU锁定文件；
- `FAST_DISK_FOLDER4`为Miner相关文件的存储目录，至少需要2TB的存储空间；

## 4. 初始化Miner
配置好上面的环境变量后，通过以下命令初始化Miner。
```sh
$ lotus-miner init --owner=<WALLET_ADDRESS>
```
此处的`WALLET_ADDRESS`为上面第一步中创建的钱包地址。

## 5. 启动Miner
#### 5.1 配置`LOTUS_MINER_PATH`路径
Miner配置文件默认在`~/.lotusminer/config.toml`文件中, 若配置了`$LOTUS_MINER_PATH`环境变量，则在此路径下。

#### 5.2 更新Miner配置文件
在配置文件`config.toml`中，打开以下配置，把下面的`MINER_IP_ADDRESS`改成Miner本机的内网IP地址，并指定一个端口，`lotus-miner`默认端口是`2345`。
```toml
[API]
ListenAddress = "/ip4/<MINER_IP_ADDRESS>/tcp/<PORT>/http"
RemoteListenAddress = "<MINER_IP_ADDRESS>:<PORT>"
Timeout = "30s"
...

[Storage]
AllowAddPiece = false
AllowPreCommit1 = false
AllowPreCommit2 = false
AllowCommit = false
AllowUnseal = true
```

#### 5.3 更改存储路径
修改`$LOTUS_MINER_PATH/sectorstore.json`文件，将`CanStore`的值改为`false`。

#### 5.4 启动Miner
```sh
$ lotus-miner run
```

#### 5.5 查看Miner状态
```sh
$ lotus-miner info
```

#### 5.6 挂载存储路径
`<STORAGE_PATH>`为存储封装结果的路径。
```sh
# 新增存储路径
lotus-miner storage attach --store --init <STORAGE_PATH>

# 查看Miner存储路径
lotus-miner storage list
```

## 6. 启动Worker
#### 6.1 配置`MINER_API_INFO`
设置环境变量，使Workers可以连接到Miner：

```sh
export MINER_API_INFO=<TOKEN>:<API>
```
其中`<API>`的格式为`ip4/<MINER_API_ADDRESS>/tcp/<PORT>/http`。

`<TOKEN>`为`~/.lotusminer/token`文件中的内容, `<API>`为`~/.lotusminer/api`文件中的内容。

或输入以下命令直接获取：
```sh
$ lotus-miner auth api-info --perm admin
```
#### 6.2 配置`LOTUS_WORKER_PATH`
设置Worker路径的环境变量，建议放在空间大的磁盘分区:
```sh
export LOTUS_WORKER_PATH=<YOUR_FAST_DISK_FOLDER5> 
```

#### 6.3 配置Worker其他环境变量
```sh
export FIL_PROOFS_USE_MULTICORE_SDR=1
export FIL_PROOFS_MAXIMIZE_CACHING=1
export FIL_PROOFS_USE_GPU_COLUMN_BUILDER=1
export FIL_PROOFS_USE_GPU_TREE_BUILDER=1
```
其中：
- `FIL_PROOFS_USE_MULTICORE_SDR`：PreCommit1多CPU核心绑定；
- `FIL_PROOFS_MAXIMIZE_CACHING`：PreCommit1开启内存最大化；
- `FIL_PROOFS_USE_GPU_COLUMN_BUILDER`：使用GPU计算COLUMN hash；
- `FIL_PROOFS_USE_GPU_TREE_BUILDER`：使用GPU计算TREE hash；

#### 6.4 启动worker
```sh
$ lotus-worker run
```

#### 6.5 查看worker信息
```sh
$ lotus-worker info
```

## 7. 封装Sector
#### 7.1 封装一个sector
```sh
$ lotus-miner sectors pledge
```

#### 7.2 查看启动的封装任务
```sh
$ lotus-miner sealing jobs
```

#### 7.3 检查启动的workers
```sh
$ lotus-miner sealing workers
```

#### 7.4 查看sector信息
```sh
$ lotus-miner sectors list
```