# 分布式Miner模块配置和使用

分布式Miner支持Deal-miner、Seal-miner、Winning-PoSt-miner、Window-PoSt-miner功能分离，各司其职，实现多Miner的分布式部署。

## 解决了哪些问题？
- 单Miner节点负载过高，机器不稳定容易导致时空证明失败掉算力的问题；
- 解决Miner节点负载过高，出块时由于计算不够快，导致的出块失败问题；
- 解决Window-PoSt和Winning-PoSt同时进行时，显卡锁定冲突的问题；
- 解决接单的时候，由于内存占用过高导致Miner异常崩溃，掉算力、出块失败的问题；

## 功能说明
- 支持同一个MinerId在多台机器上分布式部署；
- 支持Window-post-miner、Winning-post-miner、Deal-miner、Seal-miner功能分离：
  - PoSt-miner：负责Window-PoSt和Winning-PoSt，可分开为两台机器，也可由一台机器完成；
    - Window-post-miner：负责扇区窗口证明时的扇区抽查及提交；
    - Winning-post-miner：负责出块时扇区的随机抽查；
  - Deal-miner：负责接单和检索，和订单扇区密封的任务分配；
  - Seal-miner：负责普通扇区密封的任务分配。

![Distributed Miner](../images/distributed-miner.png)

## 实现思路
**1. 解决SectorID不重复**

利用一台Miner集中分配SectorID，由任意一台Miner的`--sctype=alloce`参数实现。
并由启用`--sclisten=IP:PORT`参数的Miner作为分配SectorID的Server，其他Miner设置`--sctype=get`作为Client，从Server Miner上申请SectorID。

```sh
lotus-miner run --sctype=alloce --sclisten=192.168.1.50:1357
```

**2. 解决时空证明由单独的机器完成**

由任意一台Miner的`--window-post=true`和`--winning-post=true`参数实现时空证明由一台/两台独立的机器完成，其他Miner要设置`--window-post=false`和`--winning-post=false`。

```sh
lotus-miner run --window-post=true --winning-post=true
```

**3. 解决接单及检索**

由任意一台Miner的`--p2p=true`参数实现，接单的Miner需要配置多地址。

```sh
lotus-miner run --p2p=true
```

## 参数说明
- `--window-post` [boolean] 是否允许window-PoSt证明，默认`true`；
- `--winning-post` [boolean] 是否允许winning-PoSt证明，即出块，默认`true`；
- `--p2p` [boolean] 是否允许接单，默认`true`；
- `--sctype` [alloce | get] 扇区分配服务类型，`alloce`表示分配SectorID，`get`表示获取SectorID;
- `--sclisten` [string] 扇区分配服务端监听的地址和端口;

## 配置举例
现有的单Miner集群要切换到分布式Miner，需要先停掉原有Miner和所有Worker，保证没有进行中的任务。然后将原有单Miner的`$LOTUS_STORAGE_PATH`目录，复制到其他Miner上，并将`$LOTUS_STORAGE_PATH/config.toml`文件中[API]部分的`ListenAddress`和`RemoteListenAddress`IP改为当前所在Miner的内网IP。

比如有3个Miner，由PoSt-miner负责SectorID分配(也可由其他Miner分配)。

**1. PoSt-miner**
```
lotus-miner run --window-post=true --winning-post=true --p2p=false --sctype=alloce --sclisten=192.168.1.50:1357
```
其中`192.168.1.50`为PoSt-miner的内网IP，`1357`为扇区分配服务的监听端口。
PoSt-miner启动后，在日志中将会有`This miner will be disable p2p`的提示。

如果PoSt-miner为两台机器，则需要分别配置`--window-post`和`--winning-post`参数：

**Window-post-miner**（负责窗口抽查证明）配置为：
```sh
lotus-miner run --window-post=true --winning-post=false --p2p=false --sctype=alloce --sclisten=192.168.1.50:1357
```

**Winning-post-miner**（负责出块的证明）配置为：
```sh
lotus-miner run --window-post=false --winning-post=true --p2p=false --sctype=alloce --sclisten=192.168.1.50:1357
```

**注意：负责扇区分配的Miner，首次部署的时候，需要修改`$LOTUS_STORAGE_PATH/sectorid`文件(首次部署需要创建该文件)，将其中的数字改为大于当前所有扇区ID的一个数字。**

**2. Deal-miner**
```
lotus-miner run --window-post=false --winning-post=false --p2p=true --sctype=get --sclisten=192.16810.50:1357
```
其中`--sclisten`监听的地址和端口为做扇区分配Server Miner的IP和端口。  
Deal-miner需要配置外网端口转发和`lotus-miner actor set-addrs`配置多地址。

**注意：Deal-miner也只能配置一台，不然订单检索的时候会路由失败。**

**3. Seal-miner**
```
lotus-miner run --window-post=false --winning-post=false --p2p=true --sctype=get --sclisten=192.16810.50:1357
```

**需要注意的几个问题：**
- Seal-miner和Deal-miner的配置参数相同，原理上都是密封扇区的Miner；  
- Seal-miner和Deal-miner启动后，日志中将会输出`This miner will be disable minning block`和`This miner will be disable windowPoSt`；  
- Seal-miner可根据自己的集群规模，配置多台；

## Worker配置
使用分布式Miner以后，需要根据配置的Seal-miner和Deal-miner数量，将Seal-worker分为多个组，和Miner一一对应。

假设现在有1台Deal-miner，2台Seal-miner，5台Seal-worker，因为Deal-miner的接单速度比较慢，可以给Deal-miner分配一台Seal-worker，其他两台Seal-miner各分配2台Seal-worker。