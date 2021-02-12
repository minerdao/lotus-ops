# Filecoin同构集群搭建流程详解

## 1. 准备钱包
初始化并将Deamon同步到最新高度后，运行以下命令创建钱包。
```sh
$ lotus wallet new bls
```

## 2. 配置Miner环境变量
在`vi ~/.profile`文件中，添加以下内容：
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
其中：
- `FAST_DISK_FOLDER1`为证明参数文件目录，32GB的扇区大约需要110GB的空间；
- `FAST_DISK_FOLDER2`为PreCommit1缓存文件路径，大小为56GB；
- `FAST_DISK_FOLDER3`为临时文件目录，主要用于存放GPU锁定文件；
- `FAST_DISK_FOLDER4`为Miner相关文件的存储目录，至少需要2TB的存储空间；

## 3. 初始化Miner
配置好上面的环境变量后，通过以下命令初始化Miner。
```sh
$ lotus-miner init --owner=<WALLET_ADDRESS>
```
此处的`WALLET_ADDRESS`为上面第一步中创建的钱包地址。

## 4. 启动Miner
Miner配置文件默认在`~/.lotusminer/config.toml`文件中, 若配置了`$LOTUS_MINER_PATH`环境变量，则在此路径下。

在配置文件`config.toml`中，打开以下配置，把下面的`MINER_IP_ADDRESS`改成Miner本机地址，并指定一个端口，`lotus-miner`默认端口是`2345`。
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

启动Miner：
```sh
$ lotus-miner run
```
查看Miner状态：
```sh
$ lotus-miner info
```

## 5. 启动Worker
设置环境变量，使Workers可以连接到Miner

```sh
export MINER_API_INFO=<TOKEN>:<API>
```
其中`<API>`的格式为`ip4/<MINER_API_ADDRESS>/tcp/<PORT>/http`。

`<TOKEN>`为`~/.lotusminer/token`文件中的内容, `<API>`为`~/.lotusminer/api`文件中的内容。

或输入以下命令直接获取：
```sh
$ lotus-miner auth api-info --perm admin
```

提高PreCommit1的速度：
```sh
export FIL_PROOFS_USE_MULTICORE_SDR=1
```

设置worker路径的环境变量，建议放在空间大的磁盘分区:
```sh
export LOTUS_WORKER_PATH=<YOUR_FAST_DISK_FOLDER5> 
```

## 6. 封装Sector
封装一个sector
```sh
$ lotus-miner sectors pledge
```

检查启动的jobs
```sh
$ lotus-miner sealing jobs
```

检查启动的workers
```sh
$ lotus-miner sealing workers
```

查看sector信息
```sh
$ lotus-miner sectors list
```

## 7. 集群常用操作
列出钱包地址
```sh
$ lotus wallet list
```

查看余额
```sh
$ lotus wallet balance <WALLET_ADDRESS>
```

默认钱包地址
```sh
$ lotus wallet default
```

设置默认钱包地址
```sh
$ lotus wallet set-default <WALLET_ADDRESS>
# 例如: lotus wallet set-default fxxxx001
```

从默认钱包地址发送代币
```sh
$ lotus send <TARGET_ADDRESS> <AMOUNT>
# 例如: lotus send fxxxxx001 10
```

从指定钱包地址发送代币
```sh
$ lotus send --from=<SENDER_ADDRESS> <TARGET_ADDRESS> <AMOUNT>
# 例如: lotus send --from=fxxxxxx002 fxxxxxx001 3
```

导出钱包地址
```sh
$ lotus wallet export <WALLET_ADDRESS> > <WALLET_ADDRESS>.key
# 例如: lotus wallet export fxxxxx001 > fxxxxx001.key
```

导入钱包地址
```sh
$ lotus wallet import <WALLET_ADDRESS>.key
# 例如: lotus wallet import fxxxxx001.key
```